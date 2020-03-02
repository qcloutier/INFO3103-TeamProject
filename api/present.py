#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response
from flask_restful import Resource, Api
import pymysql.cursors
import json
import cgitb
import cgi
import sys
cgitb.enable()

class Present(Resource):

	def get(self, userId, presentId):
		'''try:
			dbConnection = pymysql.connect(
				settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)

			sql = 'getPresent'
			cursor = dbConnection.cursor()
			sqlArgs = (userId, presentId,)
			cursor.callproc(sql, sqlArgs)
			rows = cursor.fetchall()
		except:
			abort(500)
		finally:
			cursor.close()
			dbConnection.close()'''

		sqlArgs = (userId, presentId)
		rows = callDB('getPresent', sqlArgs)

		return make_response(jsonify({'presents': rows}), 200)

	def delete(self, presentId):
		'''try:
			dbConnection = pymysql.connect(
				settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)

			sql = 'deletePresent'
			cursor = dbConnection.cursor()
			sqlArgs = (presentId,)
			cursor.callproc(sql, sqlArgs)
			dbConnection.commit()
			success = 1
		except:
			abort(500)
			success = 0
		finally:
			cursor.close()
			dbConnection.close()'''

		sqlArgs = (presentId)
		callDB('deletePresent', sqlArgs)

		return make_response('', 204)
