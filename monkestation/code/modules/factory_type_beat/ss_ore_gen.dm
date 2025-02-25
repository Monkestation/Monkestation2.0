SUBSYSTEM_DEF(ore_generation)
	name = "Ore Generation"
	wait = 60 SECONDS
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME

	/// All ore vents that are currently producing boulders.
	var/list/obj/structure/ore_vent/processed_vents = list()
	/// All the ore vents that are currently in the game, not just the ones that are producing boulders.
	var/list/obj/structure/ore_vent/possible_vents = list()

/datum/controller/subsystem/ore_generation/Initialize()
	//Basically, we're going to round robin through the list of ore vents and assign a mineral to them until complete.

/datum/controller/subsystem/ore_generation/fire(resumed)
	to_chat(world, "Whoa oregen fired")
