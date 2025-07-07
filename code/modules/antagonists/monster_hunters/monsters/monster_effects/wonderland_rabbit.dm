// not a subtype of /mob/living/basic/rabbit as those have several elements we don't want to inherit
/mob/living/basic/wonderland_rabbit
	name = /mob/living/basic/rabbit::name
	desc = /mob/living/basic/rabbit::desc
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "white_rabbit"
	icon_living = "white_rabbit"
	dir = EAST // so it's consistent with the animation
	density = FALSE
	health = 75
	maxHealth = 75
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	basic_mob_flags = DEL_ON_DEATH
	gold_core_spawnable = NONE
	faction = list(FACTION_RABBITS)
	sentience_type = SENTIENCE_BOSS

	unsuitable_atmos_damage = 0
	bodytemp_cold_damage_limit = -1
	bodytemp_heat_damage_limit = INFINITY
	/// Innate traits paradox rabbits have.
	/// Remember, these are not normal rabbits by any means,
	/// they are fantastical entities that don't exactly follow the same laws of reality.
	var/static/list/innate_traits = list(
		TRAIT_ANTIMAGIC,
		TRAIT_NO_MINDSWAP,
		TRAIT_NO_RANDOM_SENTIENCE,
		TRAIT_SHOCKIMMUNE,
	)

/mob/living/basic/wonderland_rabbit/Initialize(mapload)
	add_traits(innate_traits, INNATE_TRAIT)
	return ..()

/mob/living/basic/wonderland_rabbit/death(gibbed)
	var/obj/effect/wonderland_rabbit_exit/exit = new(loc)
	exit.setDir(dir)
	return ..()

/mob/living/basic/wonderland_rabbit/examine(mob/living/user)
	. = ..()
	if(!isliving(user) || IS_MONSTERHUNTER(user) || (FACTION_RABBITS in user.faction))
		return
	if(is_monster_hunter_prey(user) || IS_CULTIST(user) || IS_CLOCK(user) || IS_WIZARD(user))
		. += span_warning("You feel sick as you look into its eyes...")
		user.apply_status_effect(/datum/status_effect/rabbit_sickness)

/mob/living/basic/wonderland_rabbit/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src)

/obj/effect/wonderland_rabbit_enter
	name = "rabbit?"
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "rabbit_enter"

/obj/effect/wonderland_rabbit_enter/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(finish_animation)), 4 SECONDS)

/obj/effect/wonderland_rabbit_enter/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src)

/obj/effect/wonderland_rabbit_enter/proc/finish_animation()
	new /mob/living/basic/wonderland_rabbit(loc)
	qdel(src)

/obj/effect/wonderland_rabbit_exit
	name = "rabbit"
	icon = 'monkestation/icons/mob/rabbit.dmi'
	icon_state = "rabbit_hole"

/obj/effect/wonderland_rabbit_exit/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 8 SECONDS)

/obj/effect/wonderland_rabbit_exit/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src)

/datum/status_effect/rabbit_sickness
	id = "rabbit_sickness"
	duration = 3 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	COOLDOWN_DECLARE(message_cooldown)

/datum/status_effect/rabbit_sickness/on_apply()
	. = ..()
	owner.set_pain_mod(id, 1.5)

/datum/status_effect/rabbit_sickness/on_remove()
	owner.unset_pain_mod(id)
	return ..()

/datum/status_effect/rabbit_sickness/tick(seconds_per_tick, times_fired)
	owner.set_hallucinations_if_lower(1 MINUTES)

	if(SPT_PROB(5, seconds_per_tick))
		owner.adjust_disgust(rand(2, 5) * seconds_per_tick)

	if(owner.mob_mood && SPT_PROB(5, seconds_per_tick))
		var/amt_to_reduce = rand(5, 25) * seconds_per_tick
		owner.mob_mood.set_sanity(owner.mob_mood.sanity - amt_to_reduce)

	// only drains stamina if they have over 50%
	if(owner.stamina && owner.stamina.current >= (owner.stamina.maximum * 0.5) && SPT_PROB(3, seconds_per_tick))
		var/amt_to_drain = owner.stamina.maximum * (rand(10, 20) / 100) * seconds_per_tick
		owner.stamina.adjust(-amt_to_drain, forced = TRUE)

	if(SPT_PROB(3, seconds_per_tick))
		owner.adjust_confusion_up_to(rand(1 SECONDS, 2 SECONDS) * seconds_per_tick, 15 SECONDS)

	if(SPT_PROB(3, seconds_per_tick))
		owner.adjust_stutter_up_to(rand(2 SECONDS, 5 SECONDS) * seconds_per_tick, 1 MINUTES)

	if(COOLDOWN_FINISHED(src, message_cooldown) && SPT_PROB(1, seconds_per_tick))
		var/msg = pick(
			"I glimpse a grassy nightmare reflected in the windows...",
			"Am I merely prey, despite my power?",
			"My body aches, as if I shared my breath with an <i>incompatible</i> presence...",
		)
		to_chat(owner, span_hypnophrase(msg), type = MESSAGE_TYPE_WARNING)
		COOLDOWN_START(src, message_cooldown, 10 SECONDS)
