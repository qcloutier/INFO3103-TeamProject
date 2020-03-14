#!/bin/sh
#
# These test cases validate the
# functionality of the presents endpoint.
#
# Assumes that the login and users
# endpoints work correctly.

ptcl='http'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need two distinct pairs of known valid credentials \(LDAP\).
echo They must NOT already be registered with the system.
read -p "Username 1: " user1
read -s -p "Password 1: " pass1
printf "\n"
read -p "Username 2: " user2
read -s -p "Password 2: " pass2
printf "\n"

printf "\n=> SETUP <=\n"
echo Registering the test users with the system...
uid1=$(curl -L "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "'"$user1"'", "password": "'"$pass1"'"}' \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)
uid2=$(curl -L "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "Duke", "last": "Nuke", "dob": "1992-01-01", "username": '"$user2"', "password": '"$pass2"'}' \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)

printf "\n=> SETUP <=\n"
echo Authenticating the test users...
curl -Lf "$ptcl://$host:$port/login" \
	-c testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user1"'", "password": "'"$pass1"'"}'
curl -Lf "$ptcl://$host:$port/login" \
	-c testcookie2 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "'"$user2"'", "password": "'"$pass2"'"}'

printf "\n=> TEST <=\n"
echo Send a POST request for a non-existent user, authenticated as user1.
echo Expected response: 403
curl -Li "$ptcl://$host:$port/users/0/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

printf "\n=> TEST <=\n"
echo Send a POST request for user1, without authentication.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users/$uid1/presents" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

printf "\n=> TEST <=\n"
echo Send a POST request for user1, authenticated as user2.
echo Expected response: 403
curl -Li "$ptcl://$host:$port/users/$uid1/presents" \
	-b testcookie2 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

printf "\n=> TEST <=\n"
echo Send a POST request with an invalid body for user1, authenticated as user1.
echo Expected response: 400
curl -Li "$ptcl://$host:$port/users/$uid1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

printf "\n=> TEST <=\n"
echo Send a POST request for user1, authenticated as user1.
echo Expected response: 201
curl -Li "$ptcl://$host:$port/users/$uid1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

printf "\n=> SETUP <=\n"
echo Creating another present for user1, for use in later test cases...
curl -L "$ptcl://$host:$port/users/$uid1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present2", "description": "rad", "cost": 10, "url": "www.amazon.ca/bb"}'

printf "\n=> TEST <=\n"
echo Send a GET request for a non-existent user, authenticated as user1.
echo Expected response: 404
curl -Li "$ptcl://$host:$port/users/0/presents" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request for user1, without authentication.
echo Expected response: 401
curl -Li "$ptcl://$host:$port/users/$uid1/presents"

printf "\n=> TEST <=\n"
echo Send a GET request for user1, authenticated as user1.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users/$uid1/presents" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request for user1, authenticated as user2.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users/$uid1/presents" \
	-b testcookie2

printf "\n=> TEST <=\n"
echo Send a GET request for user1, authenticated as user1, with a query on name.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users/$uid1/presents?name=present2" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request for user1, authenticated as user1, with a query on description.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users/$uid1/presents?description=rad" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request for user1, authenticated as user1, with a query on url.
echo Expected response: 200
curl -Li "$ptcl://$host:$port/users/$uid1/presents?url=bb" \
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
