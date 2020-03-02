#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response
from flask_restful import Resource, Api
import pymysql.cursors
import json
import cgitb
import cgi
import sys
import utils
cgitb.enable()

class Users(Resource):

	def get(self, userId):
		'''try:
			dbConnection = pymysql.connect(
				settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)

			sql = 'getUsers'
			cursor = dbConnection.cursor()
			requestArgs = request.args

			sqlArgs = (
				userId,
				request.args.get('firstName'),
				request.args.get('lastName'),
				request.args.get('dob'),
				rowCount)

			cursor.callproc(sql, sqlArgs)
			rows = cursor.fetchall()
		except:
			abort(500)
		finally:
			cursor.close()
			dbConnection.close()'''

		sqlArgs = (
			userId,
			request.args.get('firstName'),
			request.args.get('lastName'),
			request.args.get('dob'))
		rows = callDB('getUsers', sqlArgs)

		return make_response(jsonify({'users': rows}), 200)

	def put(self):

		if not request.json or not 'Name' in request.json:
			abort(400)

		firstName = request.json['FirstName'];
		lastName = request.json['LastName'];
		dob = request.json['dob'];
		sqlArgs = (firstName, lastName, dob)

		'''try:
			dbConnection = pymysql.connect(settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)

			sql = 'updateUser'
			cursor = dbConnection.cursor()
			sqlArgs = (firstName, lastName, dob)
			cursor.callproc(sql,sqlArgs)
			row = cursor.fetchone()
			dbConnection.commit()
		except:
			abort(500)
		finally:
			cursor.close()
			dbConnection.close()'''

		callDB('updateUser', sqlArgs)

		return make_response('', 204)
