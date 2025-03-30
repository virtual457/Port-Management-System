-- Drop and recreate the database
DROP DATABASE IF EXISTS port;
CREATE DATABASE port;
USE port;

-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Roles table (admin, manager, staff, guest, etc.)
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO roles (role_name) VALUES ('admin'), ('manager'), ('staff'), ('customer');

-- User-Roles (many-to-many)
CREATE TABLE user_roles (
    user_id INT,
    role_id INT,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);

-- Ports table
CREATE TABLE ports (
    port_id INT AUTO_INCREMENT PRIMARY KEY,
    port_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE FUNCTION get_full_name(uid INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE full_name VARCHAR(100);
    SELECT CONCAT(first_name, ' ', last_name) INTO full_name FROM users WHERE user_id = uid;
    RETURN full_name;
END;


CREATE PROCEDURE add_new_user(IN uname VARCHAR(50), IN email VARCHAR(100))
BEGIN
    INSERT INTO users (username, email, password) VALUES (uname, email, 'default123');
END;

DELIMITER $$

CREATE PROCEDURE filter_users_advanced (
    IN username_filter VARCHAR(100),
    IN email_filter VARCHAR(100),
    IN role_filter VARCHAR(50)
)
BEGIN
    SELECT u.user_id, u.username, u.email, r.role_name
    FROM users u
    JOIN user_roles ur ON u.user_id = ur.user_id
    JOIN roles r ON ur.role_id = r.role_id
    WHERE 
        (username_filter IS NULL OR u.username LIKE CONCAT('%', username_filter, '%')) AND
        (email_filter IS NULL OR u.email LIKE CONCAT('%', email_filter, '%')) AND
        (role_filter IS NULL OR r.role_name = role_filter)
    ORDER BY u.created_at DESC;
END$$

DELIMITER ;



