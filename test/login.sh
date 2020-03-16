#!/bin/sh
#
# These test cases validate the
# functionality of the login endpoint.
#
# Assumes that the users and user
# endpoints are working correctly.
#
# Set the following in settings.py:
# LDAP_ENABLE = True

ptcl='https'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need a pair of known valid credentials \(LDAP\).
echo They must NOT already be registered with the system.
read -p "Username: " user
read -s -p "Password: " pass
echo ''

printf "\n=> SETUP <=\n"
echo Registering a test user with the system...
uid=$(curl -Lk "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "'"$user"'", "password": "'"$pass"'"}' \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)

printf "\n=> TEST <=\n"
echo Send a POST request with an invalid body.
echo Expected response: 400
curl -Lik "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

printf "\n=> TEST <=\n"
echo Send a POST request with an invalid username.
echo Expected response: 401
curl -Lik "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "jtest", "password": "jtest"}'

printf "\n=> TEST <=\n"
echo Send a POST request with a valid username, but invalid password.
echo Expected response: 401
curl -Lik "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user"'", "password": "jtest"}'

printf "\n=> TEST <=\n"
echo Send a POST request with a valid username and password.
echo Expected response: 201
curl -Lik "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user"'", "password": "'"$pass"'"}'

printf "\n=> TEST <=\n"
echo Send a POST request for a user that already has a session.
echo Expected response: 201
curl -Lik "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user"'", "password": "'"$pass"'"}'

printf "\n=> TEST <=\n"
echo Send a DELETE request without specifying a session.
echo Expected response: 404
curl -Lik "$ptcl://$host:$port/login" \
	-X DELETE

printf "\n=> TEST <=\n"
echo Send a DELETE request for a valid user that has an active session.
echo Expected response: 204
curl -Lik "$ptcl://$host:$port/login" \
	-b testcookie \
	-X DELETE

printf "\n=> TEST <=\n"
echo Send a DELETE request for a valid user that does not have an active session.
echo Expected response: 404
curl -Lik "$ptcl://$host:$port/login" \
	-b testcookie \
	-X DELETE

printf "\n=> TEARDOWN <=\n"
echo Deleting the test user...
curl -Lk "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user"'", "password": "'"$pass"'"}'
curl -Lk "$ptcl://$host:$port/users/$uid" \
	-b testcookie \
	-X DELETE

rm testcookie
