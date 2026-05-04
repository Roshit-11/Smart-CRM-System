package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.ActivityLog;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityLogDao {

    public boolean logActivity(ActivityLog log) {
        String sql = "INSERT INTO activity_logs (company_name, customer_id, user_id, action, details) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, log.getCompanyName());
            pstmt.setInt(2, log.getCustomerId());
            pstmt.setInt(3, log.getUserId());
            pstmt.setString(4, log.getAction());
            pstmt.setString(5, log.getDetails());
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<ActivityLog> getLogsByCustomer(int customerId, String companyName) {
        String sql = "SELECT l.id, l.company_name, l.customer_id, l.user_id, l.action, l.details, l.created_at, u.name AS user_name "
                + "FROM activity_logs l "
                + "JOIN customers c ON l.customer_id = c.id "
                + "JOIN users cu ON c.created_by = cu.id "
                + "JOIN users u ON l.user_id = u.id "
                + "WHERE l.customer_id = ? AND l.company_name = ? AND cu.company_name = ? "
                + "ORDER BY l.created_at DESC";

        List<ActivityLog> logs = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);
            pstmt.setString(2, companyName);
            pstmt.setString(3, companyName);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                ActivityLog log = new ActivityLog();
                log.setId(rs.getInt("id"));
                log.setCompanyName(rs.getString("company_name"));
                log.setCustomerId(rs.getInt("customer_id"));
                log.setUserId(rs.getInt("user_id"));
                log.setAction(rs.getString("action"));
                log.setDetails(rs.getString("details"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                log.setUserName(rs.getString("user_name"));
                logs.add(log);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return logs;
    }

    public int countActivitySince(String companyName, Timestamp since) {
        String sql = "SELECT COUNT(*) FROM activity_logs WHERE company_name = ? AND created_at >= ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            pstmt.setTimestamp(2, since);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<ActivityLog> getRecentActivities(String companyName) {
        String sql = "SELECT al.id, al.action, al.created_at, u.name AS user_name "
                + "FROM activity_logs al "
                + "JOIN users u ON al.user_id = u.id "
                + "WHERE u.company_name = ? "
                + "ORDER BY al.created_at DESC "
                + "LIMIT 5";
        List<ActivityLog> logs = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                ActivityLog log = new ActivityLog();
                log.setAction(rs.getString("action"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                log.setUserName(rs.getString("user_name"));
                logs.add(log);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return logs;
    }

    public List<Map<String, Object>> getActivityTrend(String companyName, int lastDays) {
        String sql = "SELECT DATE(created_at) AS day, COUNT(*) AS total "
                + "FROM activity_logs "
                + "WHERE company_name = ? AND created_at >= ? "
                + "GROUP BY DATE(created_at) "
                + "ORDER BY day ASC";

        List<Map<String, Object>> trend = new ArrayList<>();
        Timestamp since = Timestamp.valueOf(LocalDateTime.now().minusDays(lastDays - 1));

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            pstmt.setTimestamp(2, since);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("day", rs.getDate("day"));
                row.put("total", rs.getInt("total"));
                trend.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return trend;
    }
}