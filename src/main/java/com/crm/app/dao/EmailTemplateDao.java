package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.EmailTemplate;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class EmailTemplateDao {

    public boolean createTemplate(EmailTemplate template) {
        String sql = "INSERT INTO email_templates (company_name, template_name, subject, body, created_by) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, template.getCompanyName());
            pstmt.setString(2, template.getTemplateName());
            pstmt.setString(3, template.getSubject());
            pstmt.setString(4, template.getBody());
            pstmt.setInt(5, template.getCreatedBy());
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<EmailTemplate> getTemplatesByCompany(String companyName) {
        String sql = "SELECT id, company_name, template_name, subject, body, created_by, created_at "
                + "FROM email_templates WHERE company_name = ? ORDER BY created_at DESC";

        List<EmailTemplate> templates = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, companyName);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                EmailTemplate template = new EmailTemplate();
                template.setId(rs.getInt("id"));
                template.setCompanyName(rs.getString("company_name"));
                template.setTemplateName(rs.getString("template_name"));
                template.setSubject(rs.getString("subject"));
                template.setBody(rs.getString("body"));
                template.setCreatedBy(rs.getInt("created_by"));
                template.setCreatedAt(rs.getTimestamp("created_at"));
                templates.add(template);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return templates;
    }
}
