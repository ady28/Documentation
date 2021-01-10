#To get elements of a cim class use this; you will get methods and properties
Get-CimClass -ClassName win32_bios

#An easy example of a cdxml module is the win32_bios class
#It has one instance methode; the Get methode; the default noun is Bios as set in the cdxml
#The cmdlet is Get-Bios

#A more complex example is Computer; it has more instance methods
#The Name param of the cim class is mapped to the NewName in the cmdlet 

#The registry cim class has only static methods
#In the example we have also an output value
