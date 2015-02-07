#!/usr/bin/python
import netsnmp
oid = netsnmp.Varbind('.1.3.6.1.2.1.2.2.1.1')
#test = netsnmp.snmpgetnext(oid,
result = netsnmp.snmpwalk(oid,
	Version = 2,
	DestHost="localhost",
	Community="public")

#retVal = snmpSession.get(vars)
retVal = netsnmp.VarList(vals)
response = retVal[0]
print respons