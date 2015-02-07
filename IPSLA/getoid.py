#!/usr/bin/python
import netsnmp
sess = netsnmp.Session(Version=2, DestHost='localhost', Community='public')
sess.UseLongNames = 1
sess.UseEnums = 1
vars = netsnmp.VarList(netsnmp.Varbind('.1.3.6.1.2.1.2.2.1.2',''))
print vars[0:3]
vals = sess.walk(vars)
print vals[0:3]