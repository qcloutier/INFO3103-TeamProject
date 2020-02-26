DROP PROCEDURE IF EXISTS delete_present;

DELIMITER //

CREATE PROCEDURE delete_present (
	IN present_id_in INT
)
BEGIN
	DELETE FROM presents
	WHERE present_id = present_id_in;
END //

DELIMITER ;
