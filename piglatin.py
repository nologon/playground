#!/usr/bin/python
x = "J123"
print "Welcome to the Pig Latin Translator!"
# Start coding here!
name = raw_input("What's your name? ")
original = name
print original
if len(original) > 0 and x.isalpha():
	print "nice word"
else:
	print "Empty"