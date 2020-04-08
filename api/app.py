#!/usr/bin/env python3
#
# Puts all of the pieces
# together and runs the system.

from flask import Flask, jsonify, make_response
from flask_restful import Api, Resource
from flask_session import Session

from login import Login
from present import Present
from presents import Presents
from user import User
from users import Users

import ssl

import settings

# Configure the session handler.

app = Flask(__name__)

app.secret_key = settings.SECRET_KEY

app.config['SESSION_TYPE'] = 'filesystem'
app.config['SESSION_COOKIE_NAME'] = 'Key'
app.config['SESSION_COOKIE_DOMAIN'] = settings.APP_HOST

Session(app)

# Define generic error messages.

@app.errorhandler(400)
def bad_request(error):
	return make_response(
		jsonify({"message": "Your request makes no sense."}), 400)

@app.errorhandler(401)
def unauthorized(error):
	return make_response(
		jsonify({"message": "You must authenticate first."}), 401)

@app.errorhandler(403)
def forbidden(error):
	return make_response(
		jsonify({"message": "You are not allowed to do that."}), 403)

@app.errorhandler(404)
def not_found(error):
	return make_response(
		jsonify({"message": "That resource does not exist."}), 404)

@app.errorhandler(405)
def not_found(error):
	return make_response(
		jsonify({"message": "You can not do that here."}), 404)

@app.errorhandler(500)
def internal_server_error(error):
	return make_response(
		jsonify({"message": "Something has gone horribly wrong."}), 500)

app.config['ERROR_404_HELP'] = False

class SPA(Resource):
	def get(self):
		return app.send_static_file('spa.html')



# Define the endpoints for the API.

api = Api(app)

api.add_resource(SPA, '/')

api.add_resource(Login, '/login')

api.add_resource(Users, '/users')
api.add_resource(User, '/users/<int:userID>')

api.add_resource(Presents, '/users/<int:userID>/presents')
api.add_resource(Present, '/users/<int:userID>/presents/<int:presentID>')

# Start up the application.

if __name__ == '__main__':
	context = (settings.SSL_CERT, settings.SSL_KEY)
	app.run(host=settings.APP_HOST,
		port=settings.APP_PORT,
		ssl_context=context,
		debug=settings.APP_DEBUG)
