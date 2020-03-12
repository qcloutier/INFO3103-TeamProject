DROP PROCEDURE IF EXISTS get_users;

DELIMITER //

CREATE PROCEDURE get_users (
	IN first_name_in VARCHAR(20),
	IN last_name_in  VARCHAR(20),
	IN dob_in        DATE
)
BEGIN
	SELECT * FROM users
	WHERE first_name LIKE first_name_in
		AND last_name LIKE last_name_in
		AND dob LIKE dob_in;
END //

DELIMITER ;
