#~ Boolean Operators
#~ ------------------------      
#~ True and True is True
#~ True and False is False
#~ False and True is False
#~ False and False is False

#~ True or True is True
#~ True or False is True
#~ False or True is True
#~ False or False is False

#~ Not True is False
#~ Not False is True

#~ bool_one = 2**3 == 108 % 100 or 'Cleese' == 'King Arthur'
#~ bool_two = True or False
#~ bool_three = 00**0.5 >= 50 or False
#~ bool_four = True or True
#~ bool_five = 1**100 == 100**1 or 3 * 2 * 1 != 3 + 2 + 1

##~ The boolean operator not returns True for false statements and False for true statements.
#~ bool_one = not True
#~ bool_two = not 3**4 < 4**3
#~ bool_three = not 10 % 3 <= 10 % 2
#~ bool_four = not 3**2 + 4**2 != 5**2
#~ bool_five = not not False


#~ Boolean operators aren't just evaluated from left to right. Just like with arithmetic operators, there's an order of operations for boolean operators:
    #~ not is evaluated first;
    #~ and is evaluated next;
    #~ or is evaluated last.
#~ For example, True or not False and False returns True. If this isn't clear, look at the Hint.
#~ Parentheses () ensure your expressions are evaluated in the order you want. Anything in parentheses is evaluated as its own unit.

#~ bool_one = False or not True and True 	# False or False  and True
								# False and True
								# False
								
#~ bool_two = False and not True or True	# False and False or True
								# False or True
								# True
#~ bool_three = True and not (False or False)	# True and not (False)
									# True and True
									# True
#~ bool_four = not not True or False and not True	# True or False and False
										# True or False
										# True

#~ bool_five = False or not (True and True)	# False or (False)
								# False


# Use boolean expressions as appropriate on the lines below!
# Make me false!
bool_one = (2 <= 2) and "Alpha" == "Bravo"  # We did this one for you!

# Make me true!
bool_two =  (10**2) <= 120 and "Jack" == "Jack"

# Make me false!
bool_three = not 2 < 4 and "jim" == "jim"

# Make me true! 
bool_four = not 10**2 >= 2**10 or 50 and "jim" == "jim"

# Make me true!
bool_five = "Jim" != "jim"  and  100 == 100



print bool_one
print bool_two
print bool_three
print bool_four
print bool_five