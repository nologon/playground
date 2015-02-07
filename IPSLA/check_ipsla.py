#!/usr/bin/python
import netsnmp
import os
import sys
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-H", dest="host",
                  help="Hostname")
parser.add_option("-C", dest="community",
                  help="SNMP community")
parser.add_option("-o", dest="oid",
                  help="OID")
parser.add_option("-v", dest="version",
                  help="SNMP Version")
parser.add_option("-i", dest="isla",
                  help="IPSLA tag")

tag =  (sys.argv[6])

oidifname=('.1.3.6.1.2.1.31.1.1.1.1')
oidIfOperStatus=('.1.3.6.1.2.1.2.2.1.8.')

interfaces = netsnmp.snmpwalk(oidifname,
	Version = 2,
	DestHost="%s" % (sys.argv[2]),
	Community="%s" % (sys.argv[4]))

operstatus = netsnmp.snmpget(oidIfOperStatus,
	Version = 2,
	DestHost="%s" % (sys.argv[2]),
	Community="%s" % (sys.argv[4]))
ifoperstatus = oidIfOperStatus+"%s" % (tag)

test = netsnmp.snmpget (ifoperstatus, DestHost="localhost", Version = 2, Community="public")
if test[0] == "1":
	print "OK"
else:
	print "CRITICAL Tunnel down"
(options, args) = parser.parse_args()

