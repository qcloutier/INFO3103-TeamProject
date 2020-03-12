#!/usr/bin/env python3

from flask import Flask, jsonify, abort, request, make_response, session
from flask_restful import reqparse, Resource, Api
from flask_session import Session

from ldap3 import Server, Connection, ALL
from ldap3.core.exceptions import *

import pymysql.cursors

import json
import sys

from login import Login
from present import Present
from presents import Presents
from user import User
from users import Users

import settings

app = Flask(__name__)

app.secret_key = settings.SECRET_KEY

app.config['SESSION_TYPE'] = 'filesystem'
app.config['SESSION_COOKIE_NAME'] = 'Key'
app.config['SESSION_COOKIE_DOMAIN'] = settings.APP_HOST

@app.errorhandler(400)
def not_found(error):
	return make_response(jsonify( { "status": "Bad request" } ), 400)

@app.errorhandler(401)
def not_found(error):
	return make_response(jsonify( { "status": "Unauthorized" } ), 401)

@app.errorhandler(403)
def not_found(error):
	return make_response(jsonify( { "status": "Forbidden" } ), 403)

@app.errorhandler(404)
def not_found(error):
	return make_response(jsonify( { "status": "Not found" } ), 404)

@app.errorhandler(500)
def not_found(error):
	return make_response(jsonify( { "status": "Internal error" } ), 500)

Session(app)

api = Api(app)

api.add_resource(Login, '/login')

api.add_resource(Users, '/users')
api.add_resource(User, '/users/<int:userID>')

api.add_resource(Presents, '/users/<int:userID>/presents')
api.add_resource(Present, '/users/<int:userID>/presents/<int:presentID>')

if __name__ == '__main__':
	app.run(host=settings.APP_HOST,
		port=settings.APP_PORT,
		debug=settings.APP_DEBUG)
