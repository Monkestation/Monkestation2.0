/// Minimum cooldown time before we start trying to do effect emotes again.
#define MIN_EMOTE_COOLDOWN		(10 SECONDS)
/// Maximum cooldown time before we start trying to do effect emotes again.
#define MAX_EMOTE_COOLDOWN		(45 SECONDS)
/// How many seconds are shaved off each tick while holy water is in the victim's system.
#define HOLY_WATER_CURE_RATE	(5 SECONDS)
#define MAX_BLIGHT_STAGES 5 // Max stage blight can reach, each stage increases severity of effects.

/datum/status_effect/revenant_blight
	id = "revenant_blight"
	duration = 5 MINUTES
	tick_interval = 1 SECONDS // Simulate disease activation while making it fire 2x more.
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	remove_on_fullheal = TRUE
	var/max_stages = MAX_BLIGHT_STAGES
	var/stage = 0 //Current blight stage.
	//stage_prob = 5
	//var/stagedamage = 0 //Highest stage reached.
	//var/finalstage = 0 //Because we're spawning off the cure in the final stage, we need to check if we've done the final stage's effects.
	/// The omen/cursed component applied to the victim.
	var/datum/component/omen/revenant_blight/misfortune
	/// The revenant that cast this blight.
	var/mob/living/basic/revenant/ghostie
	/// Cooldown var for when the status effect can emote again.
	COOLDOWN_DECLARE(next_emote)

/datum/status_effect/revenant_blight/on_creation(mob/living/new_owner, mob/living/basic/revenant/reve_ghostie)
	. = ..()
	if(. && istype(reve_ghostie))
		src.ghostie = reve_ghostie
		RegisterSignal(reve_ghostie, COMSIG_QDELETING, PROC_REF(remove_when_ghost_dies))

// Should only be called once if they still have the status effect.
/datum/status_effect/revenant_blight/on_apply()
	misfortune = owner.AddComponent(/datum/component/omen/revenant_blight)
	owner.set_haircolor(COLOR_REVENANT, override = TRUE)
	to_chat(owner, span_revenminor("You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <i>wrong</i>")]."))

	return ..()

///Alter blight stage when applied to a mob that already has blight.
/datum/status_effect/revenant_blight/refresh(effect, ...)
	. = ..()
	adjust_stage() //Default increases stage by 1

///Helper to handle affecting blight stages.
/datum/status_effect/revenant_blight/proc/adjust_stage(set_mode = "inc", modifier = 1)
	var/blight_stage = 0
	if(set_mode == "inc")
		blight_stage = modifier
	else if(set_mode == "dec")
		blight_stage =  -modifier

	stage = clamp(stage + blight_stage, 0, MAX_BLIGHT_STAGES)

/datum/status_effect/revenant_blight/on_remove()
	QDEL_NULL(misfortune)
	owner.set_haircolor(null, override = TRUE)
	if(ghostie)
		UnregisterSignal(ghostie, COMSIG_QDELETING)
		ghostie = null
	to_chat(owner, span_notice("You feel better."))

/datum/status_effect/revenant_blight/tick(seconds_per_tick, times_fired)

/*
	var/delta_time = DELTA_WORLD_TIME(SSfastprocess)
	if(owner.stat == CONSCIOUS && COOLDOWN_FINISHED(src, next_emote) && SPT_PROB(5, delta_time))
		owner.emote(pick("pale", "shiver", "cries"))
		COOLDOWN_START(src, next_emote, rand(MIN_EMOTE_COOLDOWN, MAX_EMOTE_COOLDOWN))
	if(owner.reagents?.has_reagent(/datum/reagent/water/holywater))
		remove_duration(HOLY_WATER_CURE_RATE * delta_time)
*/

/datum/status_effect/revenant_blight/proc/remove_when_ghost_dies(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/omen/revenant_blight
	incidents_left = INFINITY
	luck_mod = 0.6 // 60% chance of bad things happening
	damage_mod = 0.25 // 25% of normal damage

#undef MIN_EMOTE_COOLDOWN
#undef MAX_EMOTE_COOLDOWN
#undef HOLY_WATER_CURE_RATE
#undef MAX_BLIGHT_STAGES
