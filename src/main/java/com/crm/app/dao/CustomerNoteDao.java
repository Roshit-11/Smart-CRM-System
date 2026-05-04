package com.crm.app.dao;

import com.crm.app.config.DBConfig;
import com.crm.app.model.CustomerNote;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CustomerNoteDao {

    public boolean addNote(int customerId, String note, int userId) {
        String sql = "INSERT INTO customer_notes (customer_id, user_id, note) VALUES (?, ?, ?)";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);
            pstmt.setInt(2, userId);
            pstmt.setString(3, note);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<CustomerNote> getNotesByCustomer(int customerId, String companyName) {
        String sql = "SELECT n.id, n.customer_id, n.user_id, n.note, n.created_at, u.name AS user_name "
                + "FROM customer_notes n "
                + "JOIN customers c ON n.customer_id = c.id "
                + "JOIN users cu ON c.created_by = cu.id "
                + "JOIN users u ON n.user_id = u.id "
                + "WHERE n.customer_id = ? AND cu.company_name = ? "
                + "ORDER BY n.created_at DESC";

        List<CustomerNote> notes = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, customerId);
            pstmt.setString(2, companyName);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                CustomerNote note = new CustomerNote();
                note.setId(rs.getInt("id"));
                note.setCustomerId(rs.getInt("customer_id"));
                note.setUserId(rs.getInt("user_id"));
                note.setNote(rs.getString("note"));
                note.setCreatedAt(rs.getTimestamp("created_at"));
                note.setUserName(rs.getString("user_name"));
                notes.add(note);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return notes;
    }
}
