package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.Deal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DealDao {

    public boolean createDeal(Deal deal) {
        String sql = "INSERT INTO deals (customer_id, title, value, stage, assigned_user_id, created_by) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, deal.getCustomerId());
            pstmt.setString(2, deal.getTitle());
            pstmt.setBigDecimal(3, deal.getValue());
            pstmt.setString(4, deal.getStage());
            if (deal.getAssignedUserId() == null || deal.getAssignedUserId() <= 0) {
                pstmt.setNull(5, java.sql.Types.INTEGER);
            } else {
                pstmt.setInt(5, deal.getAssignedUserId());
            }
            pstmt.setInt(6, deal.getCreatedBy());

            boolean created = pstmt.executeUpdate() > 0;
            if (created) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        deal.setId(rs.getInt(1));
                    }
                }
            }
            return created;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Deal> getDealsByCompany(String companyName, String search, String stage, Integer assignedUserId) {
        List<Deal> deals = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT d.id, d.customer_id, c.name AS customer_name, d.title, d.value, d.stage, "
                        + "d.assigned_user_id, au.name AS assigned_user_name, d.created_by, d.created_at, d.updated_at "
                        + "FROM deals d "
                        + "JOIN customers c ON d.customer_id = c.id "
                        + "JOIN users cu ON c.created_by = cu.id "
                        + "LEFT JOIN users au ON d.assigned_user_id = au.id "
                        + "WHERE cu.company_name = ?"
        );

        List<Object> params = new ArrayList<>();
        params.add(companyName);

        String safeSearch = search == null ? "" : search.trim();
        String safeStage = stage == null ? "" : stage.trim();

        if (!safeSearch.isEmpty()) {
            sql.append(" AND d.title LIKE ?");
            params.add("%" + safeSearch + "%");
        }

        if (!safeStage.isEmpty()) {
            sql.append(" AND d.stage = ?");
            params.add(safeStage);
        }

        if (assignedUserId != null && assignedUserId > 0) {
            sql.append(" AND d.assigned_user_id = ?");
            params.add(assignedUserId);
        }

        sql.append(" ORDER BY d.updated_at DESC");

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object value = params.get(i);
                if (value instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) value);
                } else {
                    pstmt.setString(i + 1, String.valueOf(value));
                }
            }

            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                deals.add(mapDeal(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return deals;
    }

    public List<Deal> getDealsByCustomer(int customerId, String companyName) {
        String sql = "SELECT d.id, d.customer_id, c.name AS customer_name, d.title, d.value, d.stage, "
                + "d.assigned_user_id, au.name AS assigned_user_name, d.created_by, d.created_at, d.updated_at "
                + "FROM deals d "
                + "JOIN customers c ON d.customer_id = c.id "
                + "JOIN users cu ON c.created_by = cu.id "
                + "LEFT JOIN users au ON d.assigned_user_id = au.id "
                + "WHERE d.customer_id = ? AND cu.company_name = ? "
                + "ORDER BY d.updated_at DESC";

        List<Deal> deals = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);
            pstmt.setString(2, companyName);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                deals.add(mapDeal(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return deals;
    }

    public boolean updateDeal(Deal deal, String companyName, Integer assignedUserIdFilter) {
        StringBuilder sql = new StringBuilder(
                "UPDATE deals d "
                        + "JOIN customers c ON d.customer_id = c.id "
                        + "JOIN users u ON c.created_by = u.id "
                        + "SET d.title = ?, d.value = ?, d.stage = ?, d.assigned_user_id = ?, d.updated_at = NOW() "
                        + "WHERE d.id = ? AND u.company_name = ?"
        );

        if (assignedUserIdFilter != null && assignedUserIdFilter > 0) {
            sql.append(" AND d.assigned_user_id = ?");
        }

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            pstmt.setString(1, deal.getTitle());
            pstmt.setBigDecimal(2, deal.getValue());
            pstmt.setString(3, deal.getStage());
            if (deal.getAssignedUserId() == null || deal.getAssignedUserId() <= 0) {
                pstmt.setNull(4, java.sql.Types.INTEGER);
            } else {
                pstmt.setInt(4, deal.getAssignedUserId());
            }
            pstmt.setInt(5, deal.getId());
            pstmt.setString(6, companyName);

            if (assignedUserIdFilter != null && assignedUserIdFilter > 0) {
                pstmt.setInt(7, assignedUserIdFilter);
            }

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateDealStage(int dealId, String stage, String companyName, Integer assignedUserIdFilter) {
        StringBuilder sql = new StringBuilder(
                "UPDATE deals d "
                        + "JOIN customers c ON d.customer_id = c.id "
                        + "JOIN users u ON c.created_by = u.id "
                        + "SET d.stage = ?, d.updated_at = NOW() "
                        + "WHERE d.id = ? AND u.company_name = ?"
        );

        if (assignedUserIdFilter != null && assignedUserIdFilter > 0) {
            sql.append(" AND d.assigned_user_id = ?");
        }

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            pstmt.setString(1, stage);
            pstmt.setInt(2, dealId);
            pstmt.setString(3, companyName);

            if (assignedUserIdFilter != null && assignedUserIdFilter > 0) {
                pstmt.setInt(4, assignedUserIdFilter);
            }

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteDeal(int dealId, String companyName, Integer assignedUserIdFilter) {
        StringBuilder sql = new StringBuilder(
                "DELETE d FROM deals d "
                        + "JOIN customers c ON d.customer_id = c.id "
                        + "JOIN users u ON c.created_by = u.id "
                        + "WHERE d.id = ? AND u.company_name = ?"
        );

        if (assignedUserIdFilter != null && assignedUserIdFilter > 0) {
            sql.append(" AND d.assigned_user_id = ?");
        }

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            pstmt.setInt(1, dealId);
            pstmt.setString(2, companyName);

            if (assignedUserIdFilter != null && assignedUserIdFilter > 0) {
                pstmt.setInt(3, assignedUserIdFilter);
            }

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Deal mapDeal(ResultSet rs) throws SQLException {
        Deal deal = new Deal();
        deal.setId(rs.getInt("id"));
        deal.setCustomerId(rs.getInt("customer_id"));
        deal.setCustomerName(rs.getString("customer_name"));
        deal.setTitle(rs.getString("title"));
        deal.setValue(rs.getBigDecimal("value"));
        deal.setStage(rs.getString("stage"));

        int assignedId = rs.getInt("assigned_user_id");
        if (rs.wasNull()) {
            deal.setAssignedUserId(null);
        } else {
            deal.setAssignedUserId(assignedId);
        }
        deal.setAssignedUserName(rs.getString("assigned_user_name"));
        deal.setCreatedBy(rs.getInt("created_by"));
        deal.setCreatedAt(rs.getTimestamp("created_at"));
        deal.setUpdatedAt(rs.getTimestamp("updated_at"));
        return deal;
    }
}
