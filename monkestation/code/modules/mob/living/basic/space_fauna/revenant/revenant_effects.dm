/// Minimum cooldown time before we start trying to do effect emotes again.
#define MIN_EMOTE_COOLDOWN (10 SECONDS)
/// Maximum cooldown time before we start trying to do effect emotes again.
#define MAX_EMOTE_COOLDOWN (45 SECONDS)
/// How many seconds are shaved off each tick while holy water is in the victim's system.
#define HOLY_WATER_CURE_RATE (5 SECONDS)
/// Cure protection time limit.
#define CURE_PROTECTION_TIME (1 MINUTE)
/// Max stage blight can reach, each stage increases severity of effects.
#define MAX_BLIGHT_STAGES 5
/// Chance the blight increases stage.
#define CHANCE_TO_WORSEN 1.5
/// The shortest amount of time it can take for the stage to increase.
#define MIN_WORSEN_TIME (45 SECONDS)

/datum/status_effect/revenant_blight
	id = "revenant_blight"
	duration = 5 MINUTES
	tick_interval = 1 SECOND // Simulate disease activation(2sec) while making it fire 2x more.
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	remove_on_fullheal = TRUE
	var/stage = 0 //Current blight stage.
	var/stagedamage = 0 //Highest stage reached.
	var/finalstage = FALSE //Because we're spawning off the cure in the final stage, we need to check if we've done the final stage's effects.
	/// The omen/cursed component applied to the victim.
	var/datum/component/omen/revenant_blight/misfortune
	/// The revenant that cast this blight.
	var/mob/living/basic/revenant/ghostie
	/// The maximum amount of time (well, the maximum world.time) the final stage can be extended by refreshing it.
	var/maximum_final_extension
	/// How much the blight has affected someone's damage resistance.
	var/last_dr_change = 0
	/// Cooldown until the next (natural) stage change can occur.
	COOLDOWN_DECLARE(worsen_cooldown)
	/// Cooldown until the next stamina pause can occur.
	COOLDOWN_DECLARE(next_stamina_pause)

/datum/status_effect/revenant_blight/on_creation(mob/living/new_owner, mob/living/basic/revenant/ghostie)
	. = ..()
	if(. && istype(ghostie))
		src.ghostie = ghostie
		RegisterSignal(ghostie, COMSIG_QDELETING, PROC_REF(remove_when_ghost_dies))

// Should only be called once if they still have the status effect.
/datum/status_effect/revenant_blight/on_apply()
	RegisterSignal(owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_owner_examine))
	ADD_TRAIT(owner, TRAIT_EASILY_WOUNDED, TRAIT_STATUS_EFFECT(id))
	misfortune = owner.AddComponent(/datum/component/omen/revenant_blight)
	owner.set_haircolor(COLOR_REVENANT, override = TRUE)
	owner.stamina?.regen_rate *= 0.5
	adjust_stage(1) // Blight should be applied first time here so increase the stage usually starts at 0.
	to_chat(owner, span_revenminor("You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <i>wrong</i>")]."))
	return ..()

/datum/status_effect/revenant_blight/on_remove()
	QDEL_NULL(misfortune)
	set_damage_resistance(0)
	if(owner)
		UnregisterSignal(owner, COMSIG_ATOM_EXAMINE)
		REMOVE_TRAITS_IN(owner, TRAIT_STATUS_EFFECT(id))
		owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_REVENANT)
		owner.stamina?.regen_rate /= 0.5
		if(ishuman(owner))
			var/mob/living/carbon/human/human = owner
			if(human.dna?.species)
				human.dna.species.handle_mutant_bodyparts(human)
				human.set_haircolor(null, override = TRUE)
			to_chat(owner, span_notice("You feel better."))
		if(finalstage && HAS_TRAIT_FROM(owner, TRAIT_INCAPACITATED, STAMINA))
			owner.exit_stamina_stun()
		ADD_TRAIT(owner, TRAIT_REVENANT_BLIGHT_PROTECTION, type)
		addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_REVENANT_BLIGHT_PROTECTION, type), CURE_PROTECTION_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(ghostie)
		UnregisterSignal(ghostie, COMSIG_QDELETING)
		ghostie = null

