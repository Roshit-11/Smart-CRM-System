package com.crm.app.util;

import com.crm.app.model.Customer;

public class TemplateUtil {

    public static String parseTemplate(String template, Customer customer) {
        if (template == null) {
            return "";
        }
        String result = template;
        String name = customer.getName() == null ? "" : customer.getName();
        String email = customer.getEmail() == null ? "" : customer.getEmail();
        String phone = customer.getPhone() == null ? "" : customer.getPhone();
        String company = customer.getCompany() == null ? "" : customer.getCompany();

        result = result.replace("{{name}}", name);
        result = result.replace("{{email}}", email);
        result = result.replace("{{phone}}", phone);
        result = result.replace("{{company}}", company);
        return result;
    }
}
