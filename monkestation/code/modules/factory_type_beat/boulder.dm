/**
 * The objects that ore vents produce, which is refined into minerals.
 */
/obj/item/boulder
	name = "boulder"
	desc = "This rocks."
	icon_state = "ore"
	icon = 'monkestation/code/modules/factory_type_beat/icons/ore.dmi'

	///When a refinery machine is working on this boulder, we'll set this. Re reset when the process is finished, but the boulder may still be refined/operated on further.
	var/obj/machinery/processed_by = null
	/// How many steps of refinement this boulder has gone through. Starts at 5-8, goes down one each machine process.
	var/durability = 5
	/// What was the size of the boulder when it was spawned? This is used for inheiriting the icon_state.
	var/boulder_size = BOULDER_SIZE_SMALL

/obj/item/boulder/artifact


/obj/item/boulder/proc/break_apart()
