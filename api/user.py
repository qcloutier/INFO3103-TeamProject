#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response
from flask_restful import Resource, Api
import pymysql.cursors
import json
import cgitb
import cgi
import sys
cgitb.enable()

class User(Resource):

	def get(self, userId):
		'''try:
			dbConnection = pymysql.connect(
				settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)

			sql = 'getUser'
			cursor = dbConnection.cursor()
			sqlArgs = (userId, rowCount)
			cursor.callproc(sql, sqlArgs)
			row = cursor.fetchone()
		except:
			abort(500)
		finally:
			cursor.close()
			dbConnection.close()'''

		sqlArgs = (userId, rowCount)
		rows = callDB('getUser', sqlArgs)

		return make_response(jsonify({'user': rows}), 200)

	def delete(self, userId):
		'''try:
			dbConnection = pymysql.connect(
				settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)
			sql = 'deleteUser'
			cursor = dbConnection.cursor()
			sqlArgs = (userId,)
			cursor.callproc(sql, sqlArgs)
			dbConnection.commit()
			success = 1
		except:
			abort(500)
			success = 0
		finally:
			cursor.close()
			dbConnection.close()'''

		sqlArgs = (userId)
		callDB('deleteUser', sqlArgs)

		return make_response('', 204)
