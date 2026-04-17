package com.crm.app.controller;

import com.crm.app.dao.CustomerDao;
import com.crm.app.model.Customer;
import com.crm.app.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/customers")
public class CustomerController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final CustomerDao customerDao = new CustomerDao();

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

        String search = read(request.getParameter("search"));
        String status = read(request.getParameter("status"));
        String assignedUser = read(request.getParameter("assignedUser"));
        String sort = read(request.getParameter("sort"));

        List<Customer> filteredCustomers = customerDao.getCustomersByTeam(user.getId(), search, status, assignedUser, sort);
        List<Customer> allCustomers = customerDao.getCustomersByTeam(user.getId(), "", "", "", "recent");

        String customerIdParam = request.getParameter("customerId");
        Customer selectedCustomer = null;
        if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
            try {
                int customerId = Integer.parseInt(customerIdParam.trim());
                selectedCustomer = findById(filteredCustomers, customerId);
                if (selectedCustomer == null) {
                    selectedCustomer = customerDao.getCustomerByIdAndTeam(customerId, user.getId());
                }
            } catch (NumberFormatException ignored) {
                // Fallback below.
            }
        }

        if (selectedCustomer == null && !filteredCustomers.isEmpty()) {
            selectedCustomer = filteredCustomers.get(0);
        }

        String showAdd = read(request.getParameter("showAdd"));
        String editIdParam = read(request.getParameter("editId"));
        Customer editingCustomer = null;
        if (!editIdParam.isEmpty()) {
            try {
                int editId = Integer.parseInt(editIdParam);
                editingCustomer = customerDao.getCustomerByIdAndTeam(editId, user.getId());
                if (editingCustomer != null) {
                    showAdd = "1";
                }
            } catch (NumberFormatException ignored) {
                // ignore invalid edit id
            }
        }

        int totalCustomers = allCustomers.size();
        int leadCount = countByStatus(allCustomers, "Lead");
        int convertedCount = countByStatus(allCustomers, "Won");
        int lostCount = countByStatus(allCustomers, "Lost");
        List<User> assignedUsers = customerDao.getAssignedUsersByTeam(user.getId());

        request.setAttribute("currentUser", user);
        request.setAttribute("customers", filteredCustomers);
        request.setAttribute("selectedCustomer", selectedCustomer);
        request.setAttribute("assignedUsers", assignedUsers);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("assignedUser", assignedUser);
        request.setAttribute("sort", sort);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("leadCount", leadCount);
        request.setAttribute("convertedCount", convertedCount);
        request.setAttribute("lostCount", lostCount);
        request.setAttribute("showAdd", showAdd);
        request.setAttribute("editingCustomer", editingCustomer);

        request.getRequestDispatcher("/view/dashboard/customer.jsp").forward(request, response);
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

        String action = read(request.getParameter("action"));
        if ("createCustomer".equals(action)) {
            handleCreateCustomer(request, user);
        } else if ("updateCustomer".equals(action)) {
            handleUpdateCustomer(request, user);
        } else if ("deleteCustomer".equals(action)) {
            handleDeleteCustomer(request, user);
        } else if ("bulkUpdateStatus".equals(action)) {
            handleBulkUpdateStatus(request, user);
        } else if ("bulkDelete".equals(action)) {
            handleBulkDelete(request, user);
        } else if ("updateStatus".equals(action)) {
            handleUpdateStatus(request, user);
        }

        response.sendRedirect(request.getContextPath() + "/customers");
    }

    private void handleCreateCustomer(HttpServletRequest request, User user) {
        String name = read(request.getParameter("name"));
        String email = read(request.getParameter("email"));
        String phone = read(request.getParameter("phone"));
        String company = read(request.getParameter("company"));
        String status = read(request.getParameter("status"));
        String assignedUserIdParam = read(request.getParameter("assignedUserId"));

        if (name.isEmpty() || email.isEmpty() || phone.isEmpty() || assignedUserIdParam.isEmpty()) {
            return;
        }

        int assignedUserId;
        try {
            assignedUserId = Integer.parseInt(assignedUserIdParam);
        } catch (NumberFormatException e) {
            return;
        }

        Customer customer = new Customer();
        customer.setName(name);
        customer.setEmail(email);
        customer.setPhone(phone);
        customer.setCompany(company);
        customer.setStatus(status.isEmpty() ? "Lead" : status);
        customer.setAssignedUserId(assignedUserId);
        customer.setCreatedBy(user.getId());

        customerDao.createCustomer(customer);
    }

    private void handleUpdateCustomer(HttpServletRequest request, User user) {
        String customerIdParam = read(request.getParameter("customerId"));
        if (customerIdParam.isEmpty()) {
            return;
        }

        int customerId;
        try {
            customerId = Integer.parseInt(customerIdParam);
        } catch (NumberFormatException e) {
            return;
        }

        Customer existing = customerDao.getCustomerByIdAndTeam(customerId, user.getId());
        if (existing == null) {
            return;
        }

        String name = read(request.getParameter("name"));
        String email = read(request.getParameter("email"));
        String phone = read(request.getParameter("phone"));
        String company = read(request.getParameter("company"));
        String status = read(request.getParameter("status"));
        String assignedUserIdParam = read(request.getParameter("assignedUserId"));

        if (name.isEmpty() || email.isEmpty() || phone.isEmpty() || assignedUserIdParam.isEmpty()) {
            return;
        }

        int assignedUserId;
        try {
            assignedUserId = Integer.parseInt(assignedUserIdParam);
        } catch (NumberFormatException e) {
            return;
        }

        existing.setName(name);
        existing.setEmail(email);
        existing.setPhone(phone);
        existing.setCompany(company);
        existing.setStatus(status.isEmpty() ? existing.getStatus() : status);
        existing.setAssignedUserId(assignedUserId);
        existing.setCreatedBy(user.getId());

        customerDao.updateCustomer(existing);
    }

    private void handleDeleteCustomer(HttpServletRequest request, User user) {
        String customerIdParam = read(request.getParameter("customerId"));
        if (customerIdParam.isEmpty()) {
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdParam);
            customerDao.deleteCustomer(customerId, user.getId());
        } catch (NumberFormatException ignored) {
            // ignore invalid id
        }
    }

    private void handleBulkUpdateStatus(HttpServletRequest request, User user) {
        String[] selectedIds = request.getParameterValues("selectedCustomerIds");
        String status = read(request.getParameter("bulkStatus"));
        if (selectedIds == null || selectedIds.length == 0 || status.isEmpty()) {
            return;
        }

        for (String idValue : selectedIds) {
            try {
                int customerId = Integer.parseInt(idValue);
                Customer customer = customerDao.getCustomerByIdAndTeam(customerId, user.getId());
                if (customer != null) {
                    customer.setStatus(status);
                    customer.setCreatedBy(user.getId());
                    customerDao.updateCustomer(customer);
                }
            } catch (NumberFormatException ignored) {
                // skip invalid id
            }
        }
    }

    private void handleBulkDelete(HttpServletRequest request, User user) {
        String[] selectedIds = request.getParameterValues("selectedCustomerIds");
        if (selectedIds == null || selectedIds.length == 0) {
            return;
        }

        for (String idValue : selectedIds) {
            try {
                int customerId = Integer.parseInt(idValue);
                customerDao.deleteCustomer(customerId, user.getId());
            } catch (NumberFormatException ignored) {
                // skip invalid id
            }
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, User user) {
        String customerIdParam = read(request.getParameter("customerId"));
        String nextStatus = read(request.getParameter("status"));
        if (customerIdParam.isEmpty() || nextStatus.isEmpty()) {
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdParam);
            Customer customer = customerDao.getCustomerByIdAndTeam(customerId, user.getId());
            if (customer != null) {
                customer.setStatus(nextStatus);
                customer.setCreatedBy(user.getId());
                customerDao.updateCustomer(customer);
            }
        } catch (NumberFormatException ignored) {
            // ignore invalid id
        }
    }

    private Customer findById(List<Customer> customers, int customerId) {
        for (Customer customer : customers) {
            if (customer.getId() == customerId) {
                return customer;
            }
        }
        return null;
    }

    private int countByStatus(List<Customer> customers, String status) {
        int count = 0;
        for (Customer customer : customers) {
            if (status.equalsIgnoreCase(customer.getStatus())) {
                count++;
            }
        }
        return count;
    }

    private String read(String value) {
        return value == null ? "" : value.trim();
    }
}