/// Alter blight stage when applied to a mob that already has blight.
/datum/status_effect/revenant_blight/refresh(effect, ...)
	if(finalstage)
		duration = clamp(world.time + (15 SECONDS), duration, maximum_final_extension)
		if(owner.stamina)
			var/pause_time = max(COOLDOWN_TIMELEFT(owner.stamina, paused_stamina), 10 SECONDS)
			if(!HAS_TRAIT_FROM(owner, TRAIT_INCAPACITATED, STAMINA))
				owner.stamina.adjust(-(owner.stamina.maximum * 0.45))
			owner.stamina.pause(pause_time)
	else
		. = ..()
		adjust_stage(1)

/// Helper to handle affecting blight stages.
/datum/status_effect/revenant_blight/proc/adjust_stage(amount)
	stage = clamp(stage + amount, 0, MAX_BLIGHT_STAGES)
	COOLDOWN_START(src, worsen_cooldown, MIN_WORSEN_TIME)

/datum/status_effect/revenant_blight/proc/set_damage_resistance(amount)
	if(last_dr_change == amount)
		return
	var/datum/physiology/physiology = astype(owner, /mob/living/carbon/human)?.physiology
	if(!physiology)
		return
	physiology.damage_resistance -= last_dr_change
	physiology.damage_resistance += amount
	last_dr_change = amount

/// Returns if the revenant is orbiting the victim or not.
/datum/status_effect/revenant_blight/proc/being_haunted()
	return ghostie?.orbiting?.parent == owner

/// Blight randomly causes stamina damage to the victim.
/// The damage amount is based on a percentage of the maximum and the current stage.
/// Stage 1 is 10%, stage 2 is 15%, stage 3 is 20%, and stage 4 is 10%.
/// If the revenant is orbiting the victim, the damage is multiplied by 25% (i.e stage 1 deals 12.5%, stage 3 deals 25%)
/datum/status_effect/revenant_blight/proc/effect_stamina(seconds_between_ticks)
	if(!owner.stamina || !SPT_PROB(25, seconds_between_ticks))
		return
	var/multiplier
	switch(stage)
		if(1)
			multiplier = 0.1
		if(2)
			multiplier = 0.15
		if(3)
			multiplier = 0.2
		if(4)
			multiplier = 0.1
		else
			return
	if(being_haunted())
		multiplier *= 1.25
	owner.stamina.adjust(-(owner.stamina.maximum * multiplier) * seconds_between_ticks)

/// Blight always causes the victim's sanity to drain.
/// It drains more sanity overall if the revenant is orbiting the victim.
/datum/status_effect/revenant_blight/proc/effect_sanity_drain(seconds_between_ticks)
	var/stamina_to_drain = being_haunted() ? rand(10, 25) : rand(5, 15)
	owner.mob_mood?.direct_sanity_drain(-stamina_to_drain * seconds_between_ticks)

/// Blight has a random chance to inflict confusion on the victim each tick.
/// It adds 4 seconds of confusion, up to a maximum of 20 seconds.
/// If the revenant is orbiting the victim, it's instead 8 seconds added, up to 30.
/datum/status_effect/revenant_blight/proc/effect_confusion(seconds_between_ticks)
	if(!SPT_PROB(1.5 * stage, seconds_between_ticks))
		return
	to_chat(owner, span_revennotice("You suddenly feel [pick("sick and tired", "disoriented", "tired and confused", "nauseated", "faint", "dizzy")]..."))
	if(being_haunted())
		owner.adjust_confusion_up_to((8 SECONDS) * seconds_between_ticks, 30 SECONDS)
	else
		owner.adjust_confusion_up_to((4 SECONDS) * seconds_between_ticks, 20 SECONDS)
	new /obj/effect/temp_visual/revenant(owner.loc)

