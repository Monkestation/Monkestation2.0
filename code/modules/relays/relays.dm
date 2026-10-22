// Originally ported from Iris Station, but added toml config support.
GLOBAL_VAR(relay_config)

/client/verb/go2relay()
	set category = "OOC"
	set name = "Internet Routing Relays"

	if(is_localhost())
		to_chat(src, span_notice("You are on localhost, this verb is useless to you."))
		return

	if(!GLOB.relay_config || !length(GLOB.relay_config))
		to_chat(src, span_notice("Relay configuration is missing or empty."))
		return

	var/list/names = list()
	var/list/name_to_relay = list()

	for(var/list/relay in GLOB.relay_config)
		var/name = relay["name"]
		names += name
		name_to_relay[name] = relay

	var/choice = tgui_input_list(src,	"Which relay do you wish to use? Relays can help improve ping for some users.",	"Relay Select",	names)
	if(!choice)
		to_chat(src, span_notice("You didn't select a relay."))
		return

	var/list/relay = name_to_relay[choice]
	if(!relay)
		to_chat(src, span_notice("Invalid relay selection."))
		return

	var/address = relay["address"]
	address = replacetext(address, "{port}", "[world.port]")

	var/quickname = relay["quickname"]

	to_chat_immediate(
		target = src,
		html = boxed_message(span_info(span_big("Connecting you to [quickname]\nIf nothing happens, try manually connecting to the relay ([address]), or the RELAY may be down!"))),
		type = MESSAGE_TYPE_INFO,
	)
	src << link(address)
