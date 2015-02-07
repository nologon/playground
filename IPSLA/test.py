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


(options, args) = parser.parse_args()

#~ print sys.argv[0]
#~ print sys.argv[2]
#~ print sys.argv[4]

if sys.argv[6] == "hoera":
	print "hoera"
else:
	print "no argument"