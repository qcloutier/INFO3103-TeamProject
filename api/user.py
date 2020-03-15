#!/usr/bin/env python3
#
# Defines methods for accessing and
# modifying the users of the system.

from flask import jsonify, abort, request, make_response, session
from flask_restful import Resource, reqparse

from utils import callDB

class User(Resource):

	def delete(self, userID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# The user can only delete themselves.
		if session['user_id'] != userID:
			abort(403, 'You cannot delete another user.')

		# Delete the user from the database.
		try:
			callDB('delete_user', userID)
		except:
			abort(500, 'Failed to delete user from database.')

		# Log out the user from the system.
		session.clear()

		return make_response('', 204)

	def get(self, userID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# Get the user from the database.
		try:
			rows = callDB('get_user', userID, '')
		except:
			abort(500, 'Failed to get user from database.')

		# Verify that the user actually exists.
		if len(rows) == 0:
			abort(404, 'No such user.')

		return make_response(jsonify(rows[0]), 200)

	def put(self, userID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# The user can only modify themselves.
		if session['user_id'] != userID:
			abort(403, 'YOu cannot modify another user.')

		# Parse the body of the request.
		try:
			# No JSON, no service.
			if not request.json:
				abort(400, 'Expected JSON, but did not recieve any.')

			parser = reqparse.RequestParser()

			parser.add_argument('first_name', type=str, required=False)
			parser.add_argument('last_name', type=str, required=False)
			parser.add_argument('dob', type=str, required=False)

			params = parser.parse_args()
		except:
			abort(400, 'Could not parse request.')

		# Update the user in the database.
		try:
			res = callDB('update_user', userID, params['first_name'],
				params['last_name'], params['dob'])
		except:
			abort(500, 'Failed to update user in database.')

		return make_response('', 204)