/// Blight causes toxin damage with each stage.
/// The base damage is the stage multiplied by 4, but remember this stacks with the extra damage debuff that blight applies.
///
/// HOWEVER, the toxin damage on its own cannot go over around 45% of the mob's crit threshold (usually, well, 45),
/// meaning that blight cannot crit someone using toxin damage, other types of damage will need to bring them below the crit threshold.
/datum/status_effect/revenant_blight/proc/effect_toxin_damage(seconds_between_ticks)
	if(stagedamage >= stage)
		return
	stagedamage++
	var/maximum_damage = floor((owner.crit_threshold * 0.45) - owner.getToxLoss())
	if(maximum_damage <= 0)
		return

	owner.adjustToxLoss(min(4 * stage, maximum_damage))
	new /obj/effect/temp_visual/revenant(owner.loc)

/// Blight will sometimes randomly pause stamina regeneration before stage 4.
/// The time paused is the stage multiplied by 5 seconds.
/// HOWEVER, the pause effect will be unable to trigger again for a short while - the cooldown is half the pause time (starting from when the pause ends)
/datum/status_effect/revenant_blight/proc/effect_pause_stamina(seconds_between_ticks)
	if(!owner.stamina?.is_regenerating || !ISINRANGE(stage, 1, 3) || !COOLDOWN_FINISHED(src, next_stamina_pause) || !SPT_PROB(1 * stage, seconds_between_ticks))
		return
	var/pause_time = 5 SECONDS * stage
	owner.stamina.pause(pause_time)
	COOLDOWN_START(src, next_stamina_pause, CEILING(pause_time * 1.5, 5 SECONDS))
	to_chat(owner, span_revennotice("You can't quite seem to catch your breath..."))

/// The blighted victim becomes more unlucky when being orbited by the revenant.
/datum/status_effect/revenant_blight/proc/update_misfortune()
	if(being_haunted())
		misfortune.luck_mod = 1
		misfortune.damage_mod = 0.5
	else
		misfortune.luck_mod = misfortune::luck_mod
		misfortune.damage_mod = misfortune::damage_mod

/// Updates the damage resistance (well, EXTRA damage taken) of the blighted victim
/// Final stage always takes 50% extra damage.
/// Otherwise, the extra damage taken is the current stage multiplied by 4.5 (5 if they're being orbited by the revenant)
/// Having holy water in your system completely remove the extra damage, unless they're in the final stage.
/datum/status_effect/revenant_blight/proc/update_damage_resistance()
	SIGNAL_HANDLER
	if(finalstage)
		set_damage_resistance(-50)
	// having holy water in your system negates the extra damage
	else if(owner.reagents?.has_reagent(/datum/reagent/water/holywater))
		set_damage_resistance(0)
	else
		var/multiplier = being_haunted() ? 5 : 4.5
		set_damage_resistance(-stage * multiplier)

