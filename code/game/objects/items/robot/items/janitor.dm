/obj/item/borg/janitorial_vacuum_suite
	name = "janitorial vacuum suite"
	desc = "A module designed to compensate for your lack of hands by offloading your job onto your more squishy overlords."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "vacuum_suite"
	/// The hose item that will be offered when the cyborg is pulled.
	var/obj/item/janitorial_vacuum_hose/hose
	/// Should the hose item not be offered when the cyborg is pulled?
	var/locked = FALSE
	/// Has the hose item been deployed / taken by someone?
	var/deployed = FALSE

/obj/item/borg/janitorial_vacuum_suite/Initialize(mapload)
	. = ..()
	if(!iscyborg(loc))
		return INITIALIZE_HINT_QDEL
	hose = new(src)
	hose.vacuum_suite_weakref = WEAKREF(src)
	hose.AddComponent( \
		/datum/component/transforming, \
		force_on = hose.force, \
		hitsound_on = hose.hitsound, \
		w_class_on = hose.w_class, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("washed", "mopped", "scrubbed", "whacked", "bapped", "decontaminated"), \
		attack_verb_simple_on = list("wash", "mop", "scrub", "whack", "bap", "decontaminate"), \
		)
	hose.RegisterSignal(hose, COMSIG_TRANSFORMING_ON_TRANSFORM, TYPE_PROC_REF(/obj/item/janitorial_vacuum_hose, on_transform))
	AddComponent(/datum/component/borg_item_offered_when_pulled, loc)
	ADD_TRAIT(src, TRAIT_BORG_GIVE, REF(src))
	update_icon(UPDATE_OVERLAYS)

/obj/item/borg/janitorial_vacuum_suite/Destroy(force)
	if(deployed)
		hose.retract_hose()
	QDEL_NULL(hose)
	return ..()

/obj/item/borg/janitorial_vacuum_suite/attack_self(mob/user, modifiers)
	. = ..()
	if(deployed)
		hose.retract_hose()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/borg/janitorial_vacuum_suite/click_alt(mob/user)
	if(deployed)
		hose.retract_hose()
	locked = !locked
	update_icon(UPDATE_OVERLAYS)
	return CLICK_ACTION_SUCCESS

/obj/item/borg/janitorial_vacuum_suite/on_offered(mob/living/offerer, mob/living/carbon/offered)
	if(..())
		return
	if(hose.loc != src && !istype(hose.loc, /mob/living)) // Error handling.
		stack_trace("[src] has been offered with [hose] not present inside its contents or inside a mob's loc variable. Location: [isnull(loc) ? "NULLSPACE" : "[hose.loc], X: [hose.x], Y: [hose.y], Z:[hose.z]"]")
		deployed = FALSE
		hose.forceMove(src)
	if(locked || deployed)
		return TRUE
	if(!offered)
		offered = locate(/mob/living/carbon) in orange(1, offerer)
	if(offered && istype(offered))
		offerer.visible_message(
			span_notice("[offerer] extends the handle towards [offered] for their cleaning suite."),
			span_notice("The handle to your [src] extends towards [offered]'s hand."), null, 2)
	SET_PLANE_IMPLICIT(src, ABOVE_HUD_PLANE) // Handles issue where this item could be hidden underneath the offering alert.
	offerer.apply_status_effect(/datum/status_effect/offering, src, /atom/movable/screen/alert/give/borg, offered)
	return TRUE

/obj/item/borg/janitorial_vacuum_suite/on_offer_taken(mob/living/offerer, mob/living/taker)
	if(..())
		return TRUE
	taker.visible_message(
		span_notice("[taker] takes the [hose] from [offerer]."),
		span_notice("You take the [hose] from [offerer]"))
	hose.do_pickup_animation(taker, offerer)
	taker.put_in_hands(hose)
	hose.vaccum_beam = hose.generate_vaccum_beam(offerer, taker)
	hose.RegisterSignal(hose, COMSIG_ITEM_DROPPED, TYPE_PROC_REF(/obj/item/janitorial_vacuum_hose, on_drop))
	playsound(hose, 'sound/items/vacuum/vacuum_hose.ogg', 100, TRUE)
	deployed = TRUE
	update_icon(UPDATE_OVERLAYS)
	offerer.remove_status_effect(/datum/status_effect/offering)
	return TRUE

