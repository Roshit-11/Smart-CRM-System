package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.Task;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class TaskDao {

    public boolean createTask(Task task) {
        String sql = "INSERT INTO customer_tasks (customer_id, title, due_date, status, assigned_user_id, created_by) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, task.getCustomerId());
            pstmt.setString(2, task.getTitle());
            pstmt.setDate(3, task.getDueDate());
            pstmt.setString(4, task.getStatus());
            pstmt.setInt(5, task.getAssignedUserId());
            pstmt.setInt(6, task.getCreatedBy());
            boolean created = pstmt.executeUpdate() > 0;
            if (created) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        task.setId(rs.getInt(1));
                    }
                }
            }
            return created;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Task> getTasksByCustomer(int customerId, String companyName) {
        String sql = "SELECT t.id, t.customer_id, t.title, t.due_date, t.status, t.assigned_user_id, t.created_by, t.created_at, "
                + "u.name AS assigned_user_name "
                + "FROM customer_tasks t "
                + "JOIN customers c ON t.customer_id = c.id "
                + "JOIN users cu ON c.created_by = cu.id "
                + "LEFT JOIN users u ON t.assigned_user_id = u.id "
                + "WHERE t.customer_id = ? AND cu.company_name = ? "
                + "ORDER BY t.due_date ASC, t.created_at DESC";

        List<Task> tasks = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);
            pstmt.setString(2, companyName);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Task task = new Task();
                task.setId(rs.getInt("id"));
                task.setCustomerId(rs.getInt("customer_id"));
                task.setTitle(rs.getString("title"));
                task.setDueDate(rs.getDate("due_date"));
                task.setStatus(rs.getString("status"));
                task.setAssignedUserId(rs.getInt("assigned_user_id"));
                task.setCreatedBy(rs.getInt("created_by"));
                task.setCreatedAt(rs.getTimestamp("created_at"));
                task.setAssignedUserName(rs.getString("assigned_user_name"));
                tasks.add(task);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }

    public boolean updateTaskStatus(int taskId, String status, String companyName) {
        String sql = "UPDATE customer_tasks SET status = ? "
                + "WHERE id = ? AND customer_id IN (SELECT c.id FROM customers c JOIN users u ON c.created_by = u.id WHERE u.company_name = ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            pstmt.setInt(2, taskId);
            pstmt.setString(3, companyName);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Task getTaskByIdAndCompany(int taskId, String companyName) {
        String sql = "SELECT t.id, t.customer_id, t.title, t.due_date, t.status, t.assigned_user_id, t.created_by, t.created_at "
                + "FROM customer_tasks t "
                + "JOIN customers c ON t.customer_id = c.id "
                + "JOIN users u ON c.created_by = u.id "
                + "WHERE t.id = ? AND u.company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, taskId);
            pstmt.setString(2, companyName);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                Task task = new Task();
                task.setId(rs.getInt("id"));
                task.setCustomerId(rs.getInt("customer_id"));
                task.setTitle(rs.getString("title"));
                task.setDueDate(rs.getDate("due_date"));
                task.setStatus(rs.getString("status"));
                task.setAssignedUserId(rs.getInt("assigned_user_id"));
                task.setCreatedBy(rs.getInt("created_by"));
                task.setCreatedAt(rs.getTimestamp("created_at"));
                return task;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public int countTasksByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM customer_tasks WHERE assigned_user_id = ?";

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

    public List<Task> getTasksByUser(int userId) {
        String sql = "SELECT title, due_date, status FROM customer_tasks WHERE assigned_user_id = ? ORDER BY due_date ASC LIMIT 5";
        List<Task> tasks = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Task task = new Task();
                task.setTitle(rs.getString("title"));
                task.setDueDate(rs.getDate("due_date"));
                task.setStatus(rs.getString("status"));
                tasks.add(task);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }

    public List<Task> getRecentTasksByCompany(String companyName) {
        String sql = "SELECT t.title, t.due_date, t.status "
                + "FROM customer_tasks t "
                + "JOIN customers c ON t.customer_id = c.id "
                + "JOIN users u ON c.created_by = u.id "
                + "WHERE u.company_name = ? "
                + "ORDER BY t.due_date ASC, t.created_at DESC "
                + "LIMIT 5";

        List<Task> tasks = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Task task = new Task();
                task.setTitle(rs.getString("title"));
                task.setDueDate(rs.getDate("due_date"));
                task.setStatus(rs.getString("status"));
                tasks.add(task);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }

    public boolean updateTask(Task task, String companyName) {
        String sql = "UPDATE customer_tasks ct "
                + "JOIN customers c ON ct.customer_id = c.id "
                + "JOIN users u ON c.created_by = u.id "
                + "SET ct.title = ?, ct.due_date = ?, ct.status = ?, ct.assigned_user_id = ?, ct.updated_at = NOW() "
                + "WHERE ct.id = ? AND u.company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, task.getTitle());
            pstmt.setDate(2, task.getDueDate());
            pstmt.setString(3, task.getStatus());
            pstmt.setInt(4, task.getAssignedUserId());
            pstmt.setInt(5, task.getId());
            pstmt.setString(6, companyName);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteTask(int taskId, String companyName) {
        String sql = "DELETE ct FROM customer_tasks ct "
                + "JOIN customers c ON ct.customer_id = c.id "
                + "JOIN users u ON c.created_by = u.id "
                + "WHERE ct.id = ? AND u.company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, taskId);
            pstmt.setString(2, companyName);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}