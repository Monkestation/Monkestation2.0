/// Minimum cooldown time before we start trying to do effect emotes again.
#define MIN_EMOTE_COOLDOWN		(10 SECONDS)
/// Maximum cooldown time before we start trying to do effect emotes again.
#define MAX_EMOTE_COOLDOWN		(45 SECONDS)
/// How many seconds are shaved off each tick while holy water is in the victim's system.
#define HOLY_WATER_CURE_RATE	(5 SECONDS)
#define CURE_PROTECTION_TIME (1 MINUTE) // Cure protection time limit.
#define MAX_BLIGHT_STAGES 5 // Max stage blight can reach, each stage increases severity of effects.
#define CHANCE_TO_WORSEN 5 // Chance the blight increases stage

/datum/status_effect/revenant_blight
	id = "revenant_blight"
	duration = 5 MINUTES
	tick_interval = 1 SECOND // Simulate disease activation(2sec) while making it fire 2x more.
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	remove_on_fullheal = TRUE
	var/max_stages = MAX_BLIGHT_STAGES
	var/stage = 0 //Current blight stage.
	var/stagedamage = 0 //Highest stage reached.
	var/finalstage = FALSE //Because we're spawning off the cure in the final stage, we need to check if we've done the final stage's effects.
	/// The omen/cursed component applied to the victim.
	var/datum/component/omen/revenant_blight/misfortune
	/// The revenant that cast this blight.
	var/mob/living/basic/revenant/ghostie

/datum/status_effect/revenant_blight/on_creation(mob/living/new_owner, mob/living/basic/revenant/ghostie)
	. = ..()
	if(. && istype(ghostie))
		src.ghostie = ghostie
		RegisterSignal(ghostie, COMSIG_QDELETING, PROC_REF(remove_when_ghost_dies))

// Should only be called once if they still have the status effect.
/datum/status_effect/revenant_blight/on_apply()
	ADD_TRAIT(owner, TRAIT_EASILY_WOUNDED, TRAIT_STATUS_EFFECT(id))
	misfortune = owner.AddComponent(/datum/component/omen/revenant_blight)
	owner.set_haircolor(COLOR_REVENANT, override = TRUE)
	adjust_stage(1) // Blight should be applied first time here so increase the stage usually starts at 0.
	to_chat(owner, span_revenminor("You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <i>wrong</i>")]."))
	return ..()

///Alter blight stage when applied to a mob that already has blight.
/datum/status_effect/revenant_blight/refresh(effect, ...)
	. = ..()
	adjust_stage(1)

///Helper to handle affecting blight stages.
/datum/status_effect/revenant_blight/proc/adjust_stage(amount)
	stage = clamp(stage + amount, 0, MAX_BLIGHT_STAGES)

/datum/status_effect/revenant_blight/on_remove()
	QDEL_NULL(misfortune)
	if(owner)
		REMOVE_TRAITS_IN(owner, TRAIT_STATUS_EFFECT(id))
		owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_REVENANT)
		if(ishuman(owner))
			var/mob/living/carbon/human/human = owner
			if(human.dna?.species)
				human.dna.species.handle_mutant_bodyparts(human)
				human.set_haircolor(null, override = TRUE)
			to_chat(owner, span_notice("You feel better."))
			ADD_TRAIT(owner, TRAIT_REVENANT_BLIGHT_PROTECTION, type)
			addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_REVENANT_BLIGHT_PROTECTION, type), CURE_PROTECTION_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(ghostie)
		UnregisterSignal(ghostie, COMSIG_QDELETING)
		ghostie = null

/datum/status_effect/revenant_blight/tick(seconds_per_tick, times_fired)
	if(owner.reagents?.has_reagent(/datum/reagent/water/holywater))
		remove_duration(HOLY_WATER_CURE_RATE * seconds_per_tick)
	owner.mob_mood?.direct_sanity_drain(-rand(2, 10) * seconds_per_tick)
	if(!finalstage)
		if(owner.body_position == LYING_DOWN && owner.IsSleeping() && SPT_PROB(3 * stage, seconds_per_tick)) // Make sure they are sleeping laying down.
			qdel(src) // Cure the Status effect.
			return FALSE
		if(SPT_PROB(1.5 * stage, seconds_per_tick))
			to_chat(owner, span_revennotice("You suddenly feel [pick("sick and tired", "disoriented", "tired and confused", "nauseated", "faint", "dizzy")]..."))
			owner.adjust_confusion(4 SECONDS)
			owner.stamina.adjust(-21 * seconds_per_tick)
			new /obj/effect/temp_visual/revenant(owner.loc)
		if(stagedamage < stage)
			stagedamage++
			owner.adjustToxLoss(1 * stage * seconds_per_tick) //should, normally, do about 30 toxin damage.
			new /obj/effect/temp_visual/revenant(owner.loc)
		if(SPT_PROB(25, seconds_per_tick))
			owner.stamina.adjust(-(stage * 2) * seconds_per_tick)

	switch(stage)
		if(2)
			if(owner.stat == CONSCIOUS && SPT_PROB(2.5, seconds_per_tick))
				owner.emote("pale")
		if(3)
			if(owner.stat == CONSCIOUS && SPT_PROB(5, seconds_per_tick))
				owner.emote(pick("pale","shiver"))
		if(4)
			if(owner.stat == CONSCIOUS && SPT_PROB(7.5, seconds_per_tick))
				owner.emote(pick("pale","shiver","cries"))
		if(5)
			if(!finalstage)
				finalstage = TRUE
				ADD_TRAIT(owner, TRAIT_SOFTSPOKEN, TRAIT_STATUS_EFFECT(id))
				to_chat(owner, span_revenbignotice("You feel like [pick("nothing's worth it anymore", "nobody ever needed your help", "nothing you did mattered", "everything you tried to do was worthless")]."))
				owner.stamina.adjust(-22.5 * seconds_per_tick, forced = TRUE)
				new /obj/effect/temp_visual/revenant(owner.loc)
				if(ishuman(owner))
					var/mob/living/carbon/human/human = owner
					if(human.dna?.species)
						human.dna.species.handle_mutant_bodyparts(human, COLOR_REVENANT)
						owner.set_haircolor(COLOR_REVENANT, override = TRUE)
				owner.visible_message(span_warning("[owner] looks terrifyingly gaunt..."), span_revennotice("You suddenly feel like your skin is <i>wrong</i>..."))
				owner.add_atom_colour(COLOR_REVENANT, TEMPORARY_COLOUR_PRIORITY)
				QDEL_IN(src, 10 SECONDS) // Automatically call qdel and removing status on timer.

	if(SPT_PROB(CHANCE_TO_WORSEN, seconds_per_tick)) // Finally check if we should increase the stage.
		adjust_stage(1)

/datum/status_effect/revenant_blight/proc/remove_when_ghost_dies(datum/source)
	SIGNAL_HANDLER
	if(ishuman(owner))
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
