# Complete Testing Guide - CRM Authentication System

## System Overview

Your CRM authentication system works in this flow:

```
Clean Login Page (First Load) ← No error messages shown
            ↓
User enters email and password
            ↓
Clicks "Login" button
            ↓
AuthController checks credentials against database
            ↓
├─ Email NOT found → Show ERROR: "Invalid email or password"
├─ Email found BUT wrong password → Show ERROR: "Invalid email or password"  
└─ Email found AND password correct → Create session → Show Dashboard
```

---

## What You Need to Test

### Phase 1: Setup & Database

1. **Create MySQL Database**
   ```sql
   CREATE DATABASE crm-management-system;
   USE crm-management-system;
   
   CREATE TABLE users (
       id INT PRIMARY KEY AUTO_INCREMENT,
       name VARCHAR(100) NOT NULL,
       email VARCHAR(100) UNIQUE NOT NULL,
       password VARCHAR(255) NOT NULL,
       role ENUM('admin', 'user') DEFAULT 'user',
       status ENUM('active', 'locked') DEFAULT 'active',
       failed_attempts INT DEFAULT 0,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```

2. **Update DBConfig.java**
   - File: `src/main/java/com/crm/app/config/DBConfig.java`
   - Change `PASSWORD = ""` to your MySQL password
   - Port is `3308` (as per your config)

3. **Add MySQL Connector Dependency** to `pom.xml`
   ```xml
   <dependency>
       <groupId>mysql</groupId>
       <artifactId>mysql-connector-java</artifactId>
       <version>8.0.33</version>
   </dependency>
   ```

---

## Phase 2: Test Clean Page Load

### Test 2.1: Login Page - First Load (No Error)
**Steps:**
1. Deploy project to Tomcat
2. Navigate to: `http://localhost:8080/smart-crm-system/view/auth/login.jsp`

**Expected Result:**
- ✅ Clean form appears
- ✅ No error message shown
- ✅ No red box visible
- ✅ Form fields are empty
- ✅ "Register here" link visible

---

## Phase 3: Test Registration

### Test 3.1: Register New User
**Steps:**
1. Click "Register here" link
2. Enter Details:
   - Full Name: `John Doe`
   - Email: `john@example.com`
   - Password: `MyPassword123`
3. Click "Register" button

**Expected Result:**
- ✅ User saved to database with SHA-256 hashed password
- ✅ Redirected to login page
- ✅ Green success message shows: "Registration successful! Please login with your credentials."
- ✅ Form fields are empty
- ✅ No error message

### Test 3.2: Register with Duplicate Email
**Steps:**
1. Try to register again with same email: `john@example.com`
2. Different password: `AnotherPassword123`
3. Click "Register" button

**Expected Result:**
- ❌ Red error message shows: "Registration failed. Email may already exist or invalid format."
- ✅ Stays on register page
- ✅ Form fields retain values (for re-entry)

---

## Phase 4: Test Login with Invalid Credentials

### Test 4.1: Empty Email Field
**Steps:**
1. On login page, leave email empty
2. Enter password: `MyPassword123`
3. Click "Login" button

**Expected Result:**
- ❌ Red error message shows: "Email is required"
- ✅ Stays on login page
- ✅ Password field keeps the value entered

### Test 4.2: Empty Password Field
**Steps:**
1. On login page, enter email: `john@example.com`
2. Leave password empty
3. Click "Login" button

**Expected Result:**
- ❌ Red error message shows: "Password is required"
- ✅ Stays on login page
- ✅ Email field keeps the value entered

### Test 4.3: Wrong Email (Not in Database)
**Steps:**
1. On login page, enter email: `wrong@example.com`
2. Enter password: `MyPassword123`
3. Click "Login" button

