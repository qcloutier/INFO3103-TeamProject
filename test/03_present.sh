#!/bin/sh
# These tests cases validate the functionality of the endpoint
# that lets users add, view, modify, and delete presents.

# Prompt for a two pairs of credentials that are known to be valid.
printf 'To test, we need two distinct pairs of known valid credentials (LDAP).'
read -p "Username #1: " user1
read -s -p "Password #1: " pass1
read -p "Username #2: " user2
read -s -p "Password #2: " pass2

# Register the test users.
curl -Li "https://info3103.cs.unb.ca:55338/user" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}'
curl -Li "https://info3103.cs.unb.ca:55338/user" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "Duke", "last": "Test", "dob": "1995-01-01", "username": '"$user2"', "password": '"$pass2"'}'

# Authenticate the test users.
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie1 \
	-X POST -d '{"username": '"$user1"', "password": '"$pass1"'}'
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-H 'Content-Type: application/json' \
	-c testcookie2 \
	-X POST -d '{"username": '"$user2"', "password": '"$pass2"'}'

# TODO finish this ...
