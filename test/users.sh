#!/bin/sh
#
# These test cases validate the
# functionality of the users endpoint.

ptcl='http'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need two distinct pairs of known valid credentials \(LDAP\).
read -p "Username 1: " user1
read -s -p "Password 1: " pass1
read -p "Username 2: " user2
read -s -p "Password 2: " pass2

echo Ensureing $user1 is not already registered...
uid=$(curl -Lf "$ptcl://$host:$port/users?username=$user1" \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)
if [ "$uid" != "" ]; then
	curl -Lf "$ptcl://$host:$port/users/$uid" \
		-X DELETE
fi

echo ===== TEST 1 =====
echo Send a POST request with an invalid body.
echo Expected response: 400
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

echo ===== TEST 2 =====
echo Send a POST request with an invalid username.
echo Expected response: 404
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": "jtest", "password": ""}'

echo ===== TEST 3 =====
echo Send a POST request with a valid username, but an invalid password.
echo Expected response: 404
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": ""}'

echo ===== TEST 4 =====
echo Send a POST request with a valid username and password.
echo \(This will be user1 in later test cases\)
echo Expected response: 201
resp=$(curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}')
echo "$resp"
uid=$(printf "$resp" \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)

echo ===== TEST 5 =====
echo Send another POST request for user1.
echo Expected response: 400
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}'

echo Registering another test user, user2, for use in later test cases...
curl -Lf "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "Duke", "last": "Nuke", "dob": "1992-01-01", "username": '"$user2"', "password": '"$pass2"'}'

echo Authenticating both test users...
curl -L "$ptcl://$host:$port/users" \
	-c testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": '"$user1"', "password": '"$pass1"'}'
curl -Li "$ptcl://$host:$port/users" \
	-c testcookie2 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": '"$user2"', "password": '"$pass2"'}'

echo ===== TEST 6 =====
echo Send a GET request, without authentication.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users"

echo ===== TEST 7 =====
echo Send a GET request, authenticated as user1.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users" \
	-c testcookie1

echo ===== TEST 8 =====
echo Send a GET request, authenticated as user1, with a query on first name.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users?first=duke" \
	-c testcookie1

echo ===== TEST 9 =====
echo Send a GET request, authenticated as user1, with a query on last name.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users?first=nuke" \
	-c testcookie1

echo ===== TEST 10 =====
echo Send a GET request, authenticated as user1, with a query on date-of-birth.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users?dob=1992" \
	-c testcookie1

rm testcookie1 testcookie2
