import sys
from flask import Flask, jsonify, abort, request, make_response, session
from flask_restful import reqparse, Resource, Api
from flask_session import Session
import pymysql.cursors
import json
import cgitb
import cgi
import sys
import settings
#cgitb.enable()

# Authentication:
#  - check if authenticated
#  - check if the user matches the user id
#
# DB:
#  - function that takes stored proc name and params, returns map

# Checks if a user is in the session list of our "server"
def checkAuthentication(username, session):
	if username in session:
		return True
	return False

# Takes in a username(string) and userId(int), and determines if the User with that ID matches that username
def checkIfUserMatchesId(username, userId):
	user = callDB("getUser", (userId))
	if user.username == username:
		return True
	return False


# Takes in a procedureName(string, such as "getUser") and an array of parameters to filter by
# Note, not sure how to handle determining if we fetchone() or fetchall(), we could have two different functions
def callDB(procedureName, *params):
	try:
		dbConnection = pymysql.connect(
			settings.DB_HOST,
			settings.DB_USER,
			settings.DB_PASSWD,
			settings.DB_DATABASE,
			charset='utf8mb4',
			cursorclass= pymysql.cursors.DictCursor)

		sql = procedureName
		cursor = dbConnection.cursor()
	
		# the * command on the input parameter sends in a list, pack it into a tuple for the procedure
		sqlArgs = tuple(params)

		cursor.callproc(sql, sqlArgs)
		rows = cursor.fetchall()
	except:
		abort(500)
	finally:
		cursor.close()
		dbConnection.close()

	return rows
