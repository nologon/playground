#!/usr/bin/python
from datetime import datetime
now = datetime.now()

print '%s/%s/%s ' '%s:%s:%s' % (now.year, now.month, now.day, now.hour, now.minute, now.second)
#~ print '%s:%s:%s' % (now.hour, now.minute, now.second)