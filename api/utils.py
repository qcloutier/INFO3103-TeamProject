#!/usr/bin/env python3
#
# Defines miscellaneous functions
# for reducing boilerplate.

from ldap3 import Server, Connection
from ldap3.core.exceptions import LDAPException

import pymysql.cursors

import settings

# Asks the LDAP server if the given username and password are valid.
# Returns nothing on success, and raises an LDAPException on error.
def callLDAP(username, password):

	# Many test cases require two authenticated users.
	# This debug setting allows us to run these tests
	# without needing any real credentials.
	if not settings.LDAP_ENABLE:
		return

	try:
		conn = None

		serv = Server(host=settings.LDAP_HOST)
		conn = Connection(serv, raise_exceptions=True,
			user='uid='+username+', ou=People,ou=fcs,o=unb',
			password=password)

		conn.open()
		conn.start_tls()
		conn.bind()
	finally:
		if conn is not None:
			conn.unbind()

# Runs the given stored procedure with the supplied arguments.
# Returns a list of tuples of the resulting rows on
# success, and raises a MySQLError on failure.
def callDB(procedure, *args):
	try:
		conn = None
		cur = None

		conn = pymysql.connect(settings.DB_HOST, settings.DB_USER,
			settings.DB_PASSWD, settings.DB_DATABASE, charset='utf8mb4',
			cursorclass= pymysql.cursors.DictCursor)

		cur = conn.cursor()
		cur.callproc(procedure, tuple(args))

		res = cur.fetchall()

		# We have to always commit since we don't know if
		# the procedure is supposed to modify the database.
		conn.commit()
	finally:
		if cur is not None:
			cur.close()
		if conn is not None:
			conn.close()

	return res
