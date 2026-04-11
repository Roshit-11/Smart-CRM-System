package com.crm.app.dao;

import com.crm.app.model.User;
import com.crm.app.config.DBConfig;
import com.crm.app.config.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    /**
     * Register a new user in the database
     */
    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (name, email, password, role, company_name, status, is_first_login) VALUES (?, ?, ?, ?, ?, 'active', ?)";
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getName());
            pstmt.setString(2, user.getEmail());
            // Hash the password using SHA-256
            String hashedPassword = PasswordUtil.hashPassword(user.getPassword());
            pstmt.setString(3, hashedPassword);
            pstmt.setString(4, user.getRole() != null ? user.getRole() : "user");
            pstmt.setString(5, user.getCompanyName());
            pstmt.setBoolean(6, user.isFirstLogin());
            
            int rowsInserted = pstmt.executeUpdate();
            return rowsInserted > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validate user credentials (login)
     */
    public User validateUser(String email, String password) {
        String sql = "SELECT id, name, email, password, role, company_name, is_first_login FROM users WHERE email = ? AND status = 'active'";
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String storedHashedPassword = rs.getString("password");
                
                // Hash the input password and compare with stored hash
                if (PasswordUtil.verifyPassword(password, storedHashedPassword)) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setCompanyName(rs.getString("company_name"));
                    user.setFirstLogin(rs.getBoolean("is_first_login"));
                    return user;
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null; // Invalid credentials
    }

    /**
     * Create a user by admin within the same company
     */
    public boolean createUserByAdmin(String name, String email, String hashedPassword, String companyName) {
        String sql = "INSERT INTO users (name, email, password, role, company_name, status, is_first_login) VALUES (?, ?, ?, 'user', ?, 'active', true)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setString(3, hashedPassword);
            pstmt.setString(4, companyName);

            int rowsInserted = pstmt.executeUpdate();
            return rowsInserted > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePasswordAndClearFirstLogin(int userId, String hashedPassword) {
        String sql = "UPDATE users SET password = ?, is_first_login = false WHERE id = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, hashedPassword);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<User> getUsersByCompany(String companyName) {
        String sql = "SELECT id, name, email, role, company_name, is_first_login FROM users WHERE company_name = ? ORDER BY role DESC, name ASC";
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

    public boolean updateUserNameByIdAndCompany(int userId, String name, String companyName) {
        String sql = "UPDATE users SET name = ? WHERE id = ? AND company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, name);
            pstmt.setInt(2, userId);
            pstmt.setString(3, companyName);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteUserByIdAndCompany(int userId, String companyName) {
        String sql = "DELETE FROM users WHERE id = ? AND company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setString(2, companyName);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
