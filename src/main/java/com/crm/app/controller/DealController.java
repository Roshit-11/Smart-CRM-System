package com.crm.app.controller;

import com.crm.app.dao.ActivityLogDao;
import com.crm.app.dao.CustomerDao;
import com.crm.app.dao.DealDao;
import com.crm.app.dao.UserDao;
import com.crm.app.model.ActivityLog;
import com.crm.app.model.Customer;
import com.crm.app.model.Deal;
import com.crm.app.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/deals")
public class DealController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final DealDao dealDao = new DealDao();
    private final CustomerDao customerDao = new CustomerDao();
    private final UserDao userDao = new UserDao();
    private final ActivityLogDao activityLogDao = new ActivityLogDao();

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
        if (companyName == null || companyName.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
        String search = read(request.getParameter("search"));
        String stage = read(request.getParameter("stage"));
        String assignedUserParam = read(request.getParameter("assignedUser"));

        Integer assignedUserFilter = null;
        if (!isAdmin) {
            assignedUserFilter = user.getId();
        } else if (!assignedUserParam.isEmpty()) {
            try {
                assignedUserFilter = Integer.parseInt(assignedUserParam);
            } catch (NumberFormatException ignored) {
                assignedUserFilter = null;
            }
        }

        List<Deal> deals = dealDao.getDealsByCompany(companyName, search, stage, assignedUserFilter);
        List<User> assignedUsers = userDao.getUsersByCompany(companyName);
        List<Customer> customers = customerDao.getCustomersByCompany(companyName, "", "", "", "name");

        String showAdd = read(request.getParameter("showAdd"));
        String editIdParam = read(request.getParameter("editId"));
        Deal editingDeal = null;
        if (!editIdParam.isEmpty()) {
            try {
                int editId = Integer.parseInt(editIdParam);
                List<Deal> allDeals = dealDao.getDealsByCompany(companyName, "", "", assignedUserFilter);
                editingDeal = findById(allDeals, editId);
                if (editingDeal != null) {
                    showAdd = "1";
                }
            } catch (NumberFormatException ignored) {
                // ignore invalid edit id
            }
        }

        int totalDeals = deals.size();
        int wonCount = countByStage(deals, "Closed Won");
        int lostCount = countByStage(deals, "Closed Lost");
        int activeCount = totalDeals - wonCount - lostCount;

        request.setAttribute("activeNav", "deals");
        request.setAttribute("topSearchPlaceholder", "Search deals...");
        request.setAttribute("currentUser", user);
        request.setAttribute("deals", deals);
        request.setAttribute("assignedUsers", assignedUsers);
        request.setAttribute("customers", customers);
        request.setAttribute("search", search);
        request.setAttribute("stage", stage);
        request.setAttribute("assignedUser", assignedUserParam);
        request.setAttribute("showAdd", showAdd);
        request.setAttribute("editingDeal", editingDeal);
        request.setAttribute("totalDeals", totalDeals);
        request.setAttribute("activeDeals", activeCount);
        request.setAttribute("wonDeals", wonCount);
        request.setAttribute("lostDeals", lostCount);

        request.getRequestDispatcher("/view/dashboard/deals.jsp").forward(request, response);
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

        if (user.isFirstLogin()) {
            response.sendRedirect(request.getContextPath() + "/change-password");
            return;
        }

        String companyName = resolveCompanyName(session, user);
        if (companyName == null || companyName.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
        String action = read(request.getParameter("action"));

        if ("createDeal".equals(action)) {
            handleCreateDeal(request, user, companyName, isAdmin);
        } else if ("updateDeal".equals(action)) {
            handleUpdateDeal(request, user, companyName, isAdmin);
        } else if ("updateStage".equals(action)) {
            handleUpdateStage(request, user, companyName, isAdmin);
        } else if ("deleteDeal".equals(action)) {
            handleDeleteDeal(request, user, companyName, isAdmin);
        }

        response.sendRedirect(request.getContextPath() + "/deals");
    }

    private void handleCreateDeal(HttpServletRequest request, User user, String companyName, boolean isAdmin) {
        String title = read(request.getParameter("title"));
        String valueParam = read(request.getParameter("value"));
        String stage = read(request.getParameter("stage"));
        String customerIdParam = read(request.getParameter("customerId"));
        String assignedUserIdParam = read(request.getParameter("assignedUserId"));

        if (title.isEmpty() || valueParam.isEmpty() || customerIdParam.isEmpty()) {
            return;
        }

        int customerId;
        try {
            customerId = Integer.parseInt(customerIdParam);
        } catch (NumberFormatException e) {
            return;
        }

        BigDecimal value;
        try {
            value = new BigDecimal(valueParam);
        } catch (NumberFormatException e) {
            return;
        }

        Integer assignedUserId = null;
        if (isAdmin) {
            if (!assignedUserIdParam.isEmpty()) {
                try {
                    assignedUserId = Integer.parseInt(assignedUserIdParam);
                } catch (NumberFormatException ignored) {
                    assignedUserId = null;
                }
            }
        } else {
            assignedUserId = user.getId();
        }

        Deal deal = new Deal();
        deal.setCustomerId(customerId);
        deal.setTitle(title);
        deal.setValue(value);
        deal.setStage(stage.isEmpty() ? "Prospect" : stage);
        deal.setAssignedUserId(assignedUserId);
        deal.setCreatedBy(user.getId());

        if (dealDao.createDeal(deal)) {
            logActivity(companyName, customerId, user.getId(), "DEAL_CREATED", "Created deal: " + title);
        }
    }

    private void handleUpdateDeal(HttpServletRequest request, User user, String companyName, boolean isAdmin) {
        String dealIdParam = read(request.getParameter("dealId"));
        String title = read(request.getParameter("title"));
        String valueParam = read(request.getParameter("value"));
        String stage = read(request.getParameter("stage"));
        String customerIdParam = read(request.getParameter("customerId"));
        String assignedUserIdParam = read(request.getParameter("assignedUserId"));

        if (dealIdParam.isEmpty() || title.isEmpty() || valueParam.isEmpty() || customerIdParam.isEmpty()) {
            return;
        }

        int dealId;
        int customerId;
        try {
            dealId = Integer.parseInt(dealIdParam);
            customerId = Integer.parseInt(customerIdParam);
        } catch (NumberFormatException e) {
            return;
        }

        BigDecimal value;
        try {
            value = new BigDecimal(valueParam);
        } catch (NumberFormatException e) {
            return;
        }

        Integer assignedUserId = null;
        if (isAdmin) {
            if (!assignedUserIdParam.isEmpty()) {
                try {
                    assignedUserId = Integer.parseInt(assignedUserIdParam);
                } catch (NumberFormatException ignored) {
                    assignedUserId = null;
                }
            }
        } else {
            assignedUserId = user.getId();
        }

        Deal deal = new Deal();
        deal.setId(dealId);
        deal.setCustomerId(customerId);
        deal.setTitle(title);
        deal.setValue(value);
        deal.setStage(stage.isEmpty() ? "Prospect" : stage);
        deal.setAssignedUserId(assignedUserId);

        Integer filter = isAdmin ? null : user.getId();
        if (dealDao.updateDeal(deal, companyName, filter)) {
            logActivity(companyName, customerId, user.getId(), "DEAL_UPDATED", "Updated deal: " + title);
        }
    }

    private void handleUpdateStage(HttpServletRequest request, User user, String companyName, boolean isAdmin) {
        String dealIdParam = read(request.getParameter("dealId"));
        String stage = read(request.getParameter("stage"));
        String customerIdParam = read(request.getParameter("customerId"));

        if (dealIdParam.isEmpty() || stage.isEmpty()) {
            return;
        }

        int dealId;
        int customerId = 0;
        try {
            dealId = Integer.parseInt(dealIdParam);
            if (!customerIdParam.isEmpty()) {
                customerId = Integer.parseInt(customerIdParam);
            }
        } catch (NumberFormatException e) {
            return;
        }

        Integer filter = isAdmin ? null : user.getId();
        if (dealDao.updateDealStage(dealId, stage, companyName, filter)) {
            logActivity(companyName, customerId, user.getId(), "DEAL_STAGE_CHANGED", "Stage changed to " + stage);
        }
    }

    private void handleDeleteDeal(HttpServletRequest request, User user, String companyName, boolean isAdmin) {
        String dealIdParam = read(request.getParameter("dealId"));
        String customerIdParam = read(request.getParameter("customerId"));
        if (dealIdParam.isEmpty()) {
            return;
        }

        int dealId;
        int customerId = 0;
        try {
            dealId = Integer.parseInt(dealIdParam);
            if (!customerIdParam.isEmpty()) {
                customerId = Integer.parseInt(customerIdParam);
            }
        } catch (NumberFormatException e) {
            return;
        }

        Integer filter = isAdmin ? null : user.getId();
        if (dealDao.deleteDeal(dealId, companyName, filter)) {
            logActivity(companyName, customerId, user.getId(), "DEAL_DELETED", "Deal deleted");
        }
    }

    private void logActivity(String companyName, int customerId, int userId, String action, String details) {
        ActivityLog log = new ActivityLog();
        log.setCompanyName(companyName);
        log.setCustomerId(customerId);
        log.setUserId(userId);
        log.setAction(action);
        log.setDetails(details);
        activityLogDao.logActivity(log);
    }

    private Deal findById(List<Deal> deals, int dealId) {
        for (Deal deal : deals) {
            if (deal.getId() == dealId) {
                return deal;
            }
        }
        return null;
    }

    private int countByStage(List<Deal> deals, String stage) {
        int count = 0;
        for (Deal deal : deals) {
            if (stage.equalsIgnoreCase(deal.getStage())) {
                count++;
            }
        }
        return count;
    }

    private String read(String value) {
        return value == null ? "" : value.trim();
    }

    private String resolveCompanyName(HttpSession session, User user) {
        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = user.getCompanyName();
            session.setAttribute("companyName", companyName);
        }
        return companyName;
    }
}
