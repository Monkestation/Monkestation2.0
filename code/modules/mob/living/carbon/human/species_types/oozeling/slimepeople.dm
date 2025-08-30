////////////////////////////////////////////////////////SLIMEPEOPLE///////////////////////////////////////////////////////////////////

//Slime people are able to split like slimes, retaining a single mind that can swap between bodies at will, even after death.

GLOBAL_DATUM_INIT(slimeperson_managers, /alist, alist())

/datum/species/oozeling/slime
	name = "\improper Slimeperson"
	plural_form = "Slimepeople"
	id = SPECIES_SLIMEPERSON
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_SPLEENLESS_METABOLISM,
		// Jank prevention
		TRAIT_NO_MINDSWAP,
		TRAIT_NO_TRANSFORMATION_STING,
	)
	hair_color = "mutcolor"
	hair_alpha = 150
	facial_hair_alpha = 150
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/oozeling/slime,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/oozeling/slime,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/oozeling/slime,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/oozeling/slime,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/oozeling/slime,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/oozeling/slime,
	)

	extra_actions = list(
		/datum/action/innate/swap_body,
		/datum/action/innate/split_body,
	)

	/// The manager instance used to link all of someone's slimeperson bodies.
	var/datum/slimeperson_manager/manager
	/// If TRUE, then the next `spec_life` will ensure that the slime body is added to the manager, if there is one.
	/// Mostly a simple workaround for ensuring cloned/recreated bodies are properly linked.
	var/needs_manager_update = FALSE

/datum/species/oozeling/slime/Destroy(force)
	manager = null
	return ..()

/datum/species/oozeling/slime/on_species_gain(mob/living/carbon/slime, datum/species/old_species)
	. = ..()
	if(slime.mind && isnull(manager))
		manager = GLOB.slimeperson_managers[slime.mind]
		if(isnull(manager)) // initialize a manager if one doesn't exist I guess
			manager = new(slime.mind)
	manager?.add_body(slime)

/datum/species/oozeling/slime/on_species_loss(mob/living/carbon/slime)
	manager?.remove_body(slime)
	return ..()

/datum/species/oozeling/slime/spec_death(gibbed, mob/living/carbon/human/slime)
	if(manager && slime.mind?.active)
		var/list/available_bodies = manager.get_available_bodies() - slime
		if(length(available_bodies))
			manager.swap_to_dupe(pick(available_bodies))
	return ..()

//If you're cloned you get your body pool back
/datum/species/oozeling/slime/copy_properties_from(datum/species/oozeling/slime/old_species)
	manager = old_species.manager
	needs_manager_update = TRUE