/// Begins the final stage (stage 5) of blight, which has a variety of nasty effects:
/// It forces the victim to be soft-spoken (always whispering), instantly stamcrits them,
/// prevents stamina regen for 20 seconds, increases their extra damage to 50%,
/// and of course gives an obvious message + visual effects.
///
/// The final stage normally lasts 25 seconds,
/// however the revenant can extend it up to a maximum of 1 minute by re-casting the blight ability on them.
/datum/status_effect/revenant_blight/proc/begin_final_stage()
	if(finalstage)
		return
	finalstage = TRUE

	duration = world.time + (25 SECONDS)
	maximum_final_extension = world.time + (1 MINUTES)

	ADD_TRAIT(owner, TRAIT_SOFTSPOKEN, TRAIT_STATUS_EFFECT(id))

	// instant stamcrit
	owner.Paralyze(20 SECONDS)
	if(owner.stamina)
		owner.stamina.pause(20 SECONDS)
		owner.stamina.adjust(-owner.stamina.current, forced = TRUE)

	// 50% more of ALL TYPES OF DAMAGE
	set_damage_resistance(-50)

	// aight time for the flavor/visual effects
	to_chat(owner, span_revenbignotice("You feel like [pick("nothing's worth it anymore", "nobody ever needed your help", "nothing you did mattered", "everything you tried to do was worthless")]."))
	owner.has_dna()?.species?.handle_mutant_bodyparts(owner, COLOR_REVENANT)
	owner.set_haircolor(COLOR_REVENANT, override = TRUE)
	owner.add_atom_colour(COLOR_REVENANT, TEMPORARY_COLOUR_PRIORITY)
	owner.visible_message(span_warning("[owner] looks terrifyingly gaunt..."), span_revennotice("You suddenly feel like your skin is <i>wrong</i>..."))
	new /obj/effect/temp_visual/revenant(owner.loc)

/datum/status_effect/revenant_blight/tick(seconds_between_ticks, times_fired)
	if(owner.reagents?.has_reagent(/datum/reagent/water/holywater))
		remove_duration(HOLY_WATER_CURE_RATE * seconds_between_ticks)
	effect_sanity_drain(seconds_between_ticks)
	if(!finalstage)
		if(owner.body_position == LYING_DOWN && owner.IsSleeping() && SPT_PROB(3 * stage, seconds_between_ticks)) // Make sure they are sleeping laying down.
			qdel(src) // Cure the Status effect.
			return FALSE
		update_misfortune()
		update_damage_resistance()
		effect_confusion(seconds_between_ticks)
		effect_toxin_damage(seconds_between_ticks)
		effect_stamina(seconds_between_ticks)
		effect_pause_stamina(seconds_between_ticks)

	switch(stage)
		if(2)
			if(owner.stat == CONSCIOUS && SPT_PROB(2.5, seconds_between_ticks))
				owner.emote("pale")
		if(3)
			if(owner.stat == CONSCIOUS && SPT_PROB(5, seconds_between_ticks))
				owner.emote(pick("pale", "shiver"))
		if(4)
			if(owner.stat == CONSCIOUS && SPT_PROB(7.5, seconds_between_ticks))
				owner.emote(pick("pale", "shiver", "cries"))
		if(5)
			begin_final_stage()

	if(COOLDOWN_FINISHED(src, worsen_cooldown) && SPT_PROB(CHANCE_TO_WORSEN, seconds_between_ticks)) // Finally check if we should increase the stage.
		adjust_stage(1)

/// Allows the revenant (and observers) to see that someone is blighted, and what stage of blight they have, by examining them.
/datum/status_effect/revenant_blight/proc/on_owner_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	if(isobserver(examiner) || isrevenant(examiner))
		if(finalstage)
			examine_text += span_revenboldnotice("[owner.p_They()] [owner.p_have()] been crippled by the blight, the time to reap is now!")
		else
			examine_text += span_revennotice("[owner.p_They()] [owner.p_are()] afflicted with the blight, which is currently at stage [stage].")

/datum/status_effect/revenant_blight/proc/remove_when_ghost_dies(datum/source)
	SIGNAL_HANDLER
	owner.visible_message(span_warning("Dark energy evaporates off of [owner]."), span_revennotice("The dark energy plaguing you has suddenly dissipated."))
	qdel(src)

/datum/component/omen/revenant_blight
	incidents_left = INFINITY
	luck_mod = 0.6 // 60% chance of bad things happening
	damage_mod = 0.25 // 25% of normal damage

#undef MIN_EMOTE_COOLDOWN
#undef MAX_EMOTE_COOLDOWN
#undef HOLY_WATER_CURE_RATE
#undef MAX_BLIGHT_STAGES
#undef CHANCE_TO_WORSEN
#undef CURE_PROTECTION_TIME
#undef MIN_WORSEN_TIME
