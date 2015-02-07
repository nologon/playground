#!/usr/bin/python

import optparse
import os
import sys

from optparse import OptionParser
check_IP_SLA = '0.1'

# Parse commandline options:

#parser = OptionParser(usage="%prog -w <warning threshold> -c <critical threshold> [ -h ]",version="%prog " + check_IP_SLA)
parser = OptionParser(usage="%prog [ -h ]",version="%prog " + check_IP_SLA)
parser.add_option("-w", "--warning",
    action="store", type="string", dest="warn_threshold", help="Warning threshold in percentage")
parser.add_option("-c", "--critical",
    action="store", type="string", dest="crit_threshold", help="Critical threshold in percentage")
parser.add_option("-H", "--host",
    action="store", type="string", dest="host", help="Host-Address")
parser.add_option("-s", "--community",
    action="store", type="string", dest="community", help="SNMP Community String")    
parser.add_option("-o", "--object",
    action="store", type="string", dest="object", help="Which value to get (ipsla1). Parameters are: <ipsla1>")
(options, args) = parser.parse_args()


def writelogfile(stringtowrite):

 logfile = open("/home/thijn/var/log/log.txt", "a")
 logfile.write(stringtowrite)
 logfile.close()


def checkresult(strresult, label, critical):
 
    if strresult >= critical:
        
         print "CRITICAL: "  + strresult + " " + label + "|" + label + "=" + strresult
        
         sys.exit(2)
    elif strresult >= warning:
         
         print "WARNING: "  + strresult + " " + label + "|" + label + "=" + strresult
    else:
         
         print "OK: " + strresult + " " + label + "|" + label + "=" + strresult

def check_ipsla(object, host, community):
      
   if (object == "ipsla1"):
     result =  os.popen('snmpget -v1 -c '+ community + host + ' .1.3.6.1.4.1.9.9.42.1.2.9.1.6.11')
     strresult =  result.readlines()
     strresult = str(strresult)
     strresult = strresult[-9:-5]
     label = "IPSLA1"
     checkresult(strresult, label)
        
   else:
        sys.exit(3)

def go():
#    if not options.crit_threshold:
#        print "UNKNOWN: Missing critical threshold value."
#      sys.exit(3)
#    if not options.warn_threshold:
 #       print "UNKNOWN: Missing warning threshold value."
 #       sys.exit(3)
    if not options.object:
        print "UNKNOWN: Missing object value."
        sys.exit(3)
    if not options.host:
        print "UNKNOWN: Missing Host Address."
        sys.exit(3)
    if not options.community:
        print "UNKNOWN: Missing SNMP Community."
        sys.exit(3)
 #   if int(options.warn_threshold) >= int(options.crit_threshold):
   #     print "UNKNOWN: Critical percentage can't be equal to or bigger than warning percentage."
#        sys.exit(3)
    else:
        check_ipsla(options.object, options.host, options.community)

if __name__ == '__main__':
    go()   