/obj/item/borg/janitorial_vacuum_suite/update_overlays()
	. = ..()
	if(deployed)
		. += "vacuum_suite_on"
	else
		. += "vacuum_suite_wand"
	if(locked)
		. += "vacuum_suite_locked"

/obj/item/borg/janitorial_vacuum_suite/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to <b>[locked ? "unlock" : "lock"]</b> the [src].")

/obj/item/janitorial_vacuum_hose
	name = "janitorial floor cleaner"
	desc = "This is the working end of an industrial cleaner that someone unfortunately gave sapience."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "vacuum-wand"
	inhand_icon_state = "vacuum-wand"
	righthand_file = 'icons/mob/inhands/items/vacuum_wand_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/items/vacuum_wand_lefthand.dmi'
	hitsound = SFX_SWING_HIT
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = INDESTRUCTIBLE // To prevent fuckery and a broken borg module.
	attack_verb_continuous = list("sucked", "vacuumed", "smacked", "forcefully dusted off", "beaten")
	attack_verb_simple = list("suck", "vacuum", "smack", "dust off", "beat")
	force = 12
	/// The weakref to the vacuum suite that we belong to.
	var/datum/weakref/vacuum_suite_weakref
	/// The trash bag where vacuumed items will be inserted into.
	var/obj/item/storage/bag/trash/bag
	/// The beam that visualizes the connection between the user's hand and the cyborg's vacuum suite.
	var/datum/beam/held/vacuum/vaccum_beam
	/// Should it be cleaning the floor (TRUE) or vacuuming items from the floor (FALSE)?
	var/cleaning = FALSE

/obj/item/janitorial_vacuum_hose/Destroy(force)
	if(vaccum_beam)
		QDEL_NULL(vaccum_beam)
	bag = null
	return ..()

/obj/item/janitorial_vacuum_hose/examine(mob/user)
	. = ..()
	. += span_notice("<b>Interact</b> to switch to [cleaning ? "<b>vacuum</b>" : "<b>cleaning</b>"] mode.")

/obj/item/janitorial_vacuum_hose/interact_with_atom(obj/item/thing, mob/living/user, list/modifiers)
	. = ..()
	if(!istype(thing))
		return NONE
	if(cleaning)
		return NONE
	if(thing.anchored || thing.w_class >= WEIGHT_CLASS_BULKY)
		return NONE
	if(QDELETED(bag) && !autoset_bag()) // Catches if the janitor cyborg exchanged their bag while the hose is still being used.
		retract_hose()
		return NONE
	playsound(bag, 'sound/items/vacuum/vacuum_use.ogg', 20, TRUE)
	for(var/obj/item/I in get_turf(thing))
		if(!istype(I, thing.type))
			continue
		if(!do_after(user, 0.1 SECONDS, user, progress = FALSE))
			break
		if(QDELETED(bag))
			break
		if(bag.atom_storage.attempt_insert(I, user, FALSE))
			continue
		break

/// Automatically finds and sets the trash bag for the hose to use.
/obj/item/janitorial_vacuum_hose/proc/autoset_bag()
	var/obj/item/borg/janitorial_vacuum_suite/vacuum_suite = vacuum_suite_weakref?.resolve()
	if(!vacuum_suite)
		stack_trace("[src] failed to resolve their vacuum suite.")
		return FALSE
	var/mob/living/silicon/robot/cyborg_holder
	if(iscyborg(vacuum_suite.loc))
		cyborg_holder = vacuum_suite.loc
	else if(istype(vacuum_suite.loc, /obj/item/robot_model))
		var/obj/item/robot_model/cyborg_model = vacuum_suite.loc
		cyborg_holder = cyborg_model.cyborg_owner
	if(!cyborg_holder)
		stack_trace("[src] failed to resolve the cyborg holder.")
		return FALSE
	bag = (loc == cyborg_holder) ? pick(cyborg_holder.get_all_contents_type(/obj/item/storage/bag/trash)) : locate(/obj/item/storage/bag/trash) in cyborg_holder.model.usable_modules
	if(!bag)
		stack_trace("[src] failed to find any trash bags.")
		return FALSE
	return TRUE

