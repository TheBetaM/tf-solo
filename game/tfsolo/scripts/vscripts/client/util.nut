function IncludeScript( name, scope = null )
{
	if ( scope == null )
	{
		scope = this;
	}
	return ::DoIncludeScript( name, scope );
}

//---------------------------------------------------------
function ClearGameEventCallbacks()
{
	::GameEventCallbacks <- {};
	::ScriptEventCallbacks <- {};
	::ScriptHookCallbacks <- {};
}

//---------------------------------------------------------
// Collect functions of the form OnGameEventXXX and store them in a table.
//---------------------------------------------------------
function __CollectEventCallbacks( scope, prefix, globalTableName, regFunc )
{
	if ( !(typeof( scope ) == "table" ) )
	{
		print( "__CollectEventCallbacks[" + prefix +"]: NOT TABLE! : " + typeof ( scope ) + "\n" );
		return;
	}

	if ( !(globalTableName in getroottable())  )
	{
		getroottable()[globalTableName] <- {};
	}
	local useTable = getroottable()[globalTableName] 
	foreach( key,value in scope )
	{
		if ( typeof( value ) == "function" )
		{
			if ( typeof( key ) == "string" && key.find( prefix, 0 ) == 0 )
			{
				local eventName = key.slice( prefix.len() ); 
				if ( eventName.len() > 0 )
				{
					// First time we've seen this event: Make an array for callbacks and
					// tell the game engine's listener we want to be notified.
					if ( !(eventName in useTable) )
					{
						useTable[eventName] <- [];
						if (regFunc)
							regFunc( eventName );
					}
					// Don't add duplicates. TODO: Perf on this...
					else if ( useTable[eventName].find( scope ) != null )
					{
						continue;
					}
					useTable[eventName].append( scope.weakref() );
				}
			}
		}
	}	
}

function __CollectGameEventCallbacks( scope )
{
	__CollectEventCallbacks( scope, "OnGameEvent_", "GameEventCallbacks", ::RegisterScriptGameEventListener )
	__CollectEventCallbacks( scope, "OnScriptEvent_", "ScriptEventCallbacks", null )
	__CollectEventCallbacks( scope, "OnScriptHook_", "ScriptHookCallbacks", ::RegisterScriptHookListener )
}

//---------------------------------------------------------
// Call all functions in the callback array for the given game event.
//---------------------------------------------------------
function __RunEventCallbacks( event, params, prefix, globalTableName, bWarnIfMissing )
{
	local useTable = getroottable()[globalTableName] 
	if ( !(event in useTable) )
	{
		if (bWarnIfMissing)
		    print( "__RunEventCallbacks[" + prefix + "]: Invalid 'event' name: " + event + ". No listeners registered for that event.\n" );
		return;
	}

	for ( local idx = useTable[event].len()-1; idx >= 0; --idx )
	{
		local funcName = prefix + event;
		if ( useTable[event][idx] == null )
		{
			//TODO: Not a great way to deal with cleanup...
			useTable[event].remove(idx);
		}
		else
		{
			//PERF TODO: This is a hash lookup for a function we know exists...
			// should be caching it off in CollectGameEventCallbacks.
			useTable[event][idx][funcName]( params );
		}
	}
}

function __RunGameEventCallbacks( event, params )
{
	__RunEventCallbacks( event, params, "OnGameEvent_", "GameEventCallbacks", true )
}

function __RunScriptHookCallbacks( event, params )
{
	__RunEventCallbacks( event, params, "OnScriptHook_", "ScriptHookCallbacks", false )
}

// kinda want to rename this "SendScriptEvent" - since we just send it to script
function FireScriptEvent( event, params )
{
	__RunEventCallbacks( event, params, "OnScriptEvent_", "ScriptEventCallbacks", false )
}

function UniqueString( string = "" )
{
	return DoUniqueString( string.tostring() );
}