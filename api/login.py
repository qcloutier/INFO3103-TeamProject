#!/usr/bin/env python3
#
# Defines methods that handle user
# authentication with the system.

from flask import jsonify, abort, request, make_response, session
from flask_restful import Resource, reqparse

from ldap3.core.exceptions import LDAPException

from utils import callLDAP, callDB

class Login(Resource):

	def delete(self):
		# Check that the user is logged in.
		if 'username' not in session:
			abort(404, 'User is not logged in.')

		# Log out the user from the system.
		session.clear()

		return make_response('', 204)

	def post(self):
		# Parse the body of the request.
		try:
			# No JSON, no service.
			if not request.json:
				abort(400, 'Expected JSON, but did not recieve any.')

			parser = reqparse.RequestParser()

			parser.add_argument('username', type=str, required=True)
			parser.add_argument('password', type=str, required=True)

			params = parser.parse_args()
		except:
			abort(400, 'Could not parse request.')

		# Validate the user's credentials.
		try:
			callLDAP(params['username'], params['password'])
		except (LDAPException):
			abort(401, 'Invalid credentials.')

		# Get the user ID from the database.
		try:
			rows = callDB('get_user', 0, params['username'])
		except:
			abort(500, 'Failed to get user from database.')

		# Check that the user is registered.
		if len(rows) == 0:
			abort(401, 'User is not registered.')

		# Add the username and ID to the session.
		session['username'] = params['username']
		session['user_id'] = rows[0]['user_id']

		return make_response(jsonify({'message': 'Login successful.'}), 201)
