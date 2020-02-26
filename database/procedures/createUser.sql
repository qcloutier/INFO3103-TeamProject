DROP PROCEDURE IF EXISTS create_user;

DELIMITER //

CREATE PROCEDURE create_user (
	IN  username_in   VARCHAR(20),
	IN  first_name_in VARCHAR(20),
	IN  last_name_in  VARCHAR(20),
	IN  dob_in        DATE
)
BEGIN
	INSERT INTO users (username, first_name, last_name, dob)
	VALUES (username_in, first_name_in, last_name_in, dob_in);
END //

DELIMITER ;
