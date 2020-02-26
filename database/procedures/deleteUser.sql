DROP PROCEDURE IF EXISTS delete_user;

DELIMITER //

CREATE PROCEDURE delete_user (
	IN user_id_in INT
)
BEGIN
	DELETE FROM users
	WHERE user_id = user_id_in;
END //

DELIMITER ;
