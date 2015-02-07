#!/usr/bin/python
import netsnmp
import os
import sys

oidIfOperStatus=('.1.3.6.1.2.1.2.2.1.8.1')
result = netsnmp.snmpget(oidIfOperStatus,
	Version = 2,
	DestHost="localhost",
	Community="public")

#print result[0]
#test = result[0]
#print test
if result[0] == "1":
	print "OK"
else:
	print "CRITICAL Tunnel down"
test = netsnmp.snmpget (.1.3.6.1.2.1.2.2.1.8.3,localhost, -v 2c -c public)
print test
