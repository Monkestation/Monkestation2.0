/// Minimum cooldown time before we start trying to do effect emotes again.
#define MIN_EMOTE_COOLDOWN		(10 SECONDS)
/// Maximum cooldown time before we start trying to do effect emotes again.
#define MAX_EMOTE_COOLDOWN		(45 SECONDS)
/// How many seconds are shaved off each tick while holy water is in the victim's system.
#define HOLY_WATER_CURE_RATE	(5 SECONDS)

//Blight: Infects nearby humans and in general messes living stuff up.
/datum/action/cooldown/spell/aoe/revenant/blight
	name = "Blight"
	desc = "Causes nearby living things to waste away."
	button_icon_state = "blight"
	cooldown_time = 20 SECONDS

	aoe_radius = 3
	cast_amount = 50
	unlock_amount = 75

/datum/action/cooldown/spell/aoe/revenant/blight/cast_on_thing_in_aoe(turf/victim, mob/living/basic/revenant/caster)
	for(var/mob/living/mob in victim)
		if(mob == caster)
			continue
		if(mob.can_block_magic(antimagic_flags))
			to_chat(caster, span_warning("The spell had no effect on [mob]!"))
			continue
		new /obj/effect/temp_visual/revenant(get_turf(mob))
		if(iscarbon(mob))
			if(ishuman(mob))
				mob.apply_status_effect(/datum/status_effect/revenant_blight)
			else
				mob.reagents?.add_reagent(/datum/reagent/toxin/plasma, 5)
		else
			mob.adjustToxLoss(5)
	for(var/obj/structure/spacevine/vine in victim) //Fucking with botanists, the ability.
		vine.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(vine.loc)
		QDEL_IN(vine, 10)
	for(var/obj/structure/glowshroom/shroom in victim)
		shroom.add_atom_colour("#823abb", TEMPORARY_COLOUR_PRIORITY)
		new /obj/effect/temp_visual/revenant(shroom.loc)
		QDEL_IN(shroom, 10)
	for(var/atom/movable/tray in victim)
		if(!tray.GetComponent(/datum/component/plant_growing))
			continue

		new /obj/effect/temp_visual/revenant(tray.loc)
		SEND_SIGNAL(tray, COMSIG_GROWING_ADJUST_TOXIN, rand(45, 55))
		SEND_SIGNAL(tray, COMSIG_GROWING_ADJUST_PEST, rand(8, 10))
		SEND_SIGNAL(tray, COMSIG_GROWING_ADJUST_WEED, rand(8, 10))

/datum/status_effect/revenant_blight
	id = "revenant_blight"
	duration = 5 MINUTES
	tick_interval = 0
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	remove_on_fullheal = TRUE
	/// The omen/cursed component applied to the victim.
	var/datum/component/omen/revenant_blight/misfortune
	/// The revenant that cast this blight.
	var/mob/living/basic/revenant/gohst
	/// Cooldown var for when the status effect can emote again.
	COOLDOWN_DECLARE(next_emote)

/datum/status_effect/revenant_blight/on_creation(mob/living/new_owner, mob/living/basic/revenant/gohst)
	. = ..()
	if(. && istype(gohst))
		src.gohst = gohst
		RegisterSignal(gohst, COMSIG_QDELETING, PROC_REF(remove_when_ghost_dies))

/datum/status_effect/revenant_blight/on_apply()
	misfortune = owner.AddComponent(/datum/component/omen/revenant_blight)
	owner.set_haircolor(COLOR_REVENANT, override = TRUE)
	to_chat(owner, span_revenminor("You feel [pick("suddenly sick", "a surge of nausea", "like your skin is <i>wrong</i>")]."))
	return ..()

/datum/status_effect/revenant_blight/on_remove()
	QDEL_NULL(misfortune)
	owner.set_haircolor(null, override = TRUE)
	if(gohst)
		UnregisterSignal(gohst, COMSIG_QDELETING)
		gohst = null
	to_chat(owner, span_notice("You feel better."))

/datum/status_effect/revenant_blight/tick(seconds_per_tick, times_fired)
	var/delta_time = DELTA_WORLD_TIME(SSfastprocess)
	if(owner.stat == CONSCIOUS && COOLDOWN_FINISHED(src, next_emote) && SPT_PROB(5, delta_time))
		owner.emote(pick("pale", "shiver", "cries"))
		COOLDOWN_START(src, next_emote, rand(MIN_EMOTE_COOLDOWN, MAX_EMOTE_COOLDOWN))
	if(owner.reagents?.has_reagent(/datum/reagent/water/holywater))
		remove_duration(HOLY_WATER_CURE_RATE * delta_time)

/datum/status_effect/revenant_blight/proc/remove_when_ghost_dies(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/omen/revenant_blight
	incidents_left = INFINITY
	luck_mod = 0.6 // 60% chance of bad things happening
	damage_mod = 0.25 // 25% of normal damage

#undef HOLY_WATER_CURE_RATE
#undef MAX_EMOTE_COOLDOWN
#undef MIN_EMOTE_COOLDOWN
