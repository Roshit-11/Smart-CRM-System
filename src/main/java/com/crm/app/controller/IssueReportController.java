package com.crm.app.controller;

import com.crm.app.dao.IssueReportDao;
import com.crm.app.dao.UserDao;
import com.crm.app.model.IssueReport;
import com.crm.app.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/contact-admin")
public class IssueReportController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final IssueReportDao issueDao = new IssueReportDao();
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.isFirstLogin()) {
            response.sendRedirect(request.getContextPath() + "/change-password");
            return;
        }

        String companyName = resolveCompanyName(session, user);
        boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());

        if (isAdmin) {
            String filterType = read(request.getParameter("type"));
            String filterStatus = read(request.getParameter("status"));
            List<IssueReport> issues = issueDao.getIssuesByCompany(companyName, filterType, filterStatus);
            Map<String, Integer> statusCounts = issueDao.countByStatus(companyName);
            int totalIssues = issueDao.countByCompany(companyName);

            request.setAttribute("issues", issues);
            request.setAttribute("statusCounts", statusCounts);
            request.setAttribute("totalIssues", totalIssues);
            request.setAttribute("filterType", filterType);
            request.setAttribute("filterStatus", filterStatus);
            request.getRequestDispatcher("/view/dashboard/admin-issues.jsp").forward(request, response);
        } else {
            List<IssueReport> myIssues = issueDao.getIssuesByUser(user.getId());
            request.setAttribute("myIssues", myIssues);
            request.getRequestDispatcher("/view/dashboard/contact-admin.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String companyName = resolveCompanyName(session, user);
        String action = read(request.getParameter("action"));

        if ("createIssue".equals(action)) {
            handleCreateIssue(request, user, companyName, session);
        } else if ("updateIssueStatus".equals(action)) {
            handleUpdateStatus(request, user, companyName, session);
        } else if ("deleteIssue".equals(action)) {
            handleDeleteIssue(request, user, session);
        }

        response.sendRedirect(request.getContextPath() + "/contact-admin");
    }

    private void handleCreateIssue(HttpServletRequest request, User user, String companyName, HttpSession session) {
        String issueType = read(request.getParameter("issueType"));
        String subject = read(request.getParameter("subject"));
        String description = read(request.getParameter("description"));
        String priority = read(request.getParameter("priority"));

        if (issueType.isEmpty() || subject.isEmpty() || description.isEmpty()) {
            session.setAttribute("issueFormError", "Please fill in all required fields.");
            return;
        }

        IssueReport issue = new IssueReport();
        issue.setSenderUserId(user.getId());
        issue.setCompanyName(companyName);
        issue.setIssueType(issueType);
        issue.setSubject(subject);
        issue.setDescription(description);
        issue.setStatus("Open");
        issue.setPriority(priority.isEmpty() ? "Medium" : priority);

        if (issueDao.createIssue(issue)) {
            session.setAttribute("issueFormSuccess", "Your issue has been submitted. Admin will respond soon.");
        } else {
            session.setAttribute("issueFormError", "Failed to submit issue. Please try again.");
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, User user, String companyName, HttpSession session) {
        if (!"admin".equalsIgnoreCase(user.getRole())) return;

        String idParam = read(request.getParameter("issueId"));
        String status = read(request.getParameter("status"));
        String adminResponse = read(request.getParameter("adminResponse"));
        if (idParam.isEmpty() || status.isEmpty()) return;

        try {
            int id = Integer.parseInt(idParam);
            if (issueDao.updateStatus(id, status, adminResponse, companyName)) {
                session.setAttribute("issueFormSuccess", "Issue updated successfully.");
            }
        } catch (NumberFormatException ignored) {}
    }

    private void handleDeleteIssue(HttpServletRequest request, User user, HttpSession session) {
        String idParam = read(request.getParameter("issueId"));
        if (idParam.isEmpty()) return;
        try {
            int id = Integer.parseInt(idParam);
            if (issueDao.deleteIssue(id, user.getId())) {
                session.setAttribute("issueFormSuccess", "Issue deleted.");
            }
        } catch (NumberFormatException ignored) {}
    }

    private String resolveCompanyName(HttpSession session, User user) {
        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = user.getCompanyName();
            if (companyName != null && !companyName.trim().isEmpty()) {
                session.setAttribute("companyName", companyName);
            }
        }
        return companyName == null ? "" : companyName;
    }

    private String read(String value) {
        return value == null ? "" : value.trim();
    }
}