**Expected Result:**
- ❌ Red error message shows: "Invalid email or password"
- ✅ Stays on login page
- ✅ Form is cleared (security: don't show which field is wrong)

### Test 4.4: Correct Email but Wrong Password
**Steps:**
1. On login page, enter email: `john@example.com`
2. Enter password: `WrongPassword999`
3. Click "Login" button

**Expected Result:**
- ❌ Red error message shows: "Invalid email or password"
- ✅ Stays on login page
- ✅ Form is cleared

---

## Phase 5: Test Successful Login

### Test 5.1: Correct Email and Password
**Steps:**
1. On login page, enter email: `john@example.com`
2. Enter password: `MyPassword123` (the one you registered with)
3. Click "Login" button

**Expected Result:**
- ✅ Redirected to Dashboard: `/view/dashboard/home.jsp`
- ✅ Welcome message shows: "Welcome, John Doe!"
- ✅ User profile displays:
  - Email: john@example.com
  - Role: user
  - User ID: (the ID from database)
- ✅ Green header with logout button visible

---

## Phase 6: Test Session & Logout

### Test 6.1: Session Timeout Protection
**Steps:**
1. Login successfully (logged in)
2. Open a new browser tab
3. Try to access: `http://localhost:8080/smart-crm-system/view/dashboard/home.jsp`

**Expected Result:**
- ✅ Redirected to login page
- ✅ Session is stored per browser/tab

### Test 6.2: Logout Functionality
**Steps:**
1. Login successfully (on dashboard)
2. Click "Logout" button

**Expected Result:**
- ✅ Session is destroyed
- ✅ Redirected to login page
- ✅ Clean form appears (no errors or messages)
- ✅ If you try to go back, redirected to login again

### Test 6.3: Session Persistence
**Steps:**
1. Login successfully (on dashboard)
2. Refresh page (F5)
3. Still on dashboard

**Expected Result:**
- ✅ Session persists
- ✅ User info still shows
- ✅ No redirect to login

---

## Phase 7: Password Hashing Verification

### Test 7.1: Verify Password is Hashed in Database
**Steps:**
1. Login to MySQL
2. Check the users table:
   ```sql
   SELECT id, email, password FROM users;
   ```

**Expected Result:**
- ✅ Password is NOT plain text
- ✅ Password shows as long hex string (SHA-256 hash)
- ✅ Example: `8f14e45fceea167a5a36dedd4bea2543fd6ead0728f9e7e77d0b7d0a6c1ff5c`
- ✅ Different passwords produce different hashes
- ✅ Same password produces same hash (for same user)

---

## Complete User Flow Checklist

### Registration Flow ✅
- [ ] Navigate to `/view/auth/register.jsp`
- [ ] Form is clean (no errors)
- [ ] Enter name, email, password
- [ ] Click Register
- [ ] Success message shows (green)
- [ ] Redirected to login page
- [ ] Database has new user with hashed password

### Login Flow ✅
- [ ] Navigate to `/view/auth/login.jsp`
- [ ] Form is clean (no errors)
- [ ] Try with wrong email → Error shown
- [ ] Form clears on error
- [ ] Try with wrong password → Error shown
- [ ] Form clears on error
- [ ] Enter correct email and password
- [ ] Successfully logged in
- [ ] Dashboard shows user info
- [ ] Session created

### Logout Flow ✅
- [ ] On dashboard, click Logout
- [ ] Session destroyed
- [ ] Redirected to login page
- [ ] Form is clean (no errors)
- [ ] Cannot access dashboard without login

---

## Troubleshooting

### Problem: "Invalid email or password" shows on login even with correct credentials

**Solution:**
1. Check if user is in database:
   ```sql
   SELECT * FROM users WHERE email = 'john@example.com';
   ```
2. Check DBConfig.java has correct password and port
3. Check MySQL service is running
4. Check no exceptions in Tomcat logs

### Problem: Can't register due to "Email already exists" but email is different

**Solution:**
1. Check database for duplicate emails:
   ```sql
   SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;
   ```
2. If found, delete duplicates:
   ```sql
   DELETE FROM users WHERE email = 'duplicate@example.com' LIMIT 1;
   ```

### Problem: Error message showing on first page load

**Solution:**
1. Refresh browser (Ctrl+R or Cmd+R)
2. Clear browser cache
3. Open in Incognito/Private mode
4. Check that no error attribute is being set initially

### Problem: Password verification always fails

**Solution:**
1. Check PasswordUtil.java has verifyPassword() method
2. Check BCrypt dependency is NOT in pom.xml (we use SHA-256, not BCrypt)
3. Manually test hash:
   ```java
   String password = "MyPassword123";
   String hash = PasswordUtil.hashPassword(password);
   System.out.println("Hash: " + hash);
   ```

---

## Files Created/Modified

✅ **Created:**
- AuthController.java - Login/Register logic
- LogoutController.java - Session invalidation
- UserDao.java - Database operations
- PasswordUtil.java - SHA-256 hashing
- User.java - Model class
- DBConfig.java - Database config

✅ **JSP Frontend:**
- login.jsp - Clean form with error display
- register.jsp - Registration form
- home.jsp - Dashboard (session protected)

✅ **Styling:**
- style.css - Professional UI

---

## Success Indicators 🎉

Your system is working correctly when:

✅ First page load shows clean form (no errors)
✅ Wrong credentials show red error message
✅ Correct credentials show dashboard
✅ Session persists on page refresh
✅ Logout destroys session
✅ Passwords are hashed in database
✅ Cannot access dashboard without session
✅ No error on logout and re-login

**All Tests Passing = Ready for Deployment! 🚀**
