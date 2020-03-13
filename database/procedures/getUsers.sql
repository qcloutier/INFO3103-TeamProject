DROP PROCEDURE IF EXISTS get_users;

DELIMITER //

CREATE PROCEDURE get_users (
	IN first_name_in VARCHAR(20),
	IN last_name_in  VARCHAR(20)
)
BEGIN
	IF first_name_in IS NULL THEN
		SET first_name_in = '';
	END IF;
	IF last_name_in IS NULL THEN
		SET last_name_in = '';
	END IF;

	SELECT * FROM users
	WHERE first_name LIKE CONCAT('%', first_name_in, '%')
		AND last_name LIKE CONCAT('%', last_name_in, '%');
END //

DELIMITER ;
