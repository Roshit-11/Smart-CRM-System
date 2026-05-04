package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.CompanySettings;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CompanySettingsDao {

    public CompanySettings getByCompany(String companyName) {
        String sql = "SELECT id, company_name, smtp_email, smtp_password, is_verified FROM company_settings WHERE company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                CompanySettings settings = new CompanySettings();
                settings.setId(rs.getInt("id"));
                settings.setCompanyName(rs.getString("company_name"));
                settings.setSmtpEmail(rs.getString("smtp_email"));
                settings.setSmtpPassword(rs.getString("smtp_password"));
                settings.setVerified(rs.getBoolean("is_verified"));
                return settings;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean saveOrUpdate(String companyName, String smtpEmail, String smtpPassword, boolean verified) {
        String sql = "INSERT INTO company_settings (company_name, smtp_email, smtp_password, is_verified) "
                + "VALUES (?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE smtp_email = VALUES(smtp_email), smtp_password = VALUES(smtp_password), is_verified = VALUES(is_verified)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            pstmt.setString(2, smtpEmail);
            pstmt.setString(3, smtpPassword);
            pstmt.setBoolean(4, verified);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean unlinkByCompany(String companyName) {
        String sql = "DELETE FROM company_settings WHERE company_name = ?";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
