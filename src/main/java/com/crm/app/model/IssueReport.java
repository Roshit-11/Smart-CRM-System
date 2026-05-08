package com.crm.app.model;

import java.sql.Timestamp;

public class IssueReport {
    private int id;
    private int senderUserId;
    private String companyName;
    private String issueType;
    private String subject;
    private String description;
    private String status;
    private String priority;
    private String adminResponse;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Joined fields
    private String senderName;
    private String senderEmail;
    private String senderRole;

    public IssueReport() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getSenderUserId() { return senderUserId; }
    public void setSenderUserId(int senderUserId) { this.senderUserId = senderUserId; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getIssueType() { return issueType; }
    public void setIssueType(String issueType) { this.issueType = issueType; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getAdminResponse() { return adminResponse; }
    public void setAdminResponse(String adminResponse) { this.adminResponse = adminResponse; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderEmail() { return senderEmail; }
    public void setSenderEmail(String senderEmail) { this.senderEmail = senderEmail; }

    public String getSenderRole() { return senderRole; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }
}
