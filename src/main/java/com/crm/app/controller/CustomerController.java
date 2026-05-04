package com.crm.app.controller;

import com.crm.app.dao.ActivityLogDao;
import com.crm.app.dao.CustomerDao;
import com.crm.app.dao.CustomerNoteDao;
import com.crm.app.dao.NotificationDao;
import com.crm.app.dao.TaskDao;
import com.crm.app.dao.UserDao;
import com.crm.app.dao.CompanySettingsDao;
import com.crm.app.dao.EmailTemplateDao;
import com.crm.app.model.ActivityLog;
import com.crm.app.model.Customer;
import com.crm.app.model.CustomerNote;
import com.crm.app.model.Task;
import com.crm.app.model.User;
import com.crm.app.model.CompanySettings;
import com.crm.app.model.EmailTemplate;
import com.crm.app.service.EmailService;
import com.crm.app.util.TemplateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet("/customers")
public class CustomerController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final CustomerDao customerDao = new CustomerDao();
    private final CustomerNoteDao customerNoteDao = new CustomerNoteDao();
    private final TaskDao taskDao = new TaskDao();
    private final ActivityLogDao activityLogDao = new ActivityLogDao();
    private final NotificationDao notificationDao = new NotificationDao();
    private final UserDao userDao = new UserDao();
    private final CompanySettingsDao companySettingsDao = new CompanySettingsDao();
    private final EmailTemplateDao emailTemplateDao = new EmailTemplateDao();
    private final EmailService emailService = new EmailService();

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

        String search = read(request.getParameter("search"));
        String status = read(request.getParameter("status"));
        String assignedUser = read(request.getParameter("assignedUser"));
        String sort = read(request.getParameter("sort"));

        List<Customer> filteredCustomers = customerDao.getCustomersByCompany(companyName, search, status, assignedUser, sort);
        List<Customer> allCustomers = customerDao.getCustomersByCompany(companyName, "", "", "", "recent");

        String customerIdParam = request.getParameter("customerId");
        Customer selectedCustomer = null;
        if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
            try {
                int customerId = Integer.parseInt(customerIdParam.trim());
                selectedCustomer = findById(filteredCustomers, customerId);
                if (selectedCustomer == null) {
                    selectedCustomer = customerDao.getCustomerByIdAndCompany(customerId, companyName);
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
                editingCustomer = customerDao.getCustomerByIdAndCompany(editId, companyName);
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
        List<User> assignedUsers = customerDao.getAssignedUsersByCompany(companyName);

        if (selectedCustomer != null) {
            List<CustomerNote> notes = customerNoteDao.getNotesByCustomer(selectedCustomer.getId(), companyName);
            List<Task> tasks = taskDao.getTasksByCustomer(selectedCustomer.getId(), companyName);
            List<ActivityLog> activityLogs = activityLogDao.getLogsByCustomer(selectedCustomer.getId(), companyName);
            request.setAttribute("notes", notes);
            request.setAttribute("tasks", tasks);
            request.setAttribute("activityLogs", activityLogs);
        }

        List<EmailTemplate> templates = emailTemplateDao.getTemplatesByCompany(companyName);
        request.setAttribute("emailTemplates", templates);
        CompanySettings settings = companySettingsDao.getByCompany(companyName);
        request.setAttribute("companyEmailSettings", settings);

        String bulkError = (String) session.getAttribute("bulkEmailError");
        String bulkSuccess = (String) session.getAttribute("bulkEmailSuccess");
        if (bulkError != null) {
            request.setAttribute("bulkEmailError", bulkError);
            session.removeAttribute("bulkEmailError");
        }
        if (bulkSuccess != null) {
            request.setAttribute("bulkEmailSuccess", bulkSuccess);
            session.removeAttribute("bulkEmailSuccess");
        }

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

        String companyName = resolveCompanyName(session, user);
        if (companyName == null || companyName.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = read(request.getParameter("action"));
        if ("createCustomer".equals(action)) {
            handleCreateCustomer(request, user, companyName);
        } else if ("updateCustomer".equals(action)) {
            handleUpdateCustomer(request, user, companyName);
        } else if ("deleteCustomer".equals(action)) {
            handleDeleteCustomer(request, user, companyName);
        } else if ("bulkUpdateStatus".equals(action)) {
            handleBulkUpdateStatus(request, user, companyName);
        } else if ("bulkDelete".equals(action)) {
            handleBulkDelete(request, user, companyName);
        } else if ("updateStatus".equals(action)) {
            handleUpdateStatus(request, user, companyName);
        } else if ("addNote".equals(action)) {
            handleAddNote(request, user, companyName);
        } else if ("createTask".equals(action)) {
            handleCreateTask(request, user, companyName);
        } else if ("updateTaskStatus".equals(action)) {
            handleUpdateTaskStatus(request, user, companyName);
        } else if ("updateTask".equals(action)) {
            handleUpdateTask(request, user, companyName);
        } else if ("deleteTask".equals(action)) {
            handleDeleteTask(request, user, companyName);
        } else if ("sendBulkEmail".equals(action)) {
            handleSendBulkEmail(request, user, companyName, session);
        } else if ("saveTemplate".equals(action)) {
            handleSaveTemplate(request, user, companyName, session);
        }

        response.sendRedirect(request.getContextPath() + "/customers");
    }

    private void handleCreateCustomer(HttpServletRequest request, User user, String companyName) {
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

        if (customerDao.createCustomer(customer)) {
            Customer created = customerDao.getCustomersByCompany(companyName, name, "", "", "recent")
                    .stream()
                    .filter(c -> name.equalsIgnoreCase(c.getName()))
                    .findFirst()
                    .orElse(null);
            if (created != null) {
                logActivity(companyName, created.getId(), user.getId(), "CUSTOMER_CREATED", "Created customer: " + name);

                if (assignedUserId > 0) {
                    User assignedUser = userDao.getNotificationSettingsById(assignedUserId);
                    if (assignedUser != null && assignedUser.isNotifyCustomerAssign()) {
                        notificationDao.createNotification(
                                assignedUserId,
                                "You have been assigned a new customer: " + created.getName(),
                                "CUSTOMER_ASSIGN",
                                "customer",
                                created.getId()
                        );
                    }
                }
            }
        }
    }

    private void handleUpdateCustomer(HttpServletRequest request, User user, String companyName) {
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

        Customer existing = customerDao.getCustomerByIdAndCompany(customerId, companyName);
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

        if (customerDao.updateCustomer(existing, companyName)) {
            logActivity(companyName, existing.getId(), user.getId(), "CUSTOMER_UPDATED", "Updated customer: " + name);
        }
    }

    private void handleDeleteCustomer(HttpServletRequest request, User user, String companyName) {
        String customerIdParam = read(request.getParameter("customerId"));
        if (customerIdParam.isEmpty()) {
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdParam);
            Customer existing = customerDao.getCustomerByIdAndCompany(customerId, companyName);
            if (existing != null && customerDao.deleteCustomer(customerId, companyName)) {
                logActivity(companyName, customerId, user.getId(), "CUSTOMER_DELETED", "Deleted customer: " + existing.getName());
            }
        } catch (NumberFormatException ignored) {
            // ignore invalid id
        }
    }

    private void handleBulkUpdateStatus(HttpServletRequest request, User user, String companyName) {
        String[] selectedIds = request.getParameterValues("selectedCustomerIds");
        String status = read(request.getParameter("bulkStatus"));
        if (selectedIds == null || selectedIds.length == 0 || status.isEmpty()) {
            return;
        }

        for (String idValue : selectedIds) {
            try {
                int customerId = Integer.parseInt(idValue);
                Customer customer = customerDao.getCustomerByIdAndCompany(customerId, companyName);
                if (customer != null) {
                    customer.setStatus(status);
                    customer.setCreatedBy(user.getId());
                    if (customerDao.updateCustomer(customer, companyName)) {
                        logActivity(companyName, customerId, user.getId(), "STATUS_CHANGED", "Status changed to " + status);
                    }
                }
            } catch (NumberFormatException ignored) {
                // skip invalid id
            }
        }
    }

    private void handleBulkDelete(HttpServletRequest request, User user, String companyName) {
        String[] selectedIds = request.getParameterValues("selectedCustomerIds");
        if (selectedIds == null || selectedIds.length == 0) {
            return;
        }

        for (String idValue : selectedIds) {
            try {
                int customerId = Integer.parseInt(idValue);
                Customer existing = customerDao.getCustomerByIdAndCompany(customerId, companyName);
                if (existing != null && customerDao.deleteCustomer(customerId, companyName)) {
                    logActivity(companyName, customerId, user.getId(), "CUSTOMER_DELETED", "Deleted customer: " + existing.getName());
                }
            } catch (NumberFormatException ignored) {
                // skip invalid id
            }
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, User user, String companyName) {
        String customerIdParam = read(request.getParameter("customerId"));
        String nextStatus = read(request.getParameter("status"));
        if (customerIdParam.isEmpty() || nextStatus.isEmpty()) {
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdParam);
            Customer customer = customerDao.getCustomerByIdAndCompany(customerId, companyName);
            if (customer != null) {
                customer.setStatus(nextStatus);
                customer.setCreatedBy(user.getId());
                if (customerDao.updateCustomer(customer, companyName)) {
                    logActivity(companyName, customerId, user.getId(), "STATUS_CHANGED", "Status changed to " + nextStatus);
                }
            }
        } catch (NumberFormatException ignored) {
            // ignore invalid id
        }
    }

    private void handleAddNote(HttpServletRequest request, User user, String companyName) {
        String customerIdParam = read(request.getParameter("customerId"));
        String note = read(request.getParameter("note"));
        if (customerIdParam.isEmpty() || note.isEmpty()) {
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdParam);
            Customer customer = customerDao.getCustomerByIdAndCompany(customerId, companyName);
            if (customer == null) {
                return;
            }
            if (customerNoteDao.addNote(customerId, note, user.getId())) {
                logActivity(companyName, customerId, user.getId(), "NOTE_ADDED", "Note added");
            }
        } catch (NumberFormatException ignored) {
            // ignore invalid id
        }
    }

    private void handleCreateTask(HttpServletRequest request, User user, String companyName) {
        String customerIdParam = read(request.getParameter("customerId"));
        String title = read(request.getParameter("taskTitle"));
        String dueDateParam = read(request.getParameter("dueDate"));
        String assignedUserIdParam = read(request.getParameter("taskAssignedUserId"));

        if (customerIdParam.isEmpty() || title.isEmpty() || dueDateParam.isEmpty() || assignedUserIdParam.isEmpty()) {
            return;
        }

        try {
            int customerId = Integer.parseInt(customerIdParam);
            int assignedUserId = Integer.parseInt(assignedUserIdParam);
            Customer customer = customerDao.getCustomerByIdAndCompany(customerId, companyName);
            if (customer == null) {
                return;
            }

            Task task = new Task();
            task.setCustomerId(customerId);
            task.setTitle(title);
            task.setDueDate(Date.valueOf(dueDateParam));
            task.setStatus("Pending");
            task.setAssignedUserId(assignedUserId);
            task.setCreatedBy(user.getId());

            if (taskDao.createTask(task)) {
                logActivity(companyName, customerId, user.getId(), "TASK_CREATED", "Task created: " + title);

                if (assignedUserId > 0 && task.getId() > 0) {
                    User assignedUser = userDao.getNotificationSettingsById(assignedUserId);
                    if (assignedUser != null && assignedUser.isNotifyTaskAssign()) {
                        notificationDao.createNotification(
                                assignedUserId,
                                "New task assigned: " + task.getTitle(),
                                "TASK_ASSIGN",
                                "task",
                                task.getId()
                        );
                    }
                }
            }
        } catch (IllegalArgumentException ignored) {
            // ignore invalid inputs
        }
    }

    private void handleUpdateTaskStatus(HttpServletRequest request, User user, String companyName) {
        String taskIdParam = read(request.getParameter("taskId"));
        String customerIdParam = read(request.getParameter("customerId"));
        String status = read(request.getParameter("taskStatus"));
        if (taskIdParam.isEmpty() || customerIdParam.isEmpty() || status.isEmpty()) {
            return;
        }

        if (!isAllowedTaskStatus(status)) {
            return;
        }

        try {
            int taskId = Integer.parseInt(taskIdParam);
            int customerId = Integer.parseInt(customerIdParam);

            Task existingTask = taskDao.getTaskByIdAndCompany(taskId, companyName);
            if (existingTask == null) {
                return;
            }

            if (existingTask.getAssignedUserId() != user.getId()) {
                return;
            }

            if (taskDao.updateTaskStatus(taskId, status, companyName)) {
                logActivity(companyName, customerId, user.getId(), "TASK_UPDATED", "Task status updated to " + status);
                if (existingTask.getCreatedBy() > 0 && existingTask.getCreatedBy() != user.getId()) {
                    User taskCreator = userDao.getNotificationSettingsById(existingTask.getCreatedBy());
                    if (taskCreator != null && taskCreator.isNotifyTaskUpdate()) {
                        notificationDao.createNotification(
                                existingTask.getCreatedBy(),
                                "Task updated: " + existingTask.getTitle() + " is now " + status,
                                "TASK_UPDATE",
                                "task",
                                taskId
                        );
                    }
                }
            }
        } catch (NumberFormatException ignored) {
            // ignore invalid id
        }
    }

    private void handleUpdateTask(HttpServletRequest request, User user, String companyName) {
        String taskIdParam = read(request.getParameter("taskId"));
        String title = read(request.getParameter("taskTitle"));
        String dueDateParam = read(request.getParameter("dueDate"));
        String status = read(request.getParameter("taskStatus"));
        String assignedUserIdParam = read(request.getParameter("taskAssignedUserId"));

        if (taskIdParam.isEmpty() || title.isEmpty() || dueDateParam.isEmpty() || status.isEmpty()) {
            return;
        }

        if (!isAllowedTaskStatus(status)) {
            return;
        }

        try {
            int taskId = Integer.parseInt(taskIdParam);
            Task existingTask = taskDao.getTaskByIdAndCompany(taskId, companyName);
            if (existingTask == null) {
                return;
            }

            boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
            if (!isAdmin && existingTask.getAssignedUserId() != user.getId()) {
                return;
            }

            int assignedUserId = existingTask.getAssignedUserId();
            if (isAdmin && !assignedUserIdParam.isEmpty()) {
                try {
                    assignedUserId = Integer.parseInt(assignedUserIdParam);
                } catch (NumberFormatException ignored) {
                    assignedUserId = existingTask.getAssignedUserId();
                }
            }

            Task updated = new Task();
            updated.setId(taskId);
            updated.setTitle(title);
            updated.setDueDate(Date.valueOf(dueDateParam));
            updated.setStatus(status);
            updated.setAssignedUserId(assignedUserId);

            if (taskDao.updateTask(updated, companyName)) {
                logActivity(companyName, existingTask.getCustomerId(), user.getId(), "TASK_UPDATED", "Task updated");

                if (assignedUserId != existingTask.getAssignedUserId() && assignedUserId > 0) {
                    logActivity(companyName, existingTask.getCustomerId(), user.getId(), "TASK_REASSIGNED", "Task reassigned");
                    User assignedUser = userDao.getNotificationSettingsById(assignedUserId);
                    if (assignedUser != null && assignedUser.isNotifyTaskAssign()) {
                        notificationDao.createNotification(
                                assignedUserId,
                                "New task assigned: " + updated.getTitle(),
                                "TASK_ASSIGN",
                                "task",
                                taskId
                        );
                    }
                }
            }
        } catch (IllegalArgumentException ignored) {
            // ignore invalid inputs
        }
    }

    private void handleDeleteTask(HttpServletRequest request, User user, String companyName) {
        String taskIdParam = read(request.getParameter("taskId"));
        if (taskIdParam.isEmpty()) {
            return;
        }

        try {
            int taskId = Integer.parseInt(taskIdParam);
            Task existingTask = taskDao.getTaskByIdAndCompany(taskId, companyName);
            if (existingTask == null) {
                return;
            }

            boolean isAdmin = "admin".equalsIgnoreCase(user.getRole());
            if (!isAdmin && existingTask.getCreatedBy() != user.getId()) {
                return;
            }

            if (taskDao.deleteTask(taskId, companyName)) {
                logActivity(companyName, existingTask.getCustomerId(), user.getId(), "TASK_DELETED", "Task deleted");
            }
        } catch (NumberFormatException ignored) {
            // ignore invalid id
        }
    }

    private void handleSendBulkEmail(HttpServletRequest request, User user, String companyName, HttpSession session) {
        String[] selectedIds = request.getParameterValues("selectedCustomerIds");
        String subject = read(request.getParameter("bulkSubject"));
        String body = read(request.getParameter("bulkBody"));

        if (selectedIds == null || selectedIds.length == 0) {
            session.setAttribute("bulkEmailError", "Select at least one customer to send email.");
            return;
        }

        if (subject.isEmpty() || body.isEmpty()) {
            session.setAttribute("bulkEmailError", "Subject and message are required.");
            return;
        }

        CompanySettings settings = companySettingsDao.getByCompany(companyName);
        if (settings == null || !settings.isVerified()) {
            session.setAttribute("bulkEmailError", "Company email is not linked or verified.");
            return;
        }

        int sentCount = 0;
        for (String idValue : selectedIds) {
            try {
                int customerId = Integer.parseInt(idValue);
                Customer customer = customerDao.getCustomerByIdAndCompany(customerId, companyName);
                if (customer == null || customer.getEmail() == null || customer.getEmail().trim().isEmpty()) {
                    continue;
                }

                String parsedSubject = TemplateUtil.parseTemplate(subject, customer);
                String parsedBody = TemplateUtil.parseTemplate(body, customer);
                boolean sent = emailService.sendEmail(
                        customer.getEmail(),
                        parsedSubject,
                        parsedBody,
                        settings.getSmtpEmail(),
                        settings.getSmtpPassword()
                );
                if (sent) {
                    sentCount++;
                }
            } catch (NumberFormatException ignored) {
                // ignore invalid id
            }
        }

        logActivity(companyName, 0, user.getId(), "BULK_EMAIL_SENT", "Bulk email sent to " + sentCount + " customers");

        String senderName = user.getName() == null ? "User" : user.getName();
        List<User> admins = userDao.getAdminUsersByCompany(companyName);
        for (User admin : admins) {
            notificationDao.createNotification(
                    admin.getId(),
                    "User " + senderName + " sent bulk email to " + sentCount + " customers",
                    "BULK_EMAIL",
                    "bulk_email",
                    0
            );
        }

        session.setAttribute("bulkEmailSuccess", "Bulk email sent to " + sentCount + " customers.");
    }

    private void handleSaveTemplate(HttpServletRequest request, User user, String companyName, HttpSession session) {
        String templateName = read(request.getParameter("templateName"));
        String subject = read(request.getParameter("bulkSubject"));
        String body = read(request.getParameter("bulkBody"));

        if (templateName.isEmpty() || subject.isEmpty() || body.isEmpty()) {
            session.setAttribute("bulkEmailError", "Template name, subject, and message are required.");
            return;
        }

        EmailTemplate template = new EmailTemplate();
        template.setCompanyName(companyName);
        template.setTemplateName(templateName);
        template.setSubject(subject);
        template.setBody(body);
        template.setCreatedBy(user.getId());

        if (emailTemplateDao.createTemplate(template)) {
            session.setAttribute("bulkEmailSuccess", "Template saved.");
        } else {
            session.setAttribute("bulkEmailError", "Unable to save template.");
        }
    }

    private boolean isAllowedTaskStatus(String status) {
        return "Pending".equalsIgnoreCase(status)
                || "In Progress".equalsIgnoreCase(status)
                || "Completed".equalsIgnoreCase(status);
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

    private String resolveCompanyName(HttpSession session, User user) {
        String companyName = (String) session.getAttribute("companyName");
        if (companyName == null || companyName.trim().isEmpty()) {
            companyName = user.getCompanyName();
            session.setAttribute("companyName", companyName);
        }
        return companyName;
    }
}
