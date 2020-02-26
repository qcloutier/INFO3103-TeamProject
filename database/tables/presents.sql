DROP TABLE IF EXISTS presents;

CREATE TABLE presents (
	PRIMARY KEY (present_id),

	present_id  INT            AUTO_INCREMENT,
	name        VARCHAR(50)    NOT NULL,
	description VARCHAR(1000),
	cost        DECIMAL(5,2),
	url         VARCHAR(500),
	user_id     INT            NOT NULL,

	CONSTRAINT  FOREIGN KEY (user_id)
	REFERENCES  users (user_id)
);
