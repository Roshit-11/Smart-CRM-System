package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.IssueReport;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class IssueReportDao {

    public boolean createIssue(IssueReport issue) {
        String sql = "INSERT INTO issue_reports (sender_user_id, company_name, issue_type, subject, description, status, priority) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, issue.getSenderUserId());
            pstmt.setString(2, issue.getCompanyName());
            pstmt.setString(3, issue.getIssueType());
            pstmt.setString(4, issue.getSubject());
            pstmt.setString(5, issue.getDescription());
            pstmt.setString(6, issue.getStatus() != null ? issue.getStatus() : "Open");
            pstmt.setString(7, issue.getPriority() != null ? issue.getPriority() : "Medium");
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<IssueReport> getIssuesByUser(int userId) {
        String sql = "SELECT i.*, u.name AS sender_name, u.email AS sender_email, u.role AS sender_role "
                + "FROM issue_reports i "
                + "JOIN users u ON i.sender_user_id = u.id "
                + "WHERE i.sender_user_id = ? "
                + "ORDER BY i.created_at DESC";
        return query(sql, ps -> ps.setInt(1, userId));
    }

    public List<IssueReport> getIssuesByCompany(String companyName, String filterType, String filterStatus) {
        StringBuilder sb = new StringBuilder(
            "SELECT i.*, u.name AS sender_name, u.email AS sender_email, u.role AS sender_role "
            + "FROM issue_reports i "
            + "JOIN users u ON i.sender_user_id = u.id "
            + "WHERE i.company_name = ? ");
        List<Object> params = new ArrayList<>();
        params.add(companyName);
        if (filterType != null && !filterType.isEmpty() && !"all".equalsIgnoreCase(filterType)) {
            sb.append("AND i.issue_type = ? ");
            params.add(filterType);
        }
        if (filterStatus != null && !filterStatus.isEmpty() && !"all".equalsIgnoreCase(filterStatus)) {
            sb.append("AND i.status = ? ");
            params.add(filterStatus);
        }
        sb.append("ORDER BY FIELD(i.priority, 'High', 'Medium', 'Low'), i.created_at DESC");

        return query(sb.toString(), ps -> {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
        });
    }

    public IssueReport getIssueById(int id, String companyName) {
        String sql = "SELECT i.*, u.name AS sender_name, u.email AS sender_email, u.role AS sender_role "
                + "FROM issue_reports i "
                + "JOIN users u ON i.sender_user_id = u.id "
                + "WHERE i.id = ? AND i.company_name = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.setString(2, companyName);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateStatus(int id, String status, String adminResponse, String companyName) {
        String sql = "UPDATE issue_reports SET status = ?, admin_response = ?, updated_at = NOW() "
                + "WHERE id = ? AND company_name = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setString(2, adminResponse);
            pstmt.setInt(3, id);
            pstmt.setString(4, companyName);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteIssue(int id, int senderUserId) {
        // Only the sender can delete their own issue
        String sql = "DELETE FROM issue_reports WHERE id = ? AND sender_user_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.setInt(2, senderUserId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<String, Integer> countByStatus(String companyName) {
        Map<String, Integer> counts = new HashMap<>();
        counts.put("Open", 0);
        counts.put("In Progress", 0);
        counts.put("Resolved", 0);
        counts.put("Closed", 0);
        String sql = "SELECT status, COUNT(*) AS cnt FROM issue_reports WHERE company_name = ? GROUP BY status";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                counts.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return counts;
    }

    public int countByCompany(String companyName) {
        String sql = "SELECT COUNT(*) FROM issue_reports WHERE company_name = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ── helpers ──────────────────────────────────────────────
    @FunctionalInterface
    private interface Binder { void bind(PreparedStatement ps) throws SQLException; }

    private List<IssueReport> query(String sql, Binder binder) {
        List<IssueReport> list = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            binder.bind(pstmt);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private IssueReport mapRow(ResultSet rs) throws SQLException {
        IssueReport i = new IssueReport();
        i.setId(rs.getInt("id"));
        i.setSenderUserId(rs.getInt("sender_user_id"));
        i.setCompanyName(rs.getString("company_name"));
        i.setIssueType(rs.getString("issue_type"));
        i.setSubject(rs.getString("subject"));
        i.setDescription(rs.getString("description"));
        i.setStatus(rs.getString("status"));
        i.setPriority(rs.getString("priority"));
        i.setAdminResponse(rs.getString("admin_response"));
        i.setCreatedAt(rs.getTimestamp("created_at"));
        i.setUpdatedAt(rs.getTimestamp("updated_at"));
        i.setSenderName(rs.getString("sender_name"));
        i.setSenderEmail(rs.getString("sender_email"));
        i.setSenderRole(rs.getString("sender_role"));
        return i;
    }
}
