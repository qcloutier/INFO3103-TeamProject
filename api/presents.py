#!/usr/bin/env python3
#
# Defines methods for creating and
# accessing the presents in the system.

from flask import jsonify, abort, request, make_response, session
from flask_restful import Resource, reqparse

from utils import callDB

class Presents(Resource):

	def get(self, userID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# Get the user from the database.
		try:
			user = callDB('get_user', userID, '')
		except:
			abort(500, 'Failed to find user in database.')

		# Verify that the user actually exists.
		if len(user) == 0:
			abort(404, 'No such user.')

		# Get the presents from the database.
		try:
			print(request.args)
			rows = callDB('get_presents',
				request.args.get('name'),
				request.args.get('description'),
				userID)
			print(rows)
		except:
			abort(500, 'Failed to get presents from database.')

		# The decimal class cannot be serialized
		# so we must convert the cost to a float.
		for row in rows:
			row['cost'] = float(row['cost'])

		return make_response(jsonify(rows), 200)

	def post(self, userID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# The user can only add presents to their own list.
		if session['user_id'] != userID:
			abort(403, 'You cannot request presents for another user.')

		# Parse the body of the request.
		try:
			# No JSON, no service.
			if not request.json:
				abort(400, 'Expected JSON, but did not recieve any.')

			parser = reqparse.RequestParser()

			parser.add_argument('name', type=str, required=True)
			parser.add_argument('description', type=str, required=False)
			parser.add_argument('cost', type=float, required=False)
			parser.add_argument('url', type=str, required=False)

			params = parser.parse_args()
		except:
			abort(400, 'Could not parse request.')

		# Create the present in the database.
		try:
			rows = callDB('create_present', params['name'],
				params['description'], params['cost'],
				params['url'], userID)

			presentID = rows[0]['LAST_INSERT_ID()']
		except:
			abort(500, 'Failed to create present in database.')

		return make_response(jsonify({"present_id": presentID}), 201)
