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

(options, args) = parser.parse_args()

print sys.argv[0]
print sys.argv[2]
print sys.argv[4]
