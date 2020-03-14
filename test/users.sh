#!/bin/sh
#
# These test cases validate the
# functionality of the users endpoint.
#
# Assumes that the login
# endpoint works correctly.

ptcl='http'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need a pair of known valid credentials \(LDAP\).
echo They must NOT already be registered with the system.
read -p "Username 1: " user1
read -s -p "Password 1: " pass1
echo ''
read -p "Username 2: " user2
read -s -p "Password 2: " pass2
echo ''

printf "\n=> TEST <=\n"
echo Send a POST request with an invalid body.
echo Expected response: 400
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

printf "\n=> TEST <=\n"
echo Send a POST request with an invalid username.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "jtest", "password": ""}'

printf "\n=> TEST <=\n"
echo Send a POST request with a valid username, but an invalid password.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "'"$user1"'", "password": ""}'

printf "\n=> TEST <=\n"
echo Send a POST request with a valid username and password.
echo Expected response: 201
resp=$(curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "'"$user1"'", "password": "'"$pass1"'"}')
echo "$resp"
uid1=$(printf "$resp" \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)

printf "\n=> TEST <=\n"
echo Send another POST request for user1.
echo Expected response: 403
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "'"$user1"'", "password": "'"$pass1"'"}'

printf "\n=> SETUP <=\n"
echo Registering another test user...
uid2=$(curl -L "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "Duke", "last_name": "Nuke", "dob": "1992-01-01", "username": "'"$user2"'", "password": "'"$pass2"'"}' \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)

printf "\n=> SETUP <=\n"
echo Authenticating the test users...
curl -L "$ptcl://$host:$port/login" \
	-c testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user1"'", "password": "'"$pass1"'"}'
curl -L "$ptcl://$host:$port/login" \
	-c testcookie2 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user2"'", "password": "'"$pass2"'"}'

printf "\n=> TEST <=\n"
echo Send a GET request, without authentication.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users"

printf "\n=> TEST <=\n"
echo Send a GET request, authenticated as user1.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request, authenticated as user1, with a query on first name.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users?first_name=duke" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request, authenticated as user1, with a query on last name.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users?last_name=nuke" \
	-b testcookie1

printf "\n=> TEARDOWN <=\n"
echo Deleting the test users...
curl -L "$ptcl://$host:$port/users/$uid1" \
	-b testcookie1 \
	-X DELETE
curl -L "$ptcl://$host:$port/users/$uid2" \
	-b testcookie2 \
	-X DELETE

rm testcookie1 testcookie2
