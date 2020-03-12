#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response, session
from flask_restful import reqparse, Resource, Api
from flask_session import Session

from ldap3 import Server, Connection, ALL
from ldap3.core.exceptions import *

import json
import sys

import settings
import utils

class User(Resource):

	def delete(self, userID):
		if 'username' not in session:
			abort(401)

		if not utils.isAuthorized(session['username'], userID):
			abort(403)

		try:
			utils.callDB('delete_user', userID)
		except:
			abort(500)

		session.clear()

		return make_response('', 204)

	def get(self, userID):
		if 'username' not in session:
			abort(401)

		try:
			rows = callDB('get_user', userID, session['username'])
		except:
			abort(500)

		if len(user) == 0:
			abort(404)

		return make_response(jsonify({'user': rows}), 200)

	def put(self):
		if 'username' not in session:
			abort(401)

		if not utils.isAuthorized(session['username'], userID):
			abort(403)

		if not request.json:
			abort(400)

		try:
			parser = reqparse.RequestParser()

			parser.add_argument('first_name', type=str, required=False)
			parser.add_argument('last_name', type=str, required=False)
			parser.add_argument('dob', type=str, required=False)

			params = parser.parse_args()
		except:
			abort(400)

		try:
			res = utils.callDB('update_user', request.args.get('userID'),
				params['first_name'], params['last_name'], params['dob'])
		except:
			abort(500)

		return make_response('', 204)
