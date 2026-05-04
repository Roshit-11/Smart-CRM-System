package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.Customer;
import com.crm.app.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CustomerDao {

    public List<Customer> getCustomersByCompany(String companyName, String search, String status, String assignedUser, String sort) {
        List<Customer> customers = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.name, c.email, c.phone, c.company, c.status, c.assigned_user_id, c.created_by, c.created_at, c.updated_at, "
                        + "au.name AS assigned_user_name, cu.company_name AS team_name "
                        + "FROM customers c "
                        + "LEFT JOIN users au ON c.assigned_user_id = au.id "
                        + "LEFT JOIN users cu ON c.created_by = cu.id "
                        + "WHERE cu.company_name = ?"
        );

        List<Object> params = new ArrayList<>();
        params.add(companyName);

        String safeSearch = search == null ? "" : search.trim();
        String safeStatus = status == null ? "" : status.trim();
        String safeAssignedUser = assignedUser == null ? "" : assignedUser.trim();
        String safeSort = sort == null ? "" : sort.trim();

        if (!safeSearch.isEmpty()) {
            sql.append(" AND (c.name LIKE ? OR c.email LIKE ?)");
            params.add("%" + safeSearch + "%");
            params.add("%" + safeSearch + "%");
        }

        if (!safeStatus.isEmpty()) {
            sql.append(" AND c.status = ?");
            params.add(safeStatus);
        }

        if (!safeAssignedUser.isEmpty()) {
            sql.append(" AND c.assigned_user_id = ?");
            try {
                params.add(Integer.parseInt(safeAssignedUser));
            } catch (NumberFormatException e) {
                return customers;
            }
        }

        if ("name".equalsIgnoreCase(safeSort)) {
            sql.append(" ORDER BY c.name ASC");
        } else {
            sql.append(" ORDER BY c.updated_at DESC");
        }

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
                customers.add(mapCustomer(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return customers;
    }

    public Customer getCustomerByIdAndCompany(int customerId, String companyName) {
        String sql = "SELECT c.id, c.name, c.email, c.phone, c.company, c.status, c.assigned_user_id, c.created_by, c.created_at, c.updated_at, "
                + "au.name AS assigned_user_name, cu.company_name AS team_name "
                + "FROM customers c "
                + "LEFT JOIN users au ON c.assigned_user_id = au.id "
                + "LEFT JOIN users cu ON c.created_by = cu.id "
                + "WHERE c.id = ? AND cu.company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);
            pstmt.setString(2, companyName);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapCustomer(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean createCustomer(Customer customer) {
        String sql = "INSERT INTO customers (name, email, phone, company, status, assigned_user_id, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, customer.getName());
            pstmt.setString(2, customer.getEmail());
            pstmt.setString(3, customer.getPhone());
            pstmt.setString(4, customer.getCompany());
            pstmt.setString(5, customer.getStatus());
            pstmt.setInt(6, customer.getAssignedUserId());
            pstmt.setInt(7, customer.getCreatedBy());

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateCustomer(Customer customer, String companyName) {
        String sql = "UPDATE customers SET name = ?, email = ?, phone = ?, company = ?, status = ?, assigned_user_id = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE id = ? AND created_by IN (SELECT id FROM users WHERE company_name = ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, customer.getName());
            pstmt.setString(2, customer.getEmail());
            pstmt.setString(3, customer.getPhone());
            pstmt.setString(4, customer.getCompany());
            pstmt.setString(5, customer.getStatus());
            pstmt.setInt(6, customer.getAssignedUserId());
            pstmt.setInt(7, customer.getId());
            pstmt.setString(8, companyName);

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteCustomer(int customerId, String companyName) {
        String sql = "DELETE FROM customers WHERE id = ? AND created_by IN (SELECT id FROM users WHERE company_name = ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);
            pstmt.setString(2, companyName);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<User> getAssignedUsersByCompany(String companyName) {
        String sql = "SELECT id, name, email, role, company_name, is_first_login "
                + "FROM users "
                + "WHERE company_name = ? "
                + "ORDER BY name ASC";

        List<User> users = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                user.setCompanyName(rs.getString("company_name"));
                user.setFirstLogin(rs.getBoolean("is_first_login"));
                users.add(user);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

    public int countCustomersByCompany(String companyName) {
        String sql = "SELECT COUNT(*) FROM customers c JOIN users u ON c.created_by = u.id WHERE u.company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public Map<String, Integer> countByStatus(String companyName) {
        String sql = "SELECT c.status, COUNT(*) AS total "
                + "FROM customers c "
                + "JOIN users u ON c.created_by = u.id "
                + "WHERE u.company_name = ? "
                + "GROUP BY c.status";

        Map<String, Integer> counts = new HashMap<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                counts.put(rs.getString("status"), rs.getInt("total"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return counts;
    }

    public List<Map<String, Object>> getCustomerCountPerUser(String companyName) {
        String sql = "SELECT u.name AS user_name, COUNT(c.id) AS total "
                + "FROM users u "
                + "LEFT JOIN customers c ON c.assigned_user_id = u.id "
                + "AND c.created_by IN (SELECT id FROM users WHERE company_name = ?) "
                + "WHERE u.company_name = ? "
                + "GROUP BY u.id, u.name "
                + "ORDER BY u.name ASC";

        List<Map<String, Object>> results = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            pstmt.setString(2, companyName);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", rs.getString("user_name"));
                row.put("total", rs.getInt("total"));
                results.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    public int countCustomersByAssignedUser(int userId, String companyName) {
        String sql = "SELECT COUNT(*) FROM customers c "
                + "JOIN users u ON c.created_by = u.id "
                + "WHERE u.company_name = ? AND c.assigned_user_id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            pstmt.setInt(2, userId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    private Customer mapCustomer(ResultSet rs) throws SQLException {
        Customer c = new Customer();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setEmail(rs.getString("email"));
        c.setPhone(rs.getString("phone"));
        c.setCompany(rs.getString("company"));
        c.setStatus(rs.getString("status"));
        c.setAssignedUserId(rs.getInt("assigned_user_id"));
        c.setCreatedBy(rs.getInt("created_by"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));

        c.setAssignedUser(rs.getString("assigned_user_name"));
        c.setTeam(rs.getString("team_name"));
        if (c.getUpdatedAt() != null) {
            c.setLastActivityDate(c.getUpdatedAt().toLocalDateTime().toLocalDate().toString());
        }

        return c;
    }
}
