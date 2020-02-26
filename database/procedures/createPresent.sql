DROP PROCEDURE IF EXISTS create_present;

DELIMITER //

CREATE PROCEDURE create_present (
	IN  name_in        VARCHAR(50),
	IN  description_in VARCHAR(1000),
	IN  cost_in        DECIMAL(5,2),
	IN  url_in         VARCHAR(500),
	IN  user_id_in     INT
)
BEGIN
	INSERT INTO presents (name, description, cost, url, user_id)
	VALUES (name_in, description_in, cost_in, url_in, user_id_in);
END //

DELIMITER ;
