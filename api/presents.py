#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response, session
from flask_restful import reqparse, Resource, Api
from flask_session import Session

import pymysql.cursors
import json
import sys
from utils import callDB

class Presents(Resource):

	def get(self, userID):

		#User must be logged in to access
		if 'username' not in session:
			abort(401)

		# We need an intermediary call for the user whose presents we want
		# If the user doesn't exist, 404
		user = callDB('get_user', userID, '')
		if len(user) == 0:
			abort(404)

		requestArgs = request.args

		rows = callDB('get_presents',
			requestArgs.get('name'),
			requestArgs.get('desc'),
			userID)

		# Decimal class cannot be serialized, convert to float
		for row in rows:
			row['cost'] = float(row['cost'])

		return make_response(jsonify({'presents': rows}), 200)

	def post(self, userID):

		#User must be logged in to create a present for themself
		if 'username' not in session:
			abort(401)

		if session['user_id'] != userID:
			abort(403)

		if not request.json or not 'name' in request.json:
			abort(400)

		name = request.json['name'];
		desc = request.json['description'];
		cost = request.json['cost'];
		url = request.json['url'];
		userId = userID;

		rows = callDB('create_present', name, desc, cost, url, userId)

		pid = rows[0]['LAST_INSERT_ID()']
		return make_response(jsonify( { "present_id" : pid } ), 201)

