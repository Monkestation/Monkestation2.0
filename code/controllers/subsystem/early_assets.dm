/// Initializes any assets that need to be loaded ASAP.
/// This houses preference menu assets, since they can be loaded at any time,
/// most dangerously before the atoms SS initializes.
/// Thus, we want it to fail consistently in CI as if it would've if a player
/// opened it up early.
SUBSYSTEM_DEF(early_assets)
	name = "Early Assets"
	init_order = INIT_ORDER_EARLY_ASSETS
	flags = SS_NO_FIRE

/datum/controller/subsystem/early_assets/Initialize()
	for (var/datum/asset/asset_type as anything in subtypesof(/datum/asset))
		if (asset_type::_abstract == asset_type)
			continue

		if (!asset_type::early)
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

		CHECK_TICK

	return SS_INIT_SUCCESS
