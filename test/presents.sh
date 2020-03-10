#1/bin/sh
#
# These test cases validate the
# functionality of the presents endpoint.
#
# Assumes that the database has no records, and that
# the login and users endpoints can be POST'ed successfully.

ptcl='https'
host='info3103.cs.unb.ca'
port='55338'

echo To test, we need two distinct pairs of known valid credentials \(LDAP\).
read -p "Username echo1: " user1
read -s -p "Password echo1: " pass1
read -p "Username echo2: " user2
read -s -p "Password echo2: " pass2

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

echo ===== TEST 1 =====
echo Send a POST request for a non-existent user, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/0/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

echo ===== TEST 2 =====
echo Send a POST request for user1, without authentication.
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

echo ===== TEST 3 =====
echo Send a POST request for user1, authenticated as user2.
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

echo ===== TEST 4 =====
echo Send a POST request with an invalid body for user1, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{}'

echo ===== TEST 5 =====
echo Send a POST request for user1, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present1", "description": "cool", "cost": 5, "url": "www.amazon.ca/aa"}'

echo ===== TEST 6 =====
echo Create another present for user1, present2, for use in later test cases.
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-b testcookie1 \
	-H 'Content-Type: application/json' \
	-X POST -d '{"name": "present2", "description": "rad", "cost": 10, "url": "www.amazon.ca/bb"}'

echo ===== TEST 7 =====
echo Send a GET request for a non-existent user, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/0/presents" \
	-b testcookie1

echo ===== TEST 8 =====
echo Send a GET request for user1, without authentication.
curl -Li "$ptcl://$host:$port/users/1/presents"

echo ===== TEST 9 =====
echo Send a GET request for user1, authenticated as user1.
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-b testcookie1

echo ===== TEST 10 =====
echo Send a GET request for user1, authenticated as user2.
curl -Li "$ptcl://$host:$port/users/1/presents" \
	-b testcookie2

echo ===== TEST 11 =====
echo Send a GET request for user1, authenticated as user1, with a query on name.
curl -Li "$ptcl://$host:$port/users/1/presents?name=present2" \
	-b testcookie1

echo ===== TEST 12 =====
echo Send a GET request for user1, authenticated as user1, with a query on description.
curl -Li "$ptcl://$host:$port/users/1/presents?description=rad" \
	-b testcookie1

echo ===== TEST 13 =====
echo Send a GET request for user1, authenticated as user1, with a query on cost.
curl -Li "$ptcl://$host:$port/users/1/presents?minCost=8&maxCost=12" \
	-b testcookie1

echo ===== TEST 14 =====
echo Send a GET request for user1, authenticated as user1, with a query on url.
curl -Li "$ptcl://$host:$port/users/1/presents?url=bb" \
	-b testcookie1

rm testcookie1 testcookie2
