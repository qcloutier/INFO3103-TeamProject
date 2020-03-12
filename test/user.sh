#!/bin/sh
#
# These test cases validate the
# functionality of the user endpoint.

ptcl='http'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need two distinct pairs of known valid credentials \(LDAP\).
read -p "Username echo1: " user1
read -s -p "Password echo1: " pass1
read -p "Username echo2: " user2
read -s -p "Password echo2: " pass2

echo Registering the test users...
uid=$(curl -Lf "$ptcl://$host:$port/users?username=$user1" \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)
if [ "$uid" == "" ]; then
	uid=$(curl -Lf "$ptcl://$host:$port/users" \
		-H 'Content-Type: application/json' \
		-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": "'"$user1"'", "password": "'"$pass1"'"}'
		| grep user_id \
		| tr -s '[:blank:]' \
		| cut -d ' ' -f3)
fi
curl -Lf "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "Duke", "last": "Nuke", "dob": "1992-01-01", "username": '"$user2"', "password": '"$pass2"'}'

echo Authenticating the test users...
curl -Lf "$ptcl://$host:$port/login" \
	-c testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user1"'", "password": "'"$pass1"'"}'
curl -Lf "$ptcl://$host:$port/login" \
	-c testcookie2 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user2"'", "password": "'"$pass2"'"}'

echo ===== TEST 1 =====
echo Send a GET request for user1, without authentication.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users/$uid"

echo ===== TEST 2 =====
echo Send a GET request for a non-existant user, authenticated as user1.
echo Expected response: 404
curl -Li "$ptcl://$host:$port/users/0" \
	-c testcookie1

echo ===== TEST 3 =====
echo Send a GET request for user1, authenticated as user1.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users/$uid" \
	-c testcookie1

echo ===== TEST 4 =====
echo Send a GET request for user1, authenticated as user2.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users/$uid" \
	-c testcookie2

echo ===== TEST 5 =====
echo Send a PUT request for user1, without authentication.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users/$uid" \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"first": "Johnathan", "last": "Testificate", "dob": "1900-01-01"}'

echo ===== TEST 6 =====
echo Send a PUT request for user1, authenticated as user2.
echo Expected response: 403
curl -Li "$ptcl://$host:$port/users/$uid" \
	-b testcookie2 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"first": "Johnathan", "last": "Testificate", "dob": "1900-01-01"}'

echo ===== TEST 7 =====
echo Send a PUT request for a non-existent user, authenticated as user1.
echo Expected response: 404
curl -Li "$ptcl://$host:$port/users/0" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"first": "Johnathan", "last": "Testificate", "dob": "1900-01-01"}'

echo ===== TEST 8 =====
echo Send a PUT request for user1, authenticated as user1.
echo Expected response: 204
curl -Li "$ptcl://$host:$port/users/$uid" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"first": "Johnathan", "last": "Testificate", "dob": "1900-01-01"}'

echo ===== TEST 9 =====
echo Send a DELETE request for user1, without authentication.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users/$uid" \
	-X DELETE

echo ===== TEST 10 =====
echo Send a DELETE request for user1, authenticated as user2.
echo Expected response: 403
curl -Li "$ptcl://$host:$port/users/$uid" \
	-b testcookie2 \
	-X DELETE

echo ===== TEST 11 =====
echo Send a DELETE request for a non-existent user, authenticated as user1.
echo Expected response: 404
curl -Li "$ptcl://$host:$port/users/0" \
	-b testcookie1 \
	-X DELETE

echo ===== TEST 12 =====
echo Send a DELETE request for user1, authenticated as user1.
echo Expected response: 204
curl -Li "$ptcl://$host:$port/users/$uid" \
	-n testcookie1 \
	-X DELETE

rm testcookie1 testcookie2
