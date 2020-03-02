#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response
from flask_restful import Resource, Api
import pymysql.cursors
import json
import cgitb
import cgi
import sys
cgitb.enable()

class Presents(Resource):

	def get(self, userId):
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
			requestArgs = request.args

			sqlArgs = (
				userId,
				requestArgs.get('name'),
				requestArgs.get('desc'),
				requestArgs.get('minCost'),
				requestArgs.get('maxCost'),
				requestArgs.get('url'))

			cursor.callproc(sql, sqlArgs)
			rows = cursor.fetchall()
		except:
			abort(500)
		finally:
			cursor.close()
			dbConnection.close()'''


		requestArgs = request.args

		sqlArgs = (
			userId,
			requestArgs.get('name'),
			requestArgs.get('desc'),
			requestArgs.get('minCost'),
			requestArgs.get('maxCost'),
			requestArgs.get('url'))

		rows = callDB('getPresent', sqlArgs)

		return make_response(jsonify({'presents': rows}), 200)

	def post(self):
		if not request.json or not 'Name' in request.json:
			abort(400)

		name = request.json['Name'];
		desc = request.json['Description'];
		cost = request.json['Cost'];
		url = request.json['url'];
		userId = request.json['UserId'];

		'''try:
			dbConnection = pymysql.connect(settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)

			sql = 'createPresent'
			cursor = dbConnection.cursor()
			sqlArgs = (name, desc, cost, url, userId)
			cursor.callproc(sql,sqlArgs)
			row = cursor.fetchone()
			dbConnection.commit()
		except:
			abort(500)
		finally:
			cursor.close()
			dbConnection.close()'''

		sqlArgs = (name, desc, cost, url, userId)
		callDB('createPresent', sqlArgs)

		pid = row['LAST_INSERT_ID()']
		return make_response(jsonify( { "pid" : pid } ), 201)

	def put(self):
		if not request.json or not 'Name' in request.json:
			abort(400)

		name = request.json['Name'];
		desc = request.json['Description'];
		cost = request.json['Cost'];
		url = request.json['url'];
		userId = request.json['UserId'];

		'''try:
			dbConnection = pymysql.connect(settings.DB_HOST,
				settings.DB_USER,
				settings.DB_PASSWD,
				settings.DB_DATABASE,
				charset='utf8mb4',
				cursorclass= pymysql.cursors.DictCursor)

			sql = 'updatePresent'
			cursor = dbConnection.cursor()
			sqlArgs = (name, desc, cost, url, userId)
			cursor.callproc(sql,sqlArgs)
			row = cursor.fetchone()
			dbConnection.commit()
		except:
			abort(500)
		finally:
			cursor.close()
			dbConnection.close()'''

		sqlArgs = (name, desc, cost, url, userId)
		callDB('updatePresent', sqlArgs)

		return make_response('', 204)
