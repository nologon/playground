#!/usr/bin/python
pyg = 'ay'
print "Welcome to the Pig Latin Translator!"
# Start coding here!
name = raw_input("What word do you need translated? ")
original = name
if len(original) > 0 and original.isalpha():
	word = original.lower()
	first = word[0]
	new_word = word + first + pyg
	s = new_word
	new_word = s[1:len(new_word)]
	print new_word
else:
	print "Empty"
