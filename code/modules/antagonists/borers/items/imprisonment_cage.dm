/obj/item/pet_carrier/small/borer
	name = "borer capture carrier"
	desc = "A small pet carrier for miniature sized animals. Equipped with a locking mechanism built into the lid and a trapping system meant for borers."
	allows_locking = TRUE
	/// The radio that is inserted into the trap, if any
	var/obj/item/radio/internal_radio = null
	/// The cooldown for us catching borers
	COOLDOWN_DECLARE(catch_cooldown)

/obj/item/pet_carrier/small/borer/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(spring_trap),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/pet_carrier/small/borer/examine(mob/user)
	. = ..()
	if(isnull(internal_radio))
		. += span_notice("You could [span_bold("Left-Click")] onto it with a radio device to attach it.")
	else
		. += span_notice("It has [internal_radio] attached onto its inside, you can use a [span_bold("Crowbar")] to detach it.")
	. += span_notice("While on the ground its trapping mechanism will capture any borers stepping on it.")
	if(!COOLDOWN_FINISHED(src, catch_cooldown))
		. += span_notice("Its trapping mechanism is currently recharging.")

/obj/item/pet_carrier/small/borer/Destroy(force)
	internal_radio = null // It'll get deleted due to being in our contents anyway
	return ..()

/obj/item/pet_carrier/small/borer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/radio))
		if(istype(tool, /obj/item/radio/headset))
			to_chat(user, span_notice("[tool] doesn't fit into [src]'s radio slot."))
			return ITEM_INTERACT_BLOCKING

		tool.forceMove(src)
		user.visible_message(span_notice("[user] attaches [tool] to [src] with a click."), span_notice("You attach [tool] to the [src]."), span_notice("You hear a clicking sound."))
		internal_radio = tool
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/pet_carrier/small/borer/crowbar_act(mob/living/user, obj/item/tool)
	if(isnull(internal_radio))
		return ITEM_INTERACT_BLOCKING

	internal_radio.forceMove(drop_location())
	user.visible_message(span_notice("[internal_radio] pops off [src]."), span_notice("You pop off [internal_radio] from [src]."), span_notice("You hear a clicking sound then a loud metallic thunk."))
	internal_radio = null
	return ITEM_INTERACT_SUCCESS

/obj/item/pet_carrier/small/borer/load_occupant(mob/living/user, mob/living/target)
	if(!iscorticalborer(target))
		to_chat(user, span_warning("[target] is too big to put into [src]!"))
	return ..()

/obj/item/pet_carrier/small/borer/remove_occupant(mob/living/occupant, turf/new_turf)
	COOLDOWN_START(src, catch_cooldown, 10 SECONDS)
	return ..()

/obj/item/pet_carrier/small/borer/get_escape_time(mob/living/basic/cortical_borer/user)
	if(istype(user) && user.upgrade_flags & BORER_ENERGIC)
		return rand(20 SECONDS, 30 SECONDS)
	return rand(30 SECONDS, 40 SECONDS)

/obj/item/pet_carrier/small/borer/proc/spring_trap(datum/source, mob/living/basic/cortical_borer/borer)
	SIGNAL_HANDLER
	//it will only trigger on a cortical borer, and it has to be open
	if(!istype(borer) || !open || locked || occupants.len >= max_occupants || !COOLDOWN_FINISHED(src, catch_cooldown))
		return
	borer.visible_message(span_warning("[src]'s lid snaps shut!"), span_userdanger("[src]'s lid snaps shut, locking you inside!"), span_notice("You hear a vacuuming sound."))
	open = FALSE
	locked = TRUE
	add_occupant(borer)
	playsound(src, close_sound, 30, TRUE)
	update_appearance()
	if(internal_radio)
		var/area/src_area = get_area(src)
		internal_radio.talk_into(src, "A cortical borer has been trapped in [src_area].", RADIO_CHANNEL_COMMON)
