#!/bin/sh
#
# These test cases validate the
# functionality of the login endpoint.

ptcl='http'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need a pair of known valid credentials \(LDAP\).
read -p "Username: " user
read -s -p "Password: " pass

echo Registering a test user with the system...
curl -Lf "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "'"$user"'", "password": "'"$pass"'"}'

echo ===== TEST 1 =====
echo Send a POST request with an invalid body.
echo Expected response: 400
curl -Li "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

echo ===== TEST 2 =====
echo Send a POST request with an invalid username.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "jtest", "password": "jtest"}'

echo ===== TEST 2 =====
echo Send a POST request with a valid username, but invalid password.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user"'", "password": "jtest"}'

echo ===== TEST 3 =====
echo Send a POST request with a valid username and password.
echo Expected response: 201
curl -Li "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user"'", "password": "'"$pass"'"}'

echo ===== TEST 4 =====
echo Send a POST request for a user that already has a session.
echo Expected response: 201
curl -Li "$ptcl://$host:$port/login" \
	-c testcookie \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user"'", "password": "'"$pass"'"}'

echo ===== TEST 5 =====
echo Send a DELETE request without specifying a session.
echo Expected response: 404
curl -Li "$ptcl://$host:$port/login" \
	-X DELETE

echo ===== TEST 6 =====
echo Send a DELETE request for a valid user that has an active session.
echo Expected response: 204
curl -Li "$ptcl://$host:$port/login" \
	-b testcookie \
	-X DELETE

echo ===== TEST 7 =====
echo Send a DELETE request for a valid user that does not have an active session.
echo Expected response: 204
curl -Li "$ptcl://$host:$port/login" \
	-b testcookie \
	-X DELETE

rm testcookie
