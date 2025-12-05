#define GAUZE_OVERLAY_COLOR "#2aa9d7"
#define IMPROVISED_GAUZE_OVERLAY_COLOR "#93acb5"
#define PLASTISEAL_OVERLAY_COLOR "#86d8be"


/**
 * apply_gauze() is used to- well, apply gauze to a bodypart
 *
 * As of the Wounds 2 PR, all bleeding is now bodypart based rather than the old bleedstacks system, and 90% of standard bleeding comes from flesh wounds (the exception is embedded weapons).
 * The same way bleeding is totaled up by bodyparts, gauze now applies to all wounds on the same part. Thus, having a slash wound, a pierce wound, and a broken bone wound would have the gauze
 * applying blood staunching to the first two wounds, while also acting as a sling for the third one. Once enough blood has been absorbed or all wounds with the ACCEPTS_GAUZE flag have been cleared,
 * the gauze falls off.
 *
 * Arguments:
 * * gauze- Just the gauze stack we're taking a sheet from to apply here
 */
/obj/item/bodypart/proc/apply_gauze(obj/item/stack/medical/gauze/new_gauze)
	if(!istype(new_gauze) || !new_gauze.absorption_capacity || !new_gauze.use(1))
		return
	if(!isnull(current_gauze))
		remove_gauze(drop_location())

	current_gauze = new new_gauze.type(src, 1)
	current_gauze.used = TRUE
	current_gauze.worn_icon_state = "[body_zone][rand(2, 3)]"
	if(can_bleed() && (generic_bleedstacks || cached_bleed_rate))
		current_gauze.add_mob_blood(owner)
		if(!QDELETED(new_gauze))
			new_gauze.add_mob_blood(owner)
	SEND_SIGNAL(src, COMSIG_BODYPART_GAUZED, current_gauze, new_gauze)
	owner.update_bandage_overlays()

/obj/item/bodypart/proc/check_gauze_removal(burn, brute)
	if(!current_gauze)
		return
	if(burn >= 15)
		owner.visible_message(span_warning("\The [current_gauze.name] on [owner]'s [name] burns away!"), span_warning("The [current_gauze.name] on your [parse_zone(body_zone)] burns away!"))
		playsound(current_gauze, 'sound/effects/wounds/sizzle2.ogg', 70, vary = TRUE)
		var/obj/effect/decal/cleanable/ash/ash = new(drop_location())
		ash.desc += " It looks like it used to be some kind of bandage."
		remove_gauze()
		return
	if(brute >= 10 || burn >= 10)
		owner.visible_message(span_warning("\The [current_gauze.name] on [owner]'s [name] comes loose!"), span_warning("The [current_gauze.name] on your [parse_zone(body_zone)] comes loose!"))
		remove_gauze(drop_location())
		return

/obj/item/bodypart/proc/remove_gauze(atom/remove_to)
	SEND_SIGNAL(src, COMSIG_BODYPART_UNGAUZED, current_gauze)
	if(remove_to)
		current_gauze.forceMove(remove_to)
	else
		QDEL_NULL(current_gauze)
		owner.update_bandage_overlays()
		return
	if(can_bleed() && (generic_bleedstacks || cached_bleed_rate))
		current_gauze.add_mob_blood(owner)
	current_gauze.worn_icon_state = initial(current_gauze.worn_icon_state)
	current_gauze.update_appearance()
	. = current_gauze
	if(current_gauze.sanitization)
		current_gauze.sanitization = current_gauze.sanitization * 0.25
	current_gauze.update_appearance(UPDATE_NAME)
	current_gauze = null
	owner.update_bandage_overlays()
	return .

