package com.crm.app.model;

public class User {
    private int id;
    private String name;
    private String email;
    private String password;
    private String role;
    private String companyName;
    private boolean firstLogin;
    private boolean notifyCustomerAssign = true;
    private boolean notifyTaskAssign = true;
    private boolean notifyTaskUpdate = true;

    // Constructor
    public User() {
    }

    public User(String name, String email, String password, String role) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    public User(String name, String email, String password, String role, String companyName) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.companyName = companyName;
    }

    public User(String name, String email, String password, String role, String companyName, boolean firstLogin) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.companyName = companyName;
        this.firstLogin = firstLogin;
    }

    public User(int id, String name, String email, String password, String role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    public User(int id, String name, String email, String password, String role, String companyName) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.companyName = companyName;
    }

    public User(int id, String name, String email, String password, String role, String companyName, boolean firstLogin) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.companyName = companyName;
        this.firstLogin = firstLogin;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public boolean isFirstLogin() {
        return firstLogin;
    }

    public void setFirstLogin(boolean firstLogin) {
        this.firstLogin = firstLogin;
    }

    public boolean isNotifyCustomerAssign() {
        return notifyCustomerAssign;
    }

    public void setNotifyCustomerAssign(boolean notifyCustomerAssign) {
        this.notifyCustomerAssign = notifyCustomerAssign;
    }

    public boolean isNotifyTaskAssign() {
        return notifyTaskAssign;
    }

    public void setNotifyTaskAssign(boolean notifyTaskAssign) {
        this.notifyTaskAssign = notifyTaskAssign;
    }

    public boolean isNotifyTaskUpdate() {
        return notifyTaskUpdate;
    }

    public void setNotifyTaskUpdate(boolean notifyTaskUpdate) {
        this.notifyTaskUpdate = notifyTaskUpdate;
    }
}
