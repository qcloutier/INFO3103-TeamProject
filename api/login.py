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

class Login(Resource):

	def post(self):
		if not request.json:
			abort(400)

		try:
			parser = reqparse.RequestParser()

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
			user = utils.callDB('get_user', 0, params['username'])
		except:
			abort(500)

		if len(user) != 1:
			abort(401)

		session['username'] = params['username']
		session['user_id'] = user[0]['user_id']

		return make_response(jsonify( {'status': 'Created successfully'} ), 201)

	def delete(self):
		session.clear()
		return make_response('', 204)
