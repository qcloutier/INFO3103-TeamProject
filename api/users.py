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

class Users(Resource):

	def post(self):
		if not request.json:
			abort(400)

		try:
			parser = reqparse.RequestParser()

			parser.add_argument('first_name', type=str, required=True)
			parser.add_argument('last_name', type=str, required=True)
			parser.add_argument('dob', type=str, required=False)
			parser.add_argument('username', type=str, required=True)
			parser.add_argument('password', type=str, required=True)

			params = parser.parse_args()
		except:
			abort(400)

		try:
			utils.callLDAP(params['username'], params['password'])
		except (LDAPException):
			abort(401)

		try:
			res = utils.callDB(
				'create_user',
				params['username'],
				params['first_name'],
				params['last_name'],
				params['dob']
			)

			userID = res[0]['LAST_INSERT_ID()']
		except:
			abort(500)

		return make_response(jsonify( { "user_id" : userID } ), 201)

	def get(self):
		params = (
			0,
			"",
			request.args.get('first_name'),
			request.args.get('last_name'),
			request.args.get('dob')
		)

		rows = callDB('get_user', sqlArgs)

		return make_response(jsonify({'users': rows}), 200)

	def put(self):
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
			res = utils.callDB(
				'update_user',
				request.args.get('userID'),
				params['first_name'],
				params['last_name'],
				params['dob']
			)
		except:
			abort(500)

		return make_response('', 204)
