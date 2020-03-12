DROP PROCEDURE IF EXISTS get_presents;

DELIMITER //

CREATE PROCEDURE get_presents (
	IN name_in        VARCHAR(50),
	IN description_in VARCHAR(1000),
	IN min_cost_in    DECIMAL(5,2),
	IN max_cost_in    DECIMAL(5,2),
	IN user_id_in     INT
)
BEGIN
	SELECT * FROM presents
	WHERE name LIKE name_in
		AND description LIKE description_in
		AND cost >= min_cost_in
		AND cost <= max_cost_in
		AND user_id = user_id_in;
END //

DELIMITER ;
