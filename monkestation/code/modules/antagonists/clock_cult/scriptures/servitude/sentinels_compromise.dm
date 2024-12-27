///how much do we heal per do_after() loop
#define HEALED_PER_LOOP 10
/datum/scripture/slab/sentinels_compromise
	name = "Sentinel's Compromise"
	desc = "Continuously heals non-toxin damage on a target then converts 80% of it back as toxin damage to you."
	tip = "Works well with Properity Prisms. Cannot be used by cogscarabs."
	power_cost = 80
	cogs_required = 1
	invocation_time = 1 SECONDS //short invocation but using it also takes some time afterwards
	invocation_text = list("By the light of Eng'Ine...") //the second line is said when used on someone
	button_icon_state = "Sentinel's Compromise"
	category = SPELLTYPE_SERVITUDE //you have a healing spell please please PLEASE use it
	slab_overlay = "compromise"
	use_time = 15 SECONDS
	recital_sound = 'sound/magic/magic_missile.ogg'
	fast_invoke_mult = 0.8

/datum/scripture/slab/sentinels_compromise/check_special_requirements(mob/user)
	if(issilicon(user))
		invocation_time = 10 * initial(invocation_time)
	else
		invocation_time = initial(invocation_time) //might be worth making a silicon_invoke() proc or something
	return ..()

/datum/scripture/slab/sentinels_compromise/apply_effects(mob/living/healed_mob)
	if(!istype(healed_mob) || !IS_CLOCK(invoker) || !IS_CLOCK(healed_mob))
		return FALSE

	if(iscogscarab(invoker))
		to_chat(invoker, span_warning("Your form is too frail to take the burden of another."))
		return FALSE

	if(!do_after(invoker, invocation_time, healed_mob))
		return FALSE

	healed_mob.cure_husk()
	if(healed_mob.stat == DEAD) //technically the husk healing is free but it should be fine
		return FALSE

	//MMMMMM, CHUNKY
	healed_mob.blood_volume = BLOOD_VOLUME_NORMAL
	healed_mob.set_nutrition(NUTRITION_LEVEL_FULL)
	healed_mob.bodytemperature = BODYTEMP_NORMAL
	healed_mob.pain_controller?.remove_all_pain()
	if(apply_heal(healed_mob))
		while(do_after(invoker, invocation_time, healed_mob))
			if(!apply_heal(healed_mob)) //im sure theres a better way to do this but im too tired
				break

	clockwork_say(invoker, text2ratvar("Wounds will close."), TRUE)
	new /obj/effect/temp_visual/heal(get_turf(healed_mob), "#1E8CE1")
	return TRUE

/datum/scripture/slab/sentinels_compromise/proc/apply_heal(mob/living/healed_mob)
	var/healed_amount = -healed_mob.heal_ordered_damage(HEALED_PER_LOOP, list(BRUTE, BURN, OXY, CLONE, BRAIN))
	healed_mob.stamina.adjust(HEALED_PER_LOOP)
	healed_mob.reagents.remove_reagent(/datum/reagent/water/holywater, HEALED_PER_LOOP)
	if(!invoker.adjustToxLoss(healed_amount * 0.8, TRUE, TRUE) || invoker.getToxLoss() > 80 || healed_amount < HEALED_PER_LOOP)
		return FALSE
	return TRUE

#undef HEALED_PER_LOOP
