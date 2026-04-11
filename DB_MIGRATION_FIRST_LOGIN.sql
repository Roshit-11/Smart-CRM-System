-- Add first-login enforcement flag for existing SmartCRM users table.
-- Run this once in your MySQL database: crm-management-system

ALTER TABLE users
ADD COLUMN is_first_login BOOLEAN NOT NULL DEFAULT FALSE;

-- Optional: force all existing non-admin users to reset password on next login.
-- UPDATE users SET is_first_login = TRUE WHERE role = 'user';
