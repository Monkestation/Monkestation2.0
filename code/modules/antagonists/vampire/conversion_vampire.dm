/**
 * This file contains all of the procs related to vassalizing someone
 *
**/

/**
 * Checks if the target's antag_datums contain any of the banned antags.
**/
/datum/antagonist/vampire/proc/is_blacklisted_antag(mob/target)
	for(var/datum/antagonist/antag_datum as anything in target.mind.antag_datums)
		if(antag_datum.type in vassal_banned_antags)
			return TRUE
	return FALSE

/**
 * Checks if the person is allowed to turn into the Vampire's vassal
**/
/datum/antagonist/vampire/proc/can_make_vassal(mob/living/conversion_target, ignore_concious_check = FALSE)
	var/mob/living/living_vampire = owner.current

	if(!my_clan)
		living_vampire.balloon_alert(living_vampire, "enter a clan first.")
		return FALSE

	if(count_vassals() >= max_vampire_vassals())
		living_vampire.balloon_alert(living_vampire, "too many vassals.")
		return FALSE

	// just gets us past checks, bc something *UNIQUE* happens if you try to vassalize a moonatic
	if(conversion_target.has_status_effect(/datum/status_effect/heretic_passive/moon))
		return TRUE

#ifndef VAMPIRE_TESTING
	if(!conversion_target.ckey)
		living_vampire.balloon_alert(living_vampire, "can't be vassalized.")
		return FALSE
#endif

	if(!iscarbon(conversion_target) || !conversion_target.mind || HAS_TRAIT(conversion_target, TRAIT_MINDSHIELD) || HAS_MIND_TRAIT(conversion_target, TRAIT_UNCONVERTABLE) || is_blacklisted_antag(conversion_target))
		living_vampire.balloon_alert(living_vampire, "can't be vassalized.")
		return FALSE

	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(conversion_target)
	var/mob/living/vassal_master = conversion_target.mind.enslaved_to?.resolve()
	if(vassaldatum || (vassal_master && vassal_master != owner.current))
		living_vampire.balloon_alert(living_vampire, "enslaved to someone else.")
		return FALSE

	if(!ignore_concious_check && conversion_target.stat > UNCONSCIOUS)
		living_vampire.balloon_alert(living_vampire, "must be awake.")
		return FALSE

	return TRUE

/datum/antagonist/vampire/proc/make_vassal(mob/living/conversion_target)
	// conversion gets REVERSED for moon heretics.
	if(isliving(conversion_target) && conversion_target.has_status_effect(/datum/status_effect/heretic_passive/moon)) // isliving is NEEDED bc oozeling cores can also be passed
		to_chat(owner.current, span_userdanger("You begin to pour your will into [conversion_target]'s mind, \
			but the demand does not stop. It draws you in, like a lamb caught in raPID WATERS, SWEPT INTO THE TUNNEL WITHIN, \
			DRUMS DEAFENING AS THE WATERS CRASH, THE LIGHTS AND SOUNDS DANCING ABOVE THE DROWNING DEPTHS, SWALLOWING YOU WHOLE."), type = MESSAGE_TYPE_WARNING)
		to_chat(owner.current, span_hypnophrase(span_reallybig("STOP THE NOISE OUT OF THE WATERS STOP STOP STOP THE MUSIC STOP STOP.")), type = MESSAGE_TYPE_WARNING)

		// congrats moon heretic, the hubris of a creature of the night has earned you one USEFUL minion!
		if(!conversion_target.mind.has_antag_datum(/datum/antagonist/lunatic/master))
			conversion_target.mind.add_antag_datum(/datum/antagonist/lunatic/master)

		var/datum/antagonist/lunatic/lunatic = owner.add_antag_datum(/datum/antagonist/lunatic)
		lunatic.set_master(conversion_target.mind, conversion_target)

		if(iscarbon(owner.current))
			var/mob/living/carbon/current_carbon = owner.current
			var/obj/item/clothing/neck/heretic_focus/moon_amulet/amulet = new(current_carbon.drop_location())
			var/static/list/slots = list(
				LOCATION_NECK,
				LOCATION_HANDS,
				LOCATION_RPOCKET,
				LOCATION_LPOCKET,
				LOCATION_BACKPACK,
			)
			current_carbon.equip_in_one_of_slots(amulet, slots, qdel_on_fail = FALSE)
		INVOKE_ASYNC(owner.current, TYPE_PROC_REF(/mob, emote), "laugh")
		return FALSE

	if(IS_VASSAL(conversion_target))
		conversion_target.mind.remove_antag_datum(/datum/antagonist/vassal)

	// Set the master, then give the datum.
	var/datum/antagonist/vassal/vassaldatum = new(conversion_target.mind)
	vassaldatum.master = src
	conversion_target.mind.add_antag_datum(vassaldatum)

	message_admins("[ADMIN_LOOKUPFLW(conversion_target)] has become a vassal, and is enslaved to [ADMIN_LOOKUPFLW(owner.current)].")
	log_admin("[key_name(conversion_target)] has become a vassal, and is enslaved to [key_name(owner.current)].")

	return TRUE
