#!/bin/sh
# These tests cases validate the functionality of the
# endpoint that lets users create and destroy sessions.

# Prompt for a pair of credentials that are known to be valid.
printf 'To test, we need a pair of known valid credentials (LDAP).'
read -p "Username: " user
read -s -p "Password: " pass

# Register a test user with the system.
curl -Li "https://info3103.cs.unb.ca:55338/user" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user"', "password": '"$pass"'}'

# TEST 1:
# Send a POST request with an invalid body.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie \
	-X POST -d '{}'

# TEST 2:
# Send a POST request with an invalid username and password.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie \
	-X POST -d '{"username": "jtest", "password": "jtest"}'

# TEST 3:
# Send a POST request with a valid username and password.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie \
	-X POST -d '{"username": '"$user"', "password": '"$pass"'}'

# TEST 4:
# Send a POST request for a user that already has a session.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie \
	-X POST -d '{"username": '"$user"', "password": '"$pass"'}'

# TEST 5:
# Send a DELETE request for an invalid user.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	--cookie="auth=00000000-0000-0000-0000-00000000" \
	-X DELETE

# TEST 6:
# Send a DELETE request for a valid user that has an active session.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-b testcookie \
	-X POST -d '{"username": '"$user"', "password": '"$pass"'}'

# TEST 7:
# Send a DELETE request for a valid user that does not have an active session.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-b testcookie \
	-X POST -d '{"username": '"$user"', "password": '"$pass"'}'

# Cleanup temporary files
rm testcookie
