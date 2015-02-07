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

oid_rttMonCtrlAdminTag=('.1.3.6.1.4.1.9.9.42.1.2.1.1.3.')

# .1.3.6.1.4.1.9.9.42.1.2.9.1.6.11 IPSLA1
# .1.3.6.1.4.1.9.9.42.1.2.9.1.6.12 IPSLA2
# .1.3.6.1.4.1.9.9.42.1.2.9.1.6.13 IPSLA3
# .1.3.6.1.4.1.9.9.42.1.2.9.1.6.14 IPSLA4
# .1.3.6.1.4.1.9.9.42.1.2.9.1.6.15 IPSLA5

oid_ipsla = ('.1.3.6.1.4.1.9.9.42.1.2.9.1.6.')


oid_rttMonctrlOperTimeoutOccurred= netsnmp.snmpget(oid_ipsla,
        Version = 2,
        DestHost="%s" % (sys.argv[2]),
        Community="%s" % (sys.argv[4]))
#~ print DestHost
#~ print Community
oid_test= oid_ipsla+"%s" % (tag)



#print oid_test
#test = netsnmp.snmpget (oid_test, DestHost="90.145.57.130", Version = 2, Community="Vosko123")
test = netsnmp.snmpget (oid_test, DestHost = DestHost, Version = 2, Community = Community)
#print test

if test[0] == "2":
        print "OK"
else:
        print "CRITICAL Tunnel down"


#~ ipsla_tag = netsnmp.snmpwalk(oid_rttMonCtrlAdminTag,
        #~ Version = 2,
        #~ DestHost="%s" % (sys.argv[2]),
        #~ Community="%s" % (sys.argv[4]))

#~ ipsla_list = netsnmp.snmpget (ipsla_tag, DestHost = DestHost, Version = 2, Community = Community)

(options, args) = parser.parse_args()
#oid = netsnmp.Varbind('sysDescr')
#~ oid_rttMonctrlOperTimeoutOccurred = netsnmp.Varbind('.1.3.6.1.4.1.9.9.42.1.2.9.1.6.')
#~ result = netsnmp.snmpwalk(oid_rttMonctrlOperTimeoutOccurred,
	#~ Version = 2,
	#~ DestHost="90.145.57.130", 
	#~ Community="Vosko123")
#~ print result[0]
#~ print result[1]
#~ print result[2]
#~ print result[3]
#~ print result[4]

#~ ipsla1 = "11"
#~ ipsla2 = "12"
#~ ipsla3 = "13"
#~ ipsla4 = "14"
#~ ipsla5 = "15"
#~ print ipsla1
#~ print ipsla2
#~ print ipsla3
#~ print ipsla4
#~ print ipsla5

#oid_ipsla1 = 'oid_rttMonctrlOperTimeoutOccurred = netsnmp.Varbind('.1.3.6.1.4.1.9.9.42.1.2.9.1.6.%d') % (ipsla1)'
#~ oid_ipsla1 = "oid_rttMonctrlOperTimeoutOccurred = netsnmp.Varbind('.1.3.6.1.4.1.9.9.42.1.2.9.1.6.11')"
#~ print oid_ipsla1



		
(options, args) = parser.parse_args()
