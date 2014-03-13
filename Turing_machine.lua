-- Data for new Turing machine loads from input.txt 
-- Format: n words separate with " " (one space) [the machine's behavior table]
-- 	Row:		alphabet coordinate	(0 .. n) 
-- 	Column:	state coordinate		(1 .. n) (0 means "stop machine")
-- Word format: <ai><cmd><qi>
--		<ai>  = symbol, that machine will write at this position
-- 	<cmd> = change position (move left, right or stay at this position)
-- 	<qi>  = new state of machine
-- Machine start from rightmost symbol of parse string and in state q1 - field (n, 1) in the table. 
-- Then, machine remove the symbol and write at that place symbol <ai> from word in field (1, n)
-- Do <cmd> action and change its state to <qi>
-- If state is equal to 0 -> stop machine

function formTM ( )
	local file = io.open( "./input.txt", "r" );	
	if not file then
		error "Can't open the file \"input.txt\". It should be at same directory with \"Turing_machine.lua\"";
	end

	local tabl = {};
	local i = 1;
	for line in file:lines() do
		tabl[i] = {};
		local j = 1;
		for word in string.gmatch( line, "%S+" )  do		-- separate on " "
			tabl[i][j] = process( word );
			j = j + 1;
		end
		i = i + 1;
	end

	io.close( file );
	return tabl;
end

function process ( str )	-- separate word to instructions
	local pos = string.find( str, ">" );
	if pos == nil then
		pos = string.find( str, "|" );
		if pos == nil then 
			pos = string.find( str, '<' );
			if pos == nil then
				error ("Data format error in word: " .. str .. "\nFormat: {ai: 0 .. n}{cmd: <, |, >}{qi: 0 .. n}");
			end
		end
	end

	--print( str .. " = " .. string.sub( str, 1, pos-1) .. " " .. string.sub( str, pos, pos) .. " " .. string.sub( str, pos+1) );
	return { tonumber( string.sub( str, 1,    pos-1)	), 
							 string.sub( str, pos,  pos  ), 
				tonumber( string.sub( str, pos+1      )	)
			 };
end

function point_to ( pos )
	local out = '';
	for i = 1, pos-1 do 
		out = out .. " ";
	end
	print( out .. '^' );
end

function exists_machines (  )
	local file = io.open( "./machines.txt", "r" );	
	if not file then
		print "Can't open file \"machines.txt\". It should be at same file with \"Turing_machine.lua\".\n Or, it your first machine.";
		return {};
	end

	local list_of_machines = {};
	for line in file:lines() do
		table.insert( list_of_machines, line );
	end

	io.close( file );
	return list_of_machines;
end

function save_TM ( TM_image, machines )
	io.write "Turing machine formed.\n With what name I should save it?\n> ";
	local nam = io.read();

	for _, v in ipairs(machines) do
		if v == nam then
			print "This name is occupied. Do you want use it?\n 1. Yes\n 2. No";
			local choice = tonumber( io.read() );
			if choice == 1 then
				break;
			elseif choice == 0 then
				save_TM( TM_image, machines );
				return;
			else
				print ("Incorrect input: " .. choice);
				print "Should be \"1\" or \"0\"";
				save_TM( TM_image, machines );
				return;
			end
		end
	end

	local newTM_file = io.open( nam .. ".lua", 'w' );
	local nameList   = io.open( "./machines.txt", 'a');
	local TM_module_start = "local TM_module = {\n";
	local TM_module_middle = '';
	local TM_module_end   = "}; return TM_module";

	for _, row in ipairs( TM_image ) do
		TM_module_middle = TM_module_middle	.. '   {\n';
		for i, insturucton in ipairs( row ) do
			TM_module_middle = TM_module_middle .. '      { ';
			for _, el in ipairs( insturucton ) do
				TM_module_middle = TM_module_middle .. "'" .. el .. "', ";
			end
			TM_module_middle = TM_module_middle .. '},\n';
		end
		TM_module_middle = TM_module_middle .. '   },\n';
	end
	
	newTM_file:write( TM_module_start .. TM_module_middle .. TM_module_end );
	nameList:write( nam .. "\n" );
  
	--print( TM_module_start .. TM_module_middle .. TM_module_end );
	
	io.close( nameList );
	io.close( newTM_file );
end

function selectTM (  )
	local file = io.open( "./machines.txt", "r" );
	if file == nil then
		return false;
	end

	local ExistsMachine = {};
	for nam in file:lines() do
		table.insert( ExistsMachine, nam );
	end
	io.close( file );

	print "What machine you want to load (number)?";
	for i, nam in ipairs( ExistsMachine ) do
		print(i .. '.', nam);
	end
	print(  "0.\tCreate new with data from \"input.txt\"" );
	
	io.write "> ";
	local choice = io.read();
	choice = tonumber( choice );
	if choice == 0 then
		return false;
	elseif tonumber(choice) < 1 or choice > #ExistsMachine then
		print ("Select machine ( " .. choice .. " ) is incorrect. Form new machine from \"input.txt\"");
		return false;
	else
		return require ( ExistsMachine[ tonumber( choice ) ] );
	end
end

--====================| Program |====================--
local existsTm = selectTM();
if not existsTm then
	TM_rules = formTM ();
	save_TM( TM_rules, exists_machines() );
else
	TM_rules = existsTm; 
end

print "Input word for processing:";
word = io.read();
print "";

local state = 1; 		-- q1, initial state
local pos = #word;
local symbolR; 		-- read symbol (interpret as command at this step) 
local symbolW; 		-- write symbol (interpret at next step)
local movDir = '';	-- '<' - left, '>' - right, '|' - stay

repeat
	print(word, "q" .. state);
	point_to(pos);

	symbolR = tonumber( string.sub(word, pos, pos) ) or 0;
	symbolR = symbolR + 1; -- alphabet start on 0, Lua tables - 1
	symbolW = TM_rules[state][symbolR][1];
	--print("* ", state, pos, symbolR, symbolW )
	movDir   = TM_rules[state][symbolR][2];
	state    = tonumber( TM_rules[state][symbolR][3] );

	if pos == 0 then
		word = symbolW .. word;
		pos = 1;
	elseif pos > #word then
		word = word .. '0';
	else
		word = string.sub(word, 1, pos-1) .. symbolW .. string.sub(word, pos+1);
	end
	
	if movDir == '<' then
		pos = pos - 1;
	elseif movDir == '>' then
		pos = pos + 1;
	end

until state == 0

print(word, "q" .. state);
point_to(pos);
