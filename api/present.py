#!/usr/bin/env python3
#
# Defines methods for accessing and
# modifying the presents in the system.

from flask import jsonify, abort, request, make_response, session
from flask_restful import Resource, reqparse

from utils import callDB

class Present(Resource):

	def delete(self, userID, presentID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# The user can only delete their own presents.
		if session['user_id'] != userID:
			abort(403, "You cannot delete another user's present.")

		# Find the present from the database.
		try:
			present = callDB('get_present', presentID)
		except:
			abort(500, 'Failed to find present in database.')

		# Verify that the present actually
		# exists and belongs to the user.
		if len(present) == 0 or present[0]['user_id'] != userID:
			abort(404, 'Present not found.')

		# Delete the present from the database.
		try:
			callDB('delete_present', presentID)
		except:
			abort(500, 'Failed to delete present from database.')

		return make_response('', 204)

	def get(self, userID, presentID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# Get the present from the database.
		try:
			rows = callDB('get_present', presentID)
		except:
			abort(500, 'Failed to get present from database.')

		# Check that the present exists and belongs to the user.
		if len(rows) == 0 or rows[0]['user_id'] != userID:
			abort(404, 'Present not found.')

		# The decimal class cannot be serialized
		# so we must convert the cost to a float.
		rows[0]['cost'] = float(rows[0]['cost'])

		return make_response(jsonify(rows[0]), 200)

	def put(self, userID, presentID):
		# The user must be authenticated.
		if 'username' not in session:
			abort(401, 'You must log in first.')

		# The user can only add presents to their own list.
		if session['user_id'] != userID:
			abort(403, 'You cannot modify presents for another user.')

		# Parse the body of the request.
		try:
			# No JSON, no service.
			if not request.json:
				abort(400, 'Expected JSON, but did not recieve any.')

			parser = reqparse.RequestParser()

			parser.add_argument('name', type=str, required=False)
			parser.add_argument('description', type=str, required=False)
			parser.add_argument('cost', type=float, required=False)
			parser.add_argument('url', type=str, required=False)

			params = parser.parse_args()
		except:
			abort(400, 'Could not parse request.')

		# Get the present from the database.
		try:
			present = callDB('get_present', presentID)
		except:
			abort(500, 'Failed to find present in database.')

		# Verify that the present actually
		# exists and belongs to the user.
		if len(present) == 0 or present[0]['user_id'] != userID:
			abort(404, 'Present not found.')

		# Update the present in the database.
		try:
			rows = callDB('update_present', presentID, params['name'],
				params['description'], params['cost'], params['url'])
		except:
			abort(500, 'Failed to update present in database.')

		return make_response('', 204)