/datum/species/oozeling/slime/spec_life(mob/living/carbon/human/slime, seconds_per_tick, times_fired)
	if(IS_BLOODSUCKER(slime))
		return ..()
	if(needs_manager_update && manager)
		manager.add_body(slime)
		needs_manager_update = FALSE
	if(slime.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		if(SPT_PROB(2.5, seconds_per_tick))
			to_chat(slime, span_notice("You feel very bloated!"))
		var/datum/action/innate/split_body/split_body = locate() in actions_given
		split_body?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	else if(slime.nutrition >= NUTRITION_LEVEL_WELL_FED)
		slime.blood_volume += 1.5 * seconds_per_tick
		if(slime.blood_volume <= (BLOOD_VOLUME_NORMAL - 10))
			slime.adjust_nutrition(-1.25 * seconds_per_tick)
	return ..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/split_body/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/owner = src.owner
	if(!ishuman(owner) || IS_BLOODSUCKER(owner))
		return FALSE
	if(owner.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		return TRUE
	return FALSE

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/user = owner
	if(!isslimeperson(user))
		return
	CHECK_DNA_AND_SPECIES(user)
	user.visible_message(
		span_notice("[owner] gains a look of concentration while standing perfectly still."),
		span_notice("You focus intently on moving your body while standing perfectly still..."),
	)

	if(do_after(owner, delay = 6 SECONDS, target = owner, timed_action_flags = IGNORE_HELD_ITEM))
		if(user.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(user, span_warning("...but there is not enough of you to go around! You must attain more mass to split!"))
	else
		to_chat(user, span_warning("...but fail to stand perfectly still!"))

	REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))

/datum/action/innate/split_body/proc/make_dupe()
	var/mob/living/carbon/human/user = owner
	CHECK_DNA_AND_SPECIES(user)

	var/mob/living/carbon/human/spare = new /mob/living/carbon/human(user.loc)

	spare.underwear = "Nude"
	user.dna.copy_dna(spare.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
	var/datum/color_palette/generic_colors/palette = spare.dna.color_palettes[/datum/color_palette/generic_colors]
	palette.mutant_color = "#[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.updateappearance(mutcolor_update = TRUE)
	spare.domutcheck()
	spare.Move(get_step(user.loc, GLOB.cardinals))

	var/datum/component/nanites/owner_nanites = user.GetComponent(/datum/component/nanites)
	if(owner_nanites)
		//copying over nanite programs/cloud sync with 50% saturation in host and spare
		owner_nanites.nanite_volume *= 0.5
		spare.AddComponent(/datum/component/nanites, owner_nanites.nanite_volume)
		SEND_SIGNAL(spare, COMSIG_NANITE_SYNC, owner_nanites, TRUE, TRUE) //The trues are to copy activation as well

	user.blood_volume *= 0.45
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))

	var/datum/species/oozeling/slime/origin_datum = user.dna.species
	origin_datum.manager.add_body(spare)

	user.transfer_quirk_datums(spare)
	user.mind.transfer_to(spare)
	spare.visible_message(
		span_warning("[user] distorts as a new body \"steps out\" of [user.p_them()]."),
		span_notice("...and after a moment of disorentation, you're besides yourself!"),
	)


/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = NONE
	button_icon_state = "slimeswap"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/swap_body/IsAvailable(feedback)
	return ..() && !IS_BLOODSUCKER(owner)

/datum/action/innate/swap_body/Activate()
	var/datum/species/oozeling/slime/slime = astype(astype(owner, /mob/living/carbon/human)?.dna?.species)
	if(isnull(slime))
		to_chat(owner, span_warning("You are not a slimeperson."))
		Remove(owner)
		return
	slime.manager?.ui_interact(owner)

/// Datum to manage multiple slimeperson bodies.
/datum/slimeperson_manager
	/// The mind that owns all the bodies.
	var/datum/mind/owner
	/// List of bodies in the
	var/list/bodies = list()

/datum/slimeperson_manager/New(datum/mind/owner)
	if(!isnull(GLOB.slimeperson_managers[owner]))
		CRASH("Attempted to create a [type] for a mind that already has one!")
	src.owner = owner
	GLOB.slimeperson_managers[owner] = src

/datum/slimeperson_manager/Destroy(force)
	if(!force && !QDELETED(owner))
		. = QDEL_HINT_LETMELIVE
		CRASH("/datum/slimeperson_manager should not be deleted under most circumstances!")
	if(!isnull(owner))
		GLOB.slimeperson_managers -= owner
		owner = null
	bodies.Cut()
	return ..()

/datum/slimeperson_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeBodySwapper", "Split Body")
		ui.open()

/datum/slimeperson_manager/ui_state(mob/user)
	return GLOB.always_state

/datum/slimeperson_manager/ui_host(mob/user)
	return owner?.current || ..()

