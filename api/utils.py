#!/usr/bin/env python3

from ldap3 import Server, Connection
from ldap3.core.exceptions import LDAPException

import pymysql.cursors

import settings

# Determines if the given username
# corresponds to the given user id.
def isAuthorized(username, uid):
	user = callDB("get_user", uid, username)
	return len(user) == 1

# Asks the LDAP server if the given username and password are valid.
# Returns nothing on success, and raises an LDAPException on error.
def callLDAP(username, password):
	conn = None

	try :
		serv = Server(host=settings.LDAP_HOST)
		conn = Connection(serv, raise_exceptions=True,
			user='uid='+username+', ou=People,ou=fcs,o=unb',
			password=password)

		conn.open()
		conn.start_tls()
		conn.bind()
	except (LDAPException):
		raise
	finally:
		if conn is not None:
			conn.unbind()

# Runs the given stored procedure with the supplied arguements.
# Returns a list of tuples of the resulting rows on success.
def callDB(procedure, *args):
	conn = None
	cur = None

	try:
		conn = pymysql.connect(settings.DB_HOST, settings.DB_USER,
			settings.DB_PASSWD, settings.DB_DATABASE, charset='utf8mb4',
			cursorclass= pymysql.cursors.DictCursor)

		cur = conn.cursor()
		cur.callproc(procedure, tuple(args))

		res = cur.fetchall()

		conn.commit()
	except:
		raise
	finally:
		if cur is not None:
			cur.close()
		if conn is not None:
			conn.close()

	return res
