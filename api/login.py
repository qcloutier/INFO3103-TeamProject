#!/usr/bin/env python3

import sys
from flask import Flask, jsonify, abort, request, make_response, session
from flask_restful import reqparse, Resource, Api
from flask_session import Session
import json
from ldap3 import Server, Connection, ALL
from ldap3.core.exceptions import *
import settings
import cgitb
import cgi
cgitb.enable()

class Login(Resource):

	def post(self):
		if not request.json:
			abort(400)

		parser = reqparse.RequestParser()

		try:
			parser.add_argument('username', type=str, required=True)
			parser.add_argument('password', type=str, required=True)
			request_params = parser.parse_args()
		except:
			abort(400)

		if request_params['username'] in session:
			response = {'status': 'success'}
			responseCode = 200
		else:
			try:
				ldapServer = Server(host=settings.LDAP_HOST)
				ldapConnection = Connection(ldapServer,
					raise_exceptions=True,
					user='uid='+request_params['username']+', ou=People,ou=fcs,o=unb',
					password = request_params['password'])
				ldapConnection.open()
				ldapConnection.start_tls()
				ldapConnection.bind()

				dbConnection = pymysql.connect(
					settings.DB_HOST,
					settings.DB_USER,
					settings.DB_PASSWD,
					settings.DB_DATABASE,
					charset='utf8mb4',
					cursorclass= pymysql.cursors.DictCursor)

				sql = 'getUser'
				cursor = dbConnection.cursor()
				requestArgs = request.args

				sqlArgs = (0, request.args.get('username'))

				cursor.callproc(sql, sqlArgs)
				row = cursor.fetchone()

				session['username'] = request_params['username']
				session['id'] = request_params['id']
				response = {'status': 'success' }
				responseCode = 201
			except:
				response = {'status': 'Access denied'}
				responseCode = 403
			finally:
				ldapConnection.unbind()

		return make_response(jsonify(response), responseCode)

	def delete(self):
		if not 'username' in session:
			abort(400)

		session.clear()

		return make_response('', 204)
