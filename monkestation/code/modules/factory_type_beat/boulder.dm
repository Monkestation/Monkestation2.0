/**
 * The objects that ore vents produce, which is refined into minerals.
 */
/obj/item/boulder
	name = "boulder"
	desc = "This rocks."
	icon_state = "ore"
	icon = 'monkestation/code/modules/factory_type_beat/icons/ore.dmi'

	/// When a refinery machine is working on this boulder, we'll set this. Re reset when the process is finished, but the boulder may still be refined/operated on further.
	var/obj/machinery/processed_by = null
	/// How many steps of refinement this boulder has gone through. Starts at 5-8, goes down one each machine process.
	var/durability = 5
	/// What was the size of the boulder when it was spawned? This is used for inheiriting the icon_state.
	var/boulder_size = BOULDER_SIZE_SMALL

/obj/item/boulder/Destroy(force)
	SSore_generation.available_boulders -= src
	processed_by = null
	return ..()

/// Moves boulder contents to the drop location, and then deletes the boulder.
/obj/item/boulder/proc/break_apart()
	if(length(contents))
		var/list/quips = list("Clang!", "Crack!", "Bang!", "Clunk!", "Clank!")
		visible_message(span_notice("[pick(quips)] Something falls out of \the [src]!"))
		playsound(loc, 'sound/effects/picaxe1.ogg', 60, FALSE)
		for(var/obj/item/content as anything in contents)
			content.forceMove(get_turf(src))
	qdel(src)
