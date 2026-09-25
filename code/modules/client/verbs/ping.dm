GAME_VERB_HIDDEN_INSTANT(/client, update_ping, ".update_ping", time as num)
	var/ping = pingfromtime(time)
	lastping = ping
	if (!avgping)
		avgping = ping
	else
		avgping = MC_AVERAGE_SLOW(avgping, ping)

/client/proc/pingfromtime(time)
	return ((world.time+world.tick_lag*TICK_USAGE_REAL/100)-time)*100

GAME_VERB_HIDDEN_INSTANT(/client, display_ping, ".display_ping", time as num)
	to_chat(src, span_notice("Round trip ping took [round(pingfromtime(time),1)]ms"))

GAME_VERB(/client, ping, "Ping", "OOC")
	winset(src, null, "command=.display_ping+[world.time+world.tick_lag*TICK_USAGE_REAL/100]")
