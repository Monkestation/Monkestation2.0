#define INTERDICTION_LENS_RANGE 4
#define POWER_PER_PERSON 3

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens
	name = "interdiction lens"
	desc = "A mesmerizing light that flashes to a rhythm that you just can't stop tapping to."
	clockwork_desc = "A small device which will slow down nearby attackers and projectiles at a large power cost, both active and passive."
	icon_state = "interdiction_lens"
	base_icon_state = "interdiction_lens"
	anchored = TRUE
	break_message = span_warning("The interdiction lens breaks into multiple fragments, which gently float to the ground.")
	max_integrity = 150
	passive_consumption = 5
	/// Dampening field around the interdiction
	var/datum/proximity_monitor/advanced/bubble/projectile_dampener/clockcult/dampening_field

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens/Initialize(mapload)
	. = ..()
	dampening_field = new(src, INTERDICTION_LENS_RANGE, TRUE, src)

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens/Destroy()
	if(enabled)
		STOP_PROCESSING(SSobj, src)
	QDEL_NULL(dampening_field)
	return ..()

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens/process(delta_time)
	. = ..()
	if(!.)
		return

	for(var/mob/living/living_mob in viewers(INTERDICTION_LENS_RANGE, src))
		if(!IS_CLOCK(living_mob) && use_energy(POWER_PER_PERSON))
			living_mob.apply_status_effect(STATUS_EFFECT_INTERDICTION)

	for(var/obj/vehicle/sealed/mecha/mech in range(INTERDICTION_LENS_RANGE, src))
		var/clock_pilot = FALSE
		for(var/mob/living/pilot in mech.occupants)
			if(!IS_CLOCK(pilot))
				continue

			clock_pilot = TRUE
			break

		if(clock_pilot || !use_energy(POWER_PER_PERSON))
			continue

		mech.emp_act(EMP_HEAVY)
		do_sparks(mech, TRUE, mech)

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens/repowered()
	. = ..()
	flick("interdiction_lens_recharged", src)

	if(istype(dampening_field))
		QDEL_NULL(dampening_field)

	dampening_field = new(src, INTERDICTION_LENS_RANGE, TRUE, src)

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens/depowered()
	. = ..()
	flick("interdiction_lens_discharged", src)
	QDEL_NULL(dampening_field)

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens/free

/obj/structure/destructible/clockwork/gear_base/powered/interdiction_lens/free/use_energy(amount)
	return TRUE

//Dampening field

/datum/proximity_monitor/advanced/bubble/projectile_dampener/clockcult/setup_effect_directions()
	return NONE // Should be invisible

/datum/proximity_monitor/advanced/bubble/projectile_dampener/clockcult/draw_effect()
	return NONE // Should be invisible

/datum/proximity_monitor/advanced/bubble/projectile_dampener/clockcult/catch_bullet_effect(obj/projectile/bullet)
	if(isliving(bullet.firer))
		var/mob/living/living_firer = bullet.firer
		if(IS_CLOCK(living_firer))
			return
	return ..()

/datum/proximity_monitor/advanced/bubble/projectile_dampener/clockcult/release_bullet_effect(obj/projectile/bullet)
	if(isliving(bullet.firer))
		var/mob/living/living_firer = bullet.firer
		if(IS_CLOCK(living_firer))
			return
	return ..()

#undef INTERDICTION_LENS_RANGE
#undef POWER_PER_PERSON
