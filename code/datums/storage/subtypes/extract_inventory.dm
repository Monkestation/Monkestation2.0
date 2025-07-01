/datum/storage/extract_inventory
	max_total_storage = WEIGHT_CLASS_TINY * 3
	max_slots = 3
	insert_preposition = "in"
	attack_hand_interact = FALSE
	quickdraw = FALSE
	locked = TRUE
	rustle_sound = FALSE
	silent = TRUE

/datum/storage/extract_inventory/New()
	. = ..()
	set_holdable(/obj/item/food/monkeycube)

	if(!istype(parent, /obj/item/slimecross/reproductive))
		stack_trace("storage subtype extract_inventory incompatible with [parent]")
		qdel(src)

/datum/storage/extract_inventory/proc/processCubes(mob/user)
	if(parent.contents.len >= max_slots)
		QDEL_LIST(parent.contents)
		createExtracts(user)

/datum/storage/extract_inventory/proc/createExtracts(mob/user)
	var/obj/item/slimecross/reproductive/slime_parent = parent
	if(!istype(slime_parent))
		return

	var/cores = rand(1,4)
	playsound(slime_parent, 'sound/effects/splat.ogg', 40, TRUE)
	slime_parent.last_produce = world.time
	to_chat(user, span_notice("[slime_parent] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!"))
	for(var/i in 1 to cores)
		new slime_parent.extract_type(slime_parent.drop_location())
