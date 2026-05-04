package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.Notification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NotificationDao {

    public boolean createNotification(int userId, String message, String type, String entityType, int entityId) {
        String sql = "INSERT INTO notifications (user_id, message, type, entity_type, entity_id, is_read) VALUES (?, ?, ?, ?, ?, FALSE)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setString(2, message);
            pstmt.setString(3, type);
            pstmt.setString(4, entityType);
            pstmt.setInt(5, entityId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Notification> getNotificationsByUser(int userId) {
        String sql = "SELECT n.id, n.user_id, n.message, n.type, n.is_read, n.created_at, n.entity_type, n.entity_id, "
                + "t.customer_id AS task_customer_id "
                + "FROM notifications n "
                + "LEFT JOIN customer_tasks t ON n.entity_type = 'task' AND n.entity_id = t.id "
                + "WHERE n.user_id = ? "
                + "ORDER BY n.created_at DESC "
                + "LIMIT 15";

        List<Notification> notifications = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Notification n = new Notification();
                n.setId(rs.getInt("id"));
                n.setUserId(rs.getInt("user_id"));
                n.setMessage(rs.getString("message"));
                n.setType(rs.getString("type"));
                n.setRead(rs.getBoolean("is_read"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                n.setEntityType(rs.getString("entity_type"));
                n.setEntityId(rs.getInt("entity_id"));
                n.setRelatedCustomerId(rs.getInt("task_customer_id"));
                notifications.add(n);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return notifications;
    }

    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, notificationId);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countUnreadNotifications(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }
}
