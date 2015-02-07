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
	#Community="public")
	Community="%s" % (sys.argv[4]))
#print interfaces
operstatus = netsnmp.snmpget(oidIfOperStatus,
	Version = 2,
	DestHost="%s" % (sys.argv[2]),
	Community="%s" % (sys.argv[4]))
#print operstatus
#print tag
ifoperstatus = oidIfOperStatus+"%s" % (tag)
#int01= oidIfOperStatus+"%s" % (blaa)

#print ifoperstatus

test = netsnmp.snmpget (ifoperstatus, DestHost="localhost", Version = 2, Community="public")

#~ if ifoperstatus[0] == "1":
if test[0] == "1":
	print "OK"
else:
	print "CRITICAL Tunnel down"
	
#~ status = netsnmp.snmpwalk(oidIfOperStatus,
	#~ Version = 2,
	#~ DestHost="localhost",
	#~ Community="public")

#~ result = netsnmp.snmpget(oidIfOperStatus,
	#~ Version = 2,
	#~ DestHost="%s" % (sys.argv[2]),
	#~ Community="%s" % (sys.argv[4]))
#print result
#print status

(options, args) = parser.parse_args()

#print oidIfOperStatus
#blaa = 1
#int0='oidIfOperStatus.%s' % (result[0])
#int01=oidIfOperStatus+"%s" % (blaa)
#int1="oidIfOperStatus.%s" % (result[1])
#int2="oidIfOperStatus.%s" % (result[2])
#print int0
#print int01
#print int1
#~ print int2

#print result
#print result[0]
#~ print result[1]
#~ print result[2]
#print sys.argv[0]
#print sys.argv[2]
#print sys.argv[4]


#cmd = netsnmp.snmpgetnext(
