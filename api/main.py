#!/usr/bin/env python3

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

import users, user, presents, present
from login import Login
from users import Users
from user import User
from presents import Presents
from present import Present

import settings

app = Flask(__name__)
app.secret_key = settings.SECRET_KEY
app.config['SESSION_TYPE'] = 'filesystem'
app.config['SESSION_COOKIE_NAME'] = 'peanutButter'
app.config['SESSION_COOKIE_DOMAIN'] = settings.APP_HOST
Session(app)

api = Api(app)

api.add_resource(Login, '/login')

api.add_resource(Users, '/users')
api.add_resource(User, '/users/<int:userId>')

api.add_resource(Presents, '/users/<int:userId>/presents')
api.add_resource(Present, '/users/<int:userId>/presents/<int:presentId>')

if __name__ == "__main__":
	app.run(host=settings.APP_HOST, port=settings.APP_PORT, debug=settings.APP_DEBUG)
