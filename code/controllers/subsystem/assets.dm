SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = INIT_ORDER_ASSETS
	flags = SS_NO_FIRE
	var/list/datum/asset_cache_item/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/OnConfigLoad()
	var/newtransporttype = /datum/asset_transport
	switch (CONFIG_GET(string/asset_transport))
		if ("webroot")
			newtransporttype = /datum/asset_transport/webroot

	if (newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype ()
	if (newtransport.validate_config())
		transport = newtransport
	transport.Load()



/datum/controller/subsystem/assets/Initialize()
	for(var/datum/asset/asset_type as anything in typesof(/datum/asset))
		if (asset_type == asset_type::_abstract)
			continue

		if (asset_type::early)
			continue

		var/pre_init = REALTIMEOFDAY
		var/list/typepath_split = splittext("[asset_type]", "/")
		var/typepath_readable = capitalize(replacetext(typepath_split[length(typepath_split)], "_", " "))

		SStitle.add_init_text(asset_type, "> [typepath_readable]", "<font color='yellow'>CREATING...</font>")
		if (load_asset_datum(asset_type))
			var/time = (REALTIMEOFDAY - pre_init) / (1 SECONDS)
			if(time <= 0.1)
				SStitle.remove_init_text(asset_type)
			else
				SStitle.add_init_text(asset_type, "> [typepath_readable]", "<font color='green'>DONE</font>", time)
		else
			stack_trace("Could not initialize early asset [asset_type]!")
			SStitle.add_init_text(asset_type, "> [typepath_readable]", "<font color='red'>FAILED</font>")

	transport.Initialize(cache)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload
