turing_machine
==============

**Turing machine in Lua**

For creating new machine, edit input.txt and select "Create" in menu (if you clean machines.txt - creating start automaticaly)
For start machine, you need lua interpreter (lua 5.2). 
  cd <path>/Turing_machine
  lua ./Turing_machine.lua
or
 cd <path>/Turing_machine
 lua
 dofile("./Turung_machine.lua")
or (especially for Win users)
 put Lua interpreter in project folder
 start it
 type dofile("Turing_machine.lua")
  
Files
I.  input.txt  
  Format: n words separate with " " (one space) [the machine's behavior table]
    Row:		alphabet coordinate	(0 .. n) 
    Column:	state coordinate		(1 .. n) (0 means "stop machine")
  Word format: <ai><cmd><qi>
    <ai>  = symbol, that machine will write at this position
    <cmd> = change position (move left, right or stay at this position)
    <qi>  = new state of machine
II. machines.txt
  Containe list of existents machines. New line = new machine name
III. Turing_machine.lua
  Main code and interface. Start it with Lua interpreter
IV. *.lua
  Generated files, saved machines. Filename = machine name. You can start they by menu
V. input*.txt
  Example initial files for generating. Study it, if you have trouble with creating new one. Encoding: utf-8.

Machine start from rightmost symbol of parse string and in state q1 - field (n, q) in the table. 
Then, machine remove the symbol and write on that place symbol <ai> from word in field (1, n)
Do <cmd> action and change its state to <qi>
If state is equal to 0 -> machine stoped
