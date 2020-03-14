#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response, session
from flask_restful import reqparse, Resource, Api
import pymysql.cursors
import json
import sys
from utils import callDB

class Present(Resource):

	def get(self, userID, presentID):

		#User must be logged in to access
		if 'username' not in session:
			abort(401)

		#Get present with that ID
		try:
			rows = callDB('get_present', presentID)
		except:
			abort(500)

		# If no rows returned, 404
		if len(rows) == 0:
			abort(404)

		# Decimal class cannot be serialized, convert to float
		rows[0]['cost'] = float(rows[0]['cost'])

		return make_response(jsonify(rows), 200)

	def put(self, userID, presentID):
		# Ensure that name is specified and that json is proper
		if not request.json or not 'name' in request.json:
			abort(400)

		# Check that user has a session
		if 'username' not in session:
			abort(401)

		# Check that session is correct
		if session['user_id'] != userID:
			abort(403)
	
		# We need an intermediary call for the present the user is updating
		# If the present doesn't exist, 404
		present = callDB('get_present', presentID)
		if len(present) == 0:
			abort(404)

		# If the present belongs to someone else, 403
		presentOwnerId = present[0]['user_id']
		if presentOwnerId != userID:
			abort(403)


		# Send request
		name = request.json['name'];
		desc = request.json['description'];
		cost = request.json['cost'];
		url = request.json['url'];
		presentId = presentID

		callDB('update_present', presentId, name, desc, cost, url)

		return make_response('', 204)

	def delete(self, userID, presentID):

		# Check that user has a session
		if 'username' not in session:
			abort(401)

		# Check that session is correct
		if session['user_id'] != userID:
			abort(403)
	
		# We need an intermediary call for the present the user is updating
		# If the present doesn't exist, 404
		present = callDB('get_present', presentID)
		if len(present) == 0:
			abort(404)

		# If the present belongs to someone else, 403
		presentOwnerId = present[0]['user_id']
		if presentOwnerId != userID:
			abort(403)

		# Send request
		callDB('delete_present', presentID)

		return make_response('', 204)
