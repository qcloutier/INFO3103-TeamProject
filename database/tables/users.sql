DROP TABLE IF EXISTS users;

CREATE TABLE users (
	PRIMARY KEY (user_id),

	user_id    INT         AUTO_INCREMENT,
	username   VARCHAR(20) NOT NULL,
	first_name VARCHAR(20) NOT NULL,
	last_name  VARCHAR(20) NOT NULL,
	dob        DATE
);
