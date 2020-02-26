DROP PROCEDURE IF EXISTS get_user;

DELIMITER //

CREATE PROCEDURE get_user (
	IN user_id_in  INT,
	IN username_in VARCHAR(20)
)
BEGIN
	SELECT * FROM users
	WHERE user_id = user_id_in
		OR username = username_in;
END //

DELIMITER ;
