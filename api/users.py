#!/usr/bin/env python3
#
# Defines methods for creating and
# accessing the users of the system.

from flask import jsonify, abort, request, make_response, session
from flask_restful import Resource, reqparse

from ldap3.core.exceptions import LDAPException

from pymysql.err import IntegrityError

from utils import callLDAP, callDB

class Users(Resource):

	def get(self):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# Get the users from the database.
		try:
			rows = callDB('get_users',
				request.args.get('first_name'),
				request.args.get('last_name'))
		except:
			abort(500, 'Failed to get users from database.')

		return make_response(jsonify(rows), 200)

	def post(self):
		# Parse the body of the request.
		try:
			# No JSON, no service.
			if not request.json:
				abort(400, 'Expected JSON, but did not recieve any.')

			parser = reqparse.RequestParser()

			parser.add_argument('first_name', type=str, required=True)
			parser.add_argument('last_name', type=str, required=True)
			parser.add_argument('dob', type=str, required=False)
			parser.add_argument('username', type=str, required=True)
			parser.add_argument('password', type=str, required=True)

			params = parser.parse_args()
		except:
			abort(400, 'Could not parse request.')

		# Validate the provided LDAP credentials.
		try:
			callLDAP(params['username'], params['password'])
		except (LDAPException):
			abort(401, 'Invalid credentials.')

		# Add the new user to the database.
		try:
			res = callDB('create_user', params['username'],
				params['first_name'], params['last_name'], params['dob'])

			userID = res[0]['LAST_INSERT_ID()']

		except (IntegrityError):
			abort(403, 'Duplicate usernames are not allowed.')
		except:
			abort(500, 'Failed to create user in database.')

		return make_response(jsonify({"user_id": userID}), 201)
