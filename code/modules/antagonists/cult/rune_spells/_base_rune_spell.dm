//Returns a rune spell based on the given 3 words.
/proc/get_rune_spell(mob/user, obj/spell_holder, use = "ritual", datum/rune_word/word1, datum/rune_word/word2, datum/rune_word/word3)
	if(!word1 || !word2 || !word3)
		return
	for(var/subtype in subtypesof(/datum/rune_spell))
		var/datum/rune_spell/instance = subtype
		if(word1.type == initial(instance.word1) && word2.type == initial(instance.word2) && word3.type == initial(instance.word3))
			switch (use)
				if ("ritual")
					return new subtype(user, spell_holder, use)
				if ("examine")
					return instance
				if ("walk")
					if (initial(instance.walk_effect))
						return new subtype(user, spell_holder, use) //idk man
					else
						return null
				if ("imbue")
					return subtype
			return new subtype(user, spell_holder, use)
	return null


/datum/rune_spell
	var/secret = FALSE						// When set to true, this spell will not appear in the list of runes, when using the "Draw Rune with a Guide" button.
	var/name = "rune spell"					// The spell's name.
	var/desc = "you shouldn't be reading this."   			// Appears to cultists when examining a rune that triggers this spell
	var/desc_talisman = "you shouldn't be reading this."  	// Appears to cultists when examining a taslisman that triggers this spell
	var/obj/spell_holder = null				//The rune or talisman calling the spell. If using a talisman calling an attuned rune, the holder is the rune.
	var/mob/activator = null				//The original mob that cast the spell
	var/datum/rune_word/word1 = null
	var/datum/rune_word/word2 = null
	var/datum/rune_word/word3 = null
	var/invocation = "Lo'Rem Ip'Sum"		//Spoken whenever cast.
	var/touch_cast = 0			//If set to 1, will proc cast_touch() when touching someone with an imbued talisman (example: Stun)
	var/can_conceal = 0			//If set to 1, concealing the rune will not abort the spell. (example: Path Exit)
	var/rune_flags = null 		//If set to RUNE_STAND (or 1), the user will need to stand right above the rune to use cast the spell
	var/walk_effect = 0 //If set to 1, procs Added() when step over
	var/custom_rune	= FALSE // Prevents the rune's normal UpdateIcon() from firing.

	//Optional (These vars aren't used by default rune code, but many runes make use of them, so set them up as you need, the comments below are suggestions)
	var/cost_invoke = 0						//Blood cost upon cast
	var/cost_upkeep = 0						//Blood cost upon upkeep proc
	var/list/contributors = list()			//List of people currently participating in the ritual
	var/remaining_cost = 0					//How much blood to gather for the ritual to succeed
	var/accumulated_blood = 0				//How much blood has been gathered so far
	var/cancelling = 3						//Check this variable to abort the ritual due to blood flow being interrupted
	var/list/ingredients = list()			//Items that should be on the rune for it to work
	var/list/ingredients_found = list()		//Items that are found on the rune

	var/destroying_self = FALSE		//Sanity var to prevent abort loops, ignore
	var/image/progbar = null	//Bar for channeling spells

	var/talisman_absorb = RUNE_CAN_IMBUE	//Whether the rune is absorbed into the talisman (and thus deleted), or linked to the talisman (RUNE_CAN_ATTUNE)
	var/talisman_uses = 1					//How many times can a spell be cast from a single talisman. The talisman disappears upon the last use.

	var/page = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, \
			 sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\
			  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut\
			   aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in\
			    voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint\
			     occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." //Arcane tome page description.

/datum/rune_spell/New(mob/user, obj/holder, use = "ritual", mob/target)
	spell_holder = holder
	activator = user

	if(use == "ritual")
		pre_cast()
	else if(use == "touch" && target)
		cast_touch(target) //Skips pre_cast() for talismans)


/datum/rune_spell/Destroy()
	destroying_self = TRUE
	if(spell_holder)
		if(istype(spell_holder, /obj/effect/new_rune))
			var/obj/effect/new_rune/rune_holder = spell_holder
			rune_holder.active_spell = null
		spell_holder = null
	word1 = null
	word2 = null
	word3 = null
	activator = null
	..()

/datum/rune_spell/proc/invoke(var/mob/user, var/text = "", var/whisper = 0)
	if(user.checkTattoo(TATTOO_SILENT) || (spell_holder.icon_state == "temp"))
		return
	if(!whisper)
		user.say(text, "C")
	else
		user.whisper(text)

/datum/rune_spell/proc/pre_cast()
	if(istype(spell_holder, /obj/effect/new_rune))
		var/obj/effect/new_rune/R = spell_holder
		R.activated++
		R.update_icon()
		if (R.word1)// "invisible" temporary runes spawned by some talismans shouldn't display those
			R.cast_word(R.word1.english)
			R.cast_word(R.word2.english)
			R.cast_word(R.word3.english)
		if((rune_flags & RUNE_STAND) && (get_turf(activator) != get_turf(spell_holder)))
			abort(RITUALABORT_STAND)
		else
			invoke(activator, invocation)
			cast()
	else if(istype (spell_holder, /obj/item/talisman))
		invoke(activator, invocation, 1)//talisman incantations are whispered
		cast_talisman()

