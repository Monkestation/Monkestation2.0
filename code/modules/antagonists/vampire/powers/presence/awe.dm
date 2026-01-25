/datum/action/cooldown/vampire/awe
	name = "Awe"
	desc = "Project an aura of supernatural presence that subtly influences those around you."
	button_icon_state = "power_awe"
	power_explanation = "Project an aura around yourself that subtly affects everyone nearby.\n\
						Effects on those in your aura:\n\
						- They can only whisper, unable to speak loudly.\n\
						- They are slightly slowed.\n\
						- They occasionally lose focus: facing you, stepping towards you, or dropping items.\n\
						Targets must be able to see you to be affected."
	vampire_power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY
	vitaecost = 30
	constant_vitaecost = 2
	cooldown_time = 10 SECONDS
	/// The range of the aura in tiles
	var/aura = 5

/datum/action/cooldown/vampire/awe/activate_power()
	. = ..()
	to_chat(owner, span_notice("You extend your supernatural presence."), type = MESSAGE_TYPE_INFO)

/datum/action/cooldown/vampire/awe/deactivate_power()
	. = ..()
	to_chat(owner, span_notice("You withdraw your supernatural presence."), type = MESSAGE_TYPE_INFO)

/datum/action/cooldown/vampire/awe/UsePower()
	. = ..()
	for(var/mob/living/victim in oviewers(aura, owner))
		if(can_affect(victim))
			victim.apply_status_effect(/datum/status_effect/awed, owner)

/// Checks if this victim can be affected by the awe aura
/datum/action/cooldown/vampire/awe/proc/can_affect(mob/living/victim)
	if(!victim.client)
		return FALSE
	if(HAS_SILICON_ACCESS(victim))
		return FALSE
	if(victim.stat != CONSCIOUS)
		return FALSE
	if(victim.is_blind() || victim.is_nearsighted_currently())
		return FALSE
	if(HAS_MIND_TRAIT(victim, TRAIT_VAMPIRE_ALIGNED) || HAS_MIND_TRAIT(victim, TRAIT_UNCONVERTABLE) || IS_CURATOR(victim))
		return FALSE
	return TRUE

/datum/status_effect/awed
	id = "awed"
	status_type = STATUS_EFFECT_REFRESH
	duration = 4 SECONDS
	tick_interval = 1 SECONDS
	alert_type = null
	var/mob/living/source_vampire
	COOLDOWN_DECLARE(awe_effect_cooldown)

/datum/status_effect/awed/on_creation(mob/living/new_owner, mob/living/vampire)
	source_vampire = vampire
	return ..()

/datum/status_effect/awed/Destroy()
	source_vampire = null
	return ..()

/datum/status_effect/awed/on_apply()
	if(!iscarbon(owner))
		return FALSE
	ADD_TRAIT(owner, TRAIT_SOFTSPOKEN, TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/awed)
	return TRUE

/datum/status_effect/awed/on_remove()
	REMOVE_TRAIT(owner, TRAIT_SOFTSPOKEN, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/awed)

/datum/status_effect/awed/tick(seconds_between_ticks)
	if(QDELETED(source_vampire) || source_vampire.stat == DEAD)
		qdel(src)
		return

	if(owner.incapacitated(IGNORE_RESTRAINTS) || !COOLDOWN_FINISHED(src, awe_effect_cooldown))
		return

	COOLDOWN_START(src, awe_effect_cooldown, 5 SECONDS)
	// Pick a random disruptive effect each tick
	switch(rand(1, 6))
		// Nothingburger
		if(1)
			to_chat(owner, span_awe("Your mind drifts..."))
		// Only face them, nothing else
		if(2)
			owner.face_atom(source_vampire)
		// Smile
		if(3)
			owner.face_atom(source_vampire)
			owner.emote("smiles")
			to_chat(owner, span_awe("You find yourself smiling..."))
		// Step Towards
		if(4)
			owner.face_atom(source_vampire)
			if(owner.body_position == STANDING_UP && get_step(owner.loc, get_dir(owner.loc, source_vampire.loc)) != source_vampire.loc)
				owner.visible_message(span_warning("[owner] stumbles."), span_awe("You suddenly stumble..."))
				owner.Move(get_step(owner.loc, get_dir(owner.loc, source_vampire.loc)))
		// Wobbly Knees
		if(5)
			owner.face_atom(source_vampire)
			if(owner.body_position == STANDING_UP && owner.stamina?.loss == 0)
				owner.visible_message(span_warning("[owner] seems quite wobbly on [owner.p_their()] feet."), span_awe("Your knees feel wobbly..."))
				owner.stamina?.adjust(-rand(20, 40))
		// Stunned
		if(6)
			owner.face_atom(source_vampire)
			owner.Stun(1 SECONDS, ignore_canstun = TRUE)
			to_chat(owner, span_awe("What was I doing?"))

/datum/status_effect/awed/get_examine_text()
	return span_warning("[owner.p_They()] seem[owner.p_s()] distracted and unfocused.")

/// Movespeed modifier for the awed status effect
/datum/movespeed_modifier/status_effect/awed
	multiplicative_slowdown = 0.6
