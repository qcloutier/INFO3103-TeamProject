#!/bin/sh
# These tests cases validate the functionality of the endpoint
# that lets users add, view, modify and remove themselves.

# Prompt for a two pairs of credentials that are known to be valid.
printf 'To test, we need two distinct pairs of known valid credentials (LDAP).'
read -p "Username #1: " user1
read -s -p "Password #1: " pass1
read -p "Username #2: " user2
read -s -p "Password #2: " pass2

# TEST 1:
# Send a POST request with an invalid body.
curl -Li "https://info3103.cs.unb.ca:55338/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

# TEST 2:
# Send a POST request with an invalid username.
curl -Li "https://info3103.cs.unb.ca:55338/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": "jtest", "password": ""}'

# TEST 3:
# Send a POST request with a valid username, but an invalid password.
curl -Li "https://info3103.cs.unb.ca:55338/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": ""}'

# TEST 4:
# Send a POST request with a valid username and password.
curl -Li "https://info3103.cs.unb.ca:55338/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}'

# TEST 5:
# Send a POST request for a user that is already registered.
curl -Li "https://info3103.cs.unb.ca:55338/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}'

# Register another user.
curl -Li "https://info3103.cs.unb.ca:55338/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "Duke", "last": "Test", "dob": "1995-01-01", "username": '"$user2"', "password": '"$pass2"'}'

# Authenticate both test users.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie1 \
	-X POST -d '{"username": '"$user1"', "password": '"$pass1"'}'
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie2 \
	-X POST -d '{"username": '"$user2"', "password": '"$pass2"'}'

# TEST 6:
# Send a GET request for all users, without authentication.
curl -Li "https://info3103.cs.unb.ca:55338/users"

# TEST 7:
# Send a GET request for a specific user that
# is known to exist, without authentication.
curl -Li "https://info3103.cs.unb.ca:55338/users/1"

# TEST 8:
# Send a GET request for a specific user that
# is known to not exist, without authentication.
curl -Li "https://info3103.cs.unb.ca:55338/users/0"

# TEST 9:
# Send a GET request for all users, with authentication.
curl -Li "https://info3103.cs.unb.ca:55338/users" \
	-c testcookie

# TEST 10:
# Send a GET request for a specific user that
# is known to exist, with authentication.
curl -Li "https://info3103.cs.unb.ca:55338/users/1" \
	-c testcookie

# TEST 11:
# Send a GET request for a specific user that
# is known to not exist, with authentication.
curl -Li "https://info3103.cs.unb.ca:55338/users/0" \
	-c testcookie

# TODO finish this ...

# Cleanup temporary files
rm testcookie1 testcookie2