/datum/slimeperson_manager/ui_data(mob/user)
	. = list("bodies" = list())
	for(var/mob/living/carbon/human/body as anything in bodies)
		if(QDELETED(body) || !isslimeperson(body))
			continue

		var/stat = "error"
		switch(body.stat)
			if(CONSCIOUS)
				stat = "Conscious"
			if(SOFT_CRIT to HARD_CRIT) // Also includes UNCONSCIOUS
				stat = "Unconscious"
			if(DEAD)
				stat = "Dead"

		var/occupied
		if(body == user)
			occupied = "owner"
		else if(body.mind?.active)
			occupied = "stranger"
		else
			occupied = "available"

		var/button
		if(occupied == "owner")
			button = "selected"
		else if(occupied == "stranger")
			button = "danger"
		else if(can_swap(body))
			button = null
		else
			button = "disabled"

		.["bodies"] += list(list(
			"htmlcolor" = astype(body.dna.color_palettes[/datum/color_palette/generic_colors], /datum/color_palette/generic_colors)?.mutant_color,
			"area" = get_area_name(body, TRUE),
			"status" = stat,
			"exoticblood" = body.blood_volume,
			"name" = body.real_name || body.name,
			"ref" = REF(body),
			"occupied" = occupied,
			"swap_button_state" = button,
			"swappable" = (occupied == "available") && can_swap(body),
		))

/datum/slimeperson_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("swap")
			var/mob/living/carbon/human/selected = locate(params["ref"]) in bodies
			if(can_swap(selected)) // these two procs have all the required sanity checks
				swap_to_dupe(selected)
			return TRUE

/datum/slimeperson_manager/proc/can_swap(mob/living/carbon/human/dupe)
	var/mob/living/carbon/human/owner = src.owner?.current

	if(QDELETED(dupe)) //Is there a body?
		remove_body(dupe)
		return FALSE

	if(!isslimeperson(owner))
		return FALSE

	if(!isslimeperson(dupe)) //Is it a slimeperson?
		remove_body(dupe)
		return FALSE

	if(dupe.stat != CONSCIOUS) //Is it awake?
		return FALSE

	if(dupe.mind?.active) //Is it unoccupied?
		return FALSE

	if(!(dupe in bodies)) //Do we actually own it?
		return FALSE

	return TRUE

/datum/slimeperson_manager/proc/swap_to_dupe(mob/living/carbon/human/dupe)
	if(!can_swap(dupe)) //sanity check
		return
	var/mob/living/current = owner.current
	if(current.stat == CONSCIOUS)
		current.visible_message(span_notice("[current] stops moving and starts staring vacantly into space."), span_notice("You stop moving this body..."))
	else
		to_chat(current, span_notice("You abandon this body..."))
	current.transfer_quirk_datums(dupe)
	owner.transfer_to(dupe)
	dupe.visible_message(span_notice("[dupe] blinks and looks around."), span_notice("...and move this one instead."))

/datum/slimeperson_manager/proc/add_body(mob/living/carbon/human/new_body)
	if(!isslimeperson(new_body) || QDELING(new_body))
		return FALSE
	if(new_body in bodies)
		return TRUE
	var/datum/species/oozeling/slime/slime = new_body.dna.species
	if(slime.manager && slime.manager != src)
		slime.manager.remove_body(new_body)
	RegisterSignals(new_body, list(COMSIG_QDELETING, COMSIG_SPECIES_LOSS), PROC_REF(remove_body))
	bodies += new_body
	slime.needs_manager_update = FALSE
	slime.manager = src
	SStgui.update_uis(src)
	return TRUE

/datum/slimeperson_manager/proc/remove_body(mob/living/carbon/human/body)
	SIGNAL_HANDLER
	if(isnull(body) || !(body in bodies))
		return
	bodies -= body
	UnregisterSignal(body, list(COMSIG_QDELETING, COMSIG_SPECIES_LOSS))
	SStgui.update_uis(src)
	var/datum/species/oozeling/slime/slime = astype(body.dna?.species)
	if(!slime)
		return
	if(slime.manager == src)
		slime.manager = null
	slime.needs_manager_update = FALSE

/datum/slimeperson_manager/proc/get_available_bodies()
	. = list()
	for(var/body in bodies)
		if(can_swap(body))
			. += body
