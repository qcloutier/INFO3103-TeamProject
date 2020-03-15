#!/bin/sh
#
# These test cases validate the
# functionality of the present endpoint.
#
# Assumes that the login, users, and
# presents endpoints work correctly.
#
# Set the following in settings.py:
# LDAP_ENABLE = False

ptcl='https'
host='info3103.cs.unb.ca'
port='55338'

printf "\n=> SETUP <=\n"
echo Registering the test users with the system...
uid1=$(curl -Lk "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "John", "last_name": "Test", "dob": "1995-01-01", "username": "jtest", "password": "password1!"}' \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)
uid2=$(curl -Lk "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first_name": "Duke", "last_name": "Nuke", "dob": "1992-01-01", "username": "dnuke", "password": "password1!"}' \
	| grep user_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)

printf "\n=> SETUP <=\n"
echo Authenticating the test users...
curl -Lk "$ptcl://$host:$port/login" \
	-c testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "jtest", "password": "password1!"}'
curl -Lk "$ptcl://$host:$port/login" \
	-c testcookie2 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": "dnuke", "password": "password1!"}'

printf "\n=> SETUP <=\n"
echo Creating a test present for user1...
pid=$(curl -Lk "$ptcl://$host:$port/users/$uid1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}' \
	| grep present_id \
	| tr -s '[:blank:]' \
	| cut -d ' ' -f3)

printf "\n=> TEST <=\n"
echo Send a GET request for present1, without authentication.
echo Expected response: 401
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid"

printf "\n=> TEST <=\n"
echo Send a GET request for a non-existent present, authenticated as user1.
echo Expected response: 404
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/0" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request for present1, authenticated as user1.
echo Expected response: 200
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a GET request for present1, authenticated as user2.
echo Expected response: 200
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-b testcookie2

printf "\n=> TEST <=\n"
echo Send a PUT request for present1, without authentication.
echo Expected response: 401
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'

printf "\n=> TEST <=\n"
echo Send a PUT request for a non-existent present, authenticated as user1.
echo Expected response: 404
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/0" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'

printf "\n=> TEST <=\n"
echo Send a PUT request for present1, authenticated as user2.
echo Expected response: 403
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-b testcookie2 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'

printf "\n=> TEST <=\n"
echo Send a PUT request for present1, authenticated as user1.
echo Expected response: 204
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-b testcookie1

printf "\n=> TEST <=\n"
echo Send a DELETE request for present1, without authentication.
echo Expected response: 401
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-X DELETE

printf "\n=> TEST <=\n"
echo Send a DELETE request for a non-existent present, authenticated as user1.
echo Expected response: 404
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/0" \
	-b testcookie1 \
	-X DELETE

printf "\n=> TEST <=\n"
echo Send a DELETE request for present1, authenticated as user2.
echo Expected response: 403
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-b testcookie2 \
	-X DELETE

printf "\n=> TEST <=\n"
echo Send a DELETE request for present1, authenticated as user1.
echo Expected response: 204
curl -Lik "$ptcl://$host:$port/users/$uid1/presents/$pid" \
	-b testcookie1 \
	-X DELETE

printf "\n=> TEARDOWN <=\n"
echo Deleting the test users...
curl -Lk "$ptcl://$host:$port/users/$uid1" \
	-b testcookie1 \
	-X DELETE
curl -Lk "$ptcl://$host:$port/users/$uid2" \
	-b testcookie2 \
	-X DELETE

rm testcookie1 testcookie2