/// Transforms the item between clean mode and vaccum mode.
/obj/item/janitorial_vacuum_hose/proc/on_transform(obj/item/source, mob/living/user, active)
	SIGNAL_HANDLER

	cleaning = !cleaning
	if(!user)
		return COMPONENT_NO_DEFAULT_MESSAGE
	playsound(src, 'sound/items/vacuum/vacuum_clack.ogg', 30, TRUE)
	if(cleaning) // CLEAN_SCRUB because if you get a cyborg to help you clean up a crime, you deserve to win.
		balloon_alert(user, "cleaning")
		AddComponent( \
			/datum/component/cleaner, \
			base_cleaning_duration = 1 SECONDS, \
			pre_clean_callback = CALLBACK(src, PROC_REF(clean_sound)), \
			)
	else
		balloon_alert(user, "vacuuming")
		qdel(GetComponent(/datum/component/cleaner))
	return COMPONENT_NO_DEFAULT_MESSAGE

/// Plays the sound when cleaning something.
/obj/item/janitorial_vacuum_hose/proc/clean_sound()
	playsound(src, 'sound/items/vacuum/vacuum_steam.ogg', 10, TRUE)
	return CLEAN_ALLOWED

/// Retracts the item back into the vacuum suite.
/obj/item/janitorial_vacuum_hose/proc/retract_hose()
	var/obj/item/borg/janitorial_vacuum_suite/vacuum_suite = vacuum_suite_weakref?.resolve()
	if(!vacuum_suite)
		return  // Occurs when the suite is deleted (which means we'll be deleted soon too).
	if(loc == vacuum_suite)
		return
	do_pickup_animation(vacuum_suite, get_turf(src))
	forceMove(vacuum_suite)
	playsound(vacuum_suite, 'sound/items/vacuum/vacuum_ploop.ogg', 100)
	if(!isnull(vaccum_beam) && !QDELING(vaccum_beam))
		balloon_alert_to_viewers("snap")
		QDEL_NULL(vaccum_beam)
	bag = null
	vacuum_suite.deployed = FALSE
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	vacuum_suite.update_icon(UPDATE_OVERLAYS)

/// Generates the beam between the user's hand (taker) and the cyborg's vacuum suite (offerer).
/obj/item/janitorial_vacuum_hose/proc/generate_vaccum_beam(mob/living/offerer, mob/living/taker)
	var/datum/beam/held/vacuum/generated_vaccum_beam = new(taker, offerer, icon_state = "hosebeam", max_distance = 7, emissive = FALSE, beam_layer = BELOW_MOB_LAYER)
	var/index = taker.get_held_index_of_item(src)
	generated_vaccum_beam.lefthand = IS_LEFT_INDEX(index)
	INVOKE_ASYNC(generated_vaccum_beam, TYPE_PROC_REF(/datum/beam, Start))
	RegisterSignal(generated_vaccum_beam, COMSIG_QDELETING, PROC_REF(retract_hose))
	RegisterSignal(generated_vaccum_beam, COMSIG_BEAM_BEFORE_DRAW, PROC_REF(on_update))
	return generated_vaccum_beam

/// Updates the position of the beam whenever the user moves or turns.
/obj/item/janitorial_vacuum_hose/proc/on_update()
	SIGNAL_HANDLER
	var/mob/living/mob = vaccum_beam.origin
	if(istype(mob))
		var/index = mob.is_holding(src)
		vaccum_beam.lefthand = IS_LEFT_INDEX(index)
	if(prob(10))
		playsound(src, 'sound/items/vacuum/vacuum_hose.ogg', 50, TRUE)

/// Retracts the hose when it is dropped.
/obj/item/janitorial_vacuum_hose/proc/on_drop(obj/item/vacuum, mob/living/user)
	SIGNAL_HANDLER
	if(user == loc)
		return
	retract_hose()

/datum/beam/held/vacuum
	righthand_s_px = -7
	righthand_s_py = -3

	righthand_e_px = 0
	righthand_e_py = -6

	righthand_w_px = -3
	righthand_w_py = -6

	righthand_n_px = 8
	righthand_n_py = -6

	lefthand_s_px = 7
	lefthand_s_py = -3

	lefthand_e_px = 3
	lefthand_e_py = -6

	lefthand_w_px = 0
	lefthand_w_py = -6

	lefthand_n_px = -8
	lefthand_n_py = -6
