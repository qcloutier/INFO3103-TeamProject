DROP PROCEDURE IF EXISTS update_user;

DELIMITER //

CREATE PROCEDURE update_user (
	IN user_id_in    INT,
	IN first_name_in VARCHAR(20),
	IN last_name_in  VARCHAR(20),
	IN dob_in        DATE
)
BEGIN
	UPDATE users SET
		first_name = COALESCE(first_name_in, first_name),
		last_name  = COALESCE(last_name_in, last_name),
		dob        = COALESCE(dob_in, dob)
	WHERE user_id = user_id_in;
END //

DELIMITER ;