/**
 * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
 *
 * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages falls off and we're left with nothing.
 *
 * Arguments:
 * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
 */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	current_gauze.update_appearance(UPDATE_NAME)
	if(current_gauze.absorption_capacity > 0)
		return
	owner.visible_message(
		span_danger("[current_gauze] on [owner]'s [name] falls away in rags."),
		span_warning("[current_gauze] on your [name] falls away in rags."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	remove_gauze(drop_location())

/**
 * Helper for someone helping to remove our gauze
 */
/obj/item/bodypart/proc/help_remove_gauze(mob/living/helper)
	if(!istype(helper))
		return
	if(helper.incapacitated())
		return
	if(!helper.can_perform_action(owner, NEED_HANDS|FORBID_TELEKINESIS_REACH)) // telekinetic removal can be added later
		return

	var/whose = helper == owner ? "your" : "[owner]'s"
	helper.visible_message(
		span_notice("[helper] starts carefully removing [current_gauze] from [whose] [plaintext_zone]."),
		span_notice("You start carefully removing [current_gauze] from [whose] [plaintext_zone]..."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	helper.balloon_alert(owner, "removing gauze...")

	if(!do_after(helper, 3 SECONDS, owner))
		return

	if(!current_gauze)
		return

	var/theirs = helper == owner ? helper.p_their() : "[owner]'s"
	helper.visible_message(
		span_notice("[helper] finishes removing [current_gauze] from [theirs] [plaintext_zone]."),
		span_notice("You finish removing [current_gauze] from [theirs] [plaintext_zone]."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)

	helper.balloon_alert(owner, "gauze removed")

	helper.put_in_hands(remove_gauze(drop_location()))

///////////
// Gauze //
///////////
/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth, perfect for stabilizing all kinds of wounds, from cuts and burns, to broken bones. "
	gender = PLURAL
	singular_name = "medical gauze"
	icon_state = "gauze"
	self_delay = 5 SECONDS
	other_delay = 2 SECONDS
	max_amount = 12
	amount = 6
	grind_results = list(/datum/reagent/cellulose = 2)
	custom_price = PAYCHECK_CREW * 2
	absorption_rate = 0.125
	absorption_capacity = 4
	splint_factor = 0.7
	burn_cleanliness_bonus = 0.35
	heal_burn = 10
	heal_brute = 10
	merge_type = /obj/item/stack/medical/gauze
	/// has this gauze been used? set to true in apply_gauze()
	var/used = FALSE
	/// can we clean this to restore capacity?
	var/can_clean = TRUE
	/// tracks how many times we've been scrubbed thoroughly
	var/times_cleaned = 0
	/// the color of the bandage overlay
	var/overlay_color = GAUZE_OVERLAY_COLOR

/obj/item/stack/medical/gauze/update_name(updates)
	. = ..()
	var/base_cap = initial(absorption_capacity)
	if(!base_cap)
		return

	if(absorption_capacity <= 0)
		name = "used [initial(name)]"
	else if(absorption_capacity <= base_cap * 0.2)
		name = "dirty [initial(name)]"
	else if(absorption_capacity <= base_cap * 0.8 || used)
		name = "worn [initial(name)]"
	else
		name = initial(name)

/obj/item/stack/medical/gauze/can_merge(obj/item/stack/medical/gauze/check, inhand)
	. = ..()
	if(!.)
		return .
	if(used || check.used)
		return FALSE
	// need to be in +- 0.5 dirtiness of each other
	// otherwise you can merge a completely used bandage with a brand new one, which would magically unuse it
	if(check.absorption_capacity < absorption_capacity || check.absorption_capacity > absorption_capacity)
		return FALSE
	return .

/obj/item/stack/medical/gauze/wash(clean_types)
	. = ..()
	if(.)
		return .
	if(!can_clean)
		return .
	if(!(clean_types & CLEAN_TYPE_HARD_DECAL)) // gotta scrub realllly hard to clean gauze
		return .
	times_cleaned += 1
	var/clean_to = initial(absorption_capacity) * (3 / (times_cleaned + 3))
	if(absorption_capacity < clean_to)
		absorption_capacity = clean_to
		update_appearance(UPDATE_NAME)
		. = TRUE

	return .

// gauze is only relevant for wounds, which are handled in the wounds themselves
/obj/item/stack/medical/gauze/try_heal(mob/living/patient, mob/user, silent)
	if(!patient.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		patient.balloon_alert(user, "no treatable area!")
		return
	var/treatment_delay = (user == patient ? self_delay : other_delay)

	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		patient.balloon_alert(user, "no limb!")
		return

	if(limb.current_gauze && (limb.current_gauze.absorption_capacity * 1.2 > absorption_capacity)) // ignore if our new wrap is < 20% better than the current one, so someone doesn't bandage it 5 times in a row
		patient.balloon_alert(user, pick("already bandaged!", "bandage is clean!")) // good enough
		return

	var/boosted = FALSE
	if(LAZYLEN(limb.wounds))
		for(var/datum/wound/wound as anything in limb.wounds)
			if(HAS_TRAIT(wound, TRAIT_WOUND_SCANNED))
				boosted = TRUE
				break
	else
		// gives you extra time so you realize you're not treating a wound
		treatment_delay *= 2

	var/whose = user == patient ? "your" : "[patient]'s"
	var/theirs = user == patient ? patient.p_their() : "[patient]'s"
	var/wrap_or_replace = limb.current_gauze ? "replacing [limb.current_gauze] on" : "wrapping"
	var/with_what = limb.current_gauze?.type == type ? "more of [src]" : src
	if(!silent)
		if(boosted)
			treatment_delay *= 0.5
			user.visible_message(
				span_notice("[user] begins expertly [wrap_or_replace] [theirs] [limb.plaintext_zone] with [with_what]."),
				span_notice("You begin quickly [wrap_or_replace] [whose] [limb.plaintext_zone] with [with_what], keeping the holo-image indications in mind..."),
			)
		else
			user.visible_message(
				span_notice("[user] begins [wrap_or_replace] [theirs] [limb.plaintext_zone] with [with_what]."),
				span_notice("You begin [wrap_or_replace] [whose] [limb.plaintext_zone] with [with_what]..."),
			)
	user.balloon_alert(user, "applying gauze...")
	if(user != patient)
		user.balloon_alert(patient, "applying gauze...")

	playsound(patient, pick(
		'monkestation/sound/items/rip1.ogg',
		'monkestation/sound/items/rip2.ogg',
		'monkestation/sound/items/rip3.ogg',
		'monkestation/sound/items/rip4.ogg',
	), 33)

	if(!do_after(user, treatment_delay, target = patient))
		user.balloon_alert(user, "interrupted!")
		return
	if(limb.current_gauze && (limb.current_gauze.absorption_capacity * 1.2 > absorption_capacity)) // double check for sanity
		return
	user.balloon_alert(user, "gauze applied")
	if(user != patient)
		user.balloon_alert(patient, "gauze applied")
	if(!silent)
		user.visible_message(
			span_infoplain(span_green("[user] applies [src] to [theirs] [limb.plaintext_zone].")),
			span_infoplain(span_green("You [limb.current_gauze?.type == type ? "replace" : "bandage"] the wounds on [whose] [limb.plaintext_zone].")),
		)
	limb.apply_gauze(src)
	if(iscarbon(patient) && !used)
		var/mob/living/carbon/carbon_patient = patient
		heal_carbon(carbon_patient, user, heal_brute, heal_burn, TRUE)
	return TRUE //for flesh burn wound code

/obj/item/stack/medical/gauze/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.tool_behaviour == TOOL_WIRECUTTER || attacking_item.get_sharpness())
		if(get_amount() < 2)
			balloon_alert(user, "not enough gauze!")
			return
		new /obj/item/stack/sheet/cloth(attacking_item.drop_location())
		if(user.CanReach(src))
			user.visible_message(span_notice("[user] cuts [src] into pieces of cloth with [attacking_item]."), \
				span_notice("You cut [src] into pieces of cloth with [attacking_item]."), \
				span_hear("You hear cutting."))
		else //telekinesis
			visible_message(span_notice("[attacking_item] cuts [src] into pieces of cloth."), \
				blind_message = span_hear("You hear cutting."))
		use(2)
		return

	return ..()

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins tightening [src] around [user.p_their()] neck! It looks like [user.p_they()] forgot how to use medical supplies!"))
	return OXYLOSS

/obj/item/stack/medical/gauze/twelve
	amount = 12

//////////////////////
// Improvised Gauze //
//////////////////////
/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that does a decent job of stabilizing wounds, but less efficiently so than real medical gauze."
	icon_state = "gauze_imp"
	self_delay = 6 SECONDS
	other_delay = 3 SECONDS
	splint_factor = 0.85
	burn_cleanliness_bonus = 0.7
	absorption_rate = 0.075
	absorption_capacity = 2
	heal_burn = 5
	heal_brute = 5
	merge_type = /obj/item/stack/medical/gauze/improvised
	overlay_color = IMPROVISED_GAUZE_OVERLAY_COLOR

////////////////
// Plastiseal //
////////////////
/obj/item/stack/medical/gauze/plastiseal
	name = "plastiseal"
	desc = "A synthetic skin with hemostatic properties, able to quickly seal most wounds. Very effective against burn wounds."
	singular_name = "plastiseal"
	icon_state = "plastiseal"
	grind_results = list(/datum/reagent/cellulose = 2, /datum/reagent/medicine/polypyr = 2, /datum/reagent/medicine/antipathogenic/spaceacillin = 1)
	custom_price = PAYCHECK_CREW * 3
	absorption_rate = 0.2
	splint_factor = 0.35
	burn_cleanliness_bonus = 0.1
	merge_type = /obj/item/stack/medical/gauze/plastiseal
	heal_burn = 30
	sanitization = 3
	flesh_regeneration = 15
	heal_brute = 15
	can_clean = FALSE
	overlay_color = PLASTISEAL_OVERLAY_COLOR

/obj/item/stack/medical/gauze/plastiseal/twelve
	amount = 12

#undef GAUZE_OVERLAY_COLOR
#undef IMPROVISED_GAUZE_OVERLAY_COLOR
#undef PLASTISEAL_OVERLAY_COLOR