/datum/rune_spell/proc/pay_blood()
	var/data = use_available_blood(activator, cost_invoke)
	if(data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		to_chat(activator, span_warning("This ritual requires more blood than you can offer.") )
		return FALSE
	else
		return TRUE

/datum/rune_spell/proc/Added(var/mob/M)

/datum/rune_spell/proc/Removed(var/mob/M)

/datum/rune_spell/proc/midcast(mob/add_cultist)
	return

/datum/rune_spell/proc/cast() //Override for your spell functionality.
	spell_holder.visible_message(span_warning("This rune wasn't properly set up, tell a coder.") )
	qdel(src)

/datum/rune_spell/proc/abort(var/cause) //The error message for aborting, usable by any runeset.
	if(destroying_self)
		return
	destroying_self = TRUE
	switch(cause)
		if (RITUALABORT_ERASED)
			if (istype (spell_holder, /obj/effect/new_rune))
				spell_holder.visible_message(span_warning("The rune's destruction ended the ritual.") )
		if (RITUALABORT_STAND)
			if (activator)
				to_chat(activator, span_warning("The [name] ritual requires you to stand on top of the rune.") )
		if (RITUALABORT_GONE)
			if (activator)
				to_chat(activator, span_warning("The ritual ends as you move away from the rune.") )
		if (RITUALABORT_BLOCKED)
			if (activator)
				to_chat(activator, span_warning("There is a building blocking the ritual..") )
		if (RITUALABORT_BLOOD)
			spell_holder.visible_message(span_warning("Deprived of blood, the channeling is disrupted.") )
		if (RITUALABORT_TOOLS)
			if (activator)
				to_chat(activator, span_warning("The necessary tools have been misplaced.") )
		if (RITUALABORT_TOOLS)
			spell_holder.visible_message(span_warning("The ritual ends as the victim gets pulled away from the rune.") )
		if (RITUALABORT_CONVERT)
			if (activator)
				to_chat(activator, span_notice("The conversion ritual successfully brought a new member to the cult. Inform them of the current situation so they can take action."))
		if (RITUALABORT_REFUSED)
			if (activator)
				to_chat(activator, span_notice("The conversion ritual ended with the target being restrained by some eldritch contraption. Deal with them how you see fit so their life may serve our plans."))
		if (RITUALABORT_NOCHOICE)
			if (activator)
				to_chat(activator, span_notice("The target never manifested any clear reaction to the ritual. As such they were automatically restrained."))
		if (RITUALABORT_SACRIFICE)
			if (activator)
				to_chat(activator, span_warning("The ritual ends leaving behind nothing but a creepy chest, filled with your lost soul's belongings.") )
		if (RITUALABORT_CONCEAL)
			if (activator)
				to_chat(activator, span_warning("The ritual is disrupted by the rune's sudden phasing out.") )
		if (RITUALABORT_NEAR)
			if (activator)
				to_chat(activator, span_warning("You cannot perform this ritual that close from another similar structure.") )
		if (RITUALABORT_OVERCROWDED)
			if (activator)
				to_chat(activator, span_warning("There are too many human cultists and constructs already.") )

	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/datum/rune_spell/proc/salt_act(var/turf/T)
	return

/datum/rune_spell/proc/missing_ingredients_count()
	var/list/missing_ingredients = ingredients.Copy()
	var/turf/T = get_turf(spell_holder)
	for (var/path in missing_ingredients)
		var/atom/A = locate(path) in T
		if (A)
			missing_ingredients -= path
			ingredients_found += A

	if (missing_ingredients.len > 0)
		var/missing = "You need "
		var/i = 1
		for (var/I in missing_ingredients)
			i++
			var/atom/A = I
			missing += "\a [initial(A.name)]"
			if (i <= missing_ingredients.len)
				missing += ", "
				if (i == missing_ingredients.len)
					missing += "and "
			else
				missing += "."
		to_chat(activator, span_warning("The necessary ingredients for this ritual are missing. [missing]") )
		abort(RITUALABORT_MISSING)
		return TRUE
	return FALSE

/datum/rune_spell/proc/update_progbar()
	if(!progbar)
		progbar = image("icon" = 'monkestation/code/modules/bloody_cult/icons/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = 32
		progbar.plane = HUD_PLANE
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[round((min(1, accumulated_blood / remaining_cost) * 100), 10)]"
	return

/datum/rune_spell/proc/cast_talisman() //Override for unique talisman behavior.
	cast()

/datum/rune_spell/proc/cast_touch(var/mob/M) //Behavior on using the talisman on somebody. See - stun talisman.
	return

/datum/rune_spell/proc/midcast_talisman(var/mob/add_cultist)
	return
