DROP PROCEDURE IF EXISTS update_present;

DELIMITER //

CREATE PROCEDURE update_present (
	IN present_id_in  INT,
	IN name_in        VARCHAR(50),
	IN description_in VARCHAR(1000),
	IN cost_in        DECIMAL(5,2),
	IN url_in         VARCHAR(500)
)
BEGIN
	UPDATE presents SET
		name        = COALESCE(name_in, name),
		description = COALESCE(description_in, description),
		cost        = COALESCE(cost_in, cost),
		url         = COALESCE(url_in, url)
	WHERE present_id = present_id_in;
END //

DELIMITER ;
