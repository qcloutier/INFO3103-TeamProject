#!/bin/sh
#
# These test cases validate the
# functionality of the present endpoint.
#
# Assumes that the database has no records, and that the
# login, users, and presents endpoints can be POST'ed successfully.

ptcl='https'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need two distinct pairs of known valid credentials \(LDAP\).
read -p "Username #1: " user1
read -s -p "Password #1: " pass1
read -p "Username #2: " user2
read -s -p "Password #2: " pass2

echo Registering the test users...
curl -Li "https://info3103.cs.unb.ca:55338/user" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "John", "last": "Test", "dob": "1995-01-01", "username": '"$user1"', "password": '"$pass1"'}'
curl -Li "https://info3103.cs.unb.ca:55338/user" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"first": "Duke", "last": "Test", "dob": "1995-01-01", "username": '"$user2"', "password": '"$pass2"'}'

echo Authenticating the test users...
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-c testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": '"$user1"', "password": '"$pass1"'}'
curl -Li "https://info3103.cs.unb.ca:55338/login" \
	-c testcookie2 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"username": '"$user2"', "password": '"$pass2"'}'

echo Creating a test present for user1...
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

echo ===== TEST 1 =====
echo Send a GET request for present1, without authentication.
curl -Li "$ptcl://$host:$port/users/1/presents/1"

echo ===== TEST 2 =====
echo Send a GET request for a non-existent present, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents/0" \
	-c testcookie1

echo ===== TEST 3 =====
echo Send a GET request for present1, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-c testcookie1

echo ===== TEST 4 =====
echo Send a GET request for present1, authenticated as user2.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-c testcookie2

echo ===== TEST 5 =====
echo Send a PUT request for present1, without authentication.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'

echo ===== TEST 6 =====
echo Send a PUT request for a non-existent present, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents/0" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'

echo ===== TEST 7 =====
echo Send a PUT request for present1, authenticated as user2.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-b testcookie2 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'

echo ===== TEST 8 =====
echo Send a PUT request for present1, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X PUT -d '{"name": "present1mod", "description": "very cool", "cost": 50, "url": "www.amazon.ca/aaaa"}'

echo ===== TEST 9 =====
echo Send a DELETE request for present1, without authentication.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-X DELETE

echo ===== TEST 10 =====
echo Send a DELETE request for a non-existent present, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents/0" \
	-b testcookie1 \
	-X DELETE

echo ===== TEST 11 =====
echo Send a DELETE request for present1, authenticated as user2.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-b testcookie2 \
	-X DELETE

echo ===== TEST 12 =====
echo Send a DELETE request for present1, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents/1" \
	-n testcookie1 \
	-X DELETE

rm testcookie1 testcookie2
