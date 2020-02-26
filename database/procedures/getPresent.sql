DROP PROCEDURE IF EXISTS get_present;

DELIMITER //

CREATE PROCEDURE get_present (
	IN present_id_in INT
)
BEGIN
	SELECT * FROM presents
	WHERE present_id = present_id_in;
END //

DELIMITER ;
