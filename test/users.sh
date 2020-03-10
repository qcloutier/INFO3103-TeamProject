#!/bin/sh
#
# These test cases validate the
# functionality of the users endpoint.
#
# Assumes that the database has no records, and that
# the login endpoint can be POST'ed successfully.

ptcl='https'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need two distinct pairs of known valid credentials \(LDAP\).
read -p "Username echo1: " user1
read -s -p "Password echo1: " pass1
read -p "Username echo2: " user2
read -s -p "Password echo2: " pass2

echo ===== TEST 1 =====
echo Send a POST request with an invalid body.
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

echo ===== TEST 2 =====
echo Send a POST request with an invalid username.
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": "jtest", "password": ""}'

echo ===== TEST 3 =====
echo Send a POST request with a valid username, but an invalid password.
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": ""}'

echo ===== TEST 4 =====
echo Send a POST request with a valid username and password.
echo \(This will be user1 in later test cases\)
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}'

echo ===== TEST 5 =====
echo Send another POST request for user1.
curl -Li "$ptcl://$host:$port/users" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}'

echo Registering another test user, user2, for use in later test cases...
curl -L "$ptcl://$host:$port/users" \
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
curl -Li "$ptcl://$host:$port/users"

echo ===== TEST 7 =====
echo Send a GET request, authenticated as user1.
curl -Li "$ptcl://$host:$port/users" \
	-c testcookie1

echo ===== TEST 8 =====
echo Send a GET request, authenticated as user1, with a query on first name.
curl -Li "$ptcl://$host:$port/users?first=duke" \
	-c testcookie1

echo ===== TEST 9 =====
echo Send a GET request, authenticated as user1, with a query on last name.
curl -Li "$ptcl://$host:$port/users?first=nuke" \
	-c testcookie1

echo ===== TEST 10 =====
echo Send a GET request, authenticated as user1, with a query on date-of-birth.
curl -Li "$ptcl://$host:$port/users?dob=1992" \
	-c testcookie1

rm testcookie1 testcookie2
