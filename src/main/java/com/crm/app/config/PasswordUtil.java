package com.crm.app.config;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

/**
 * Utility class for password hashing using SHA-256
 */
public class PasswordUtil {

    /**
     * Hash a password using SHA-256 algorithm
     * @param password The plain text password to hash
     * @return The hashed password as a Base64 string
     */
    public static String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = digest.digest(password.getBytes());
            return Base64.getEncoder().encodeToString(hashedBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not found", e);
        }
    }

    /**
     * Verify a password by comparing its hash with the stored hash
     * @param plainPassword The plain text password to verify
     * @param storedHash The stored hashed password
     * @return true if password matches, false otherwise
     */
    public static boolean verifyPassword(String plainPassword, String storedHash) {
        String hashedInput = hashPassword(plainPassword);
        if (hashedInput.equals(storedHash)) {
            return true;
        }

        // Backward compatibility: allow existing hex-hashed records.
        return hashPasswordHex(plainPassword).equalsIgnoreCase(storedHash);
    }

    private static String hashPasswordHex(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = digest.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashedBytes) {
                int intValue = b & 0xff;
                String hex = Integer.toHexString(intValue);
                if (hex.length() == 1) {
                    hexString.append("0");
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not found", e);
        }
    }
}
