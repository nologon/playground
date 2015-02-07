#!/usr/bin/python 

import netsnmp
import os
import sys
from optparse import OptionParser


parser = OptionParser()
parser.add_option("-H", dest="DestHost",
                help="Target Host")
parser.add_option("-C", dest="Community",
		help="Community (default is public)")
parser.add_option("-U", dest="V3user",
		help="SNMPv3 username")
parser.add_option("-P", dest="V3pass",
		help="SNMPv3 password")
parser.add_option("-a", dest="V3hash",
		help="SNMPv3 hashing algorithm (default is MD5)")
parser.add_option("-e", dest="V3crypt",
		help="SNMPv3 encryption algorithm (default is DES)")
parser.add_option("-v", dest="V3version",
		help="SNMP version (1, 2c or 3 supported)")
parser.add_option("-S", dest="IPSLA",
		help="IPSLA Tag name")		

DestHost =  (sys.argv[2])
Community =  (sys.argv[4])
tag = (sys.argv[6])

oid_rttMonCtrlAdminTag = ('.1.3.6.1.4.1.9.9.42.1.2.1.1.3.11')

oid_ipsla = ('.1.3.6.1.4.1.9.9.42.1.2.9.1.6.')


oid_rttMonctrlOperTimeoutOccurred= netsnmp.snmpget(oid_ipsla,
        Version = 2,
        DestHost="%s" % (sys.argv[2]),
        Community="%s" % (sys.argv[4]))
oid_test= oid_ipsla+"%s" % (tag)
test = netsnmp.snmpget (oid_test, DestHost = DestHost, Version = 2, Community = Community)

if test[0] == "2":
        print "OK"
else:
        print "CRITICAL Tunnel down"

#print oid_rttMonCtrlAdminTag
ipsla_tag = netsnmp.snmpwalk(oid_rttMonCtrlAdminTag,
        Version = 2,
        DestHost="%s" % (sys.argv[2]),
        Community="%s" % (sys.argv[4]))
print DestHost
ipsla_list = netsnmp.snmpwalk ('.1.3.6.1.4.1.9.9.42.1.2.1.1.3', DestHost = DestHost, Version = 2, Community = Community)
#ipsla_list = netsnmp.snmpwalk (oid_rttMonCtrlAdminTag, DestHost = DestHost, Version = 2, Community = Community)
print ipsla_list
print ipsla_list[0]
print ipsla_list[1]
print ipsla_list[2]
print ipsla_list[3]
print ipsla_list[4]



(options, args) = parser.parse_args()

