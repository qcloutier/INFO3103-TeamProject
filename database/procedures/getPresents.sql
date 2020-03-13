DROP PROCEDURE IF EXISTS get_presents;

DELIMITER //

CREATE PROCEDURE get_presents (
	IN name_in        VARCHAR(50),
	IN description_in VARCHAR(1000),
	IN user_id_in     INT
)
BEGIN
	IF name_in IS NULL THEN
		SET name_in = '';
	END IF;
	IF description_in IS NULL THEN
		SET description_in = '';
	END IF;

	SELECT * FROM presents
	WHERE name LIKE name_in
		AND description LIKE description_in
		AND user_id = user_id_in;
END //

DELIMITER ;
