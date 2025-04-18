/datum/symptom/teratoma
	name = "Teratoma Syndrome"
	desc = "Causes the infected to oversynthesize stem cells engineered towards organ generation, causing damage to the host's organs in the process. Said generated organs are expelled from the body upon completion."
	stage = 3
	badness = EFFECT_DANGER_HARMFUL
	severity = 3
	COOLDOWN_DECLARE(organ_cooldown)

/datum/symptom/teratoma/activate(mob/living/carbon/mob)
	if(ismouse(mob))
		var/mob/living/basic/mouse/mouse = mob
		mouse.splat() //tumors are bad for you, tumors equal to your body in size doubley so
		return
	if(!iscarbon(mob) || !COOLDOWN_FINISHED(src, organ_cooldown))
		return
	COOLDOWN_START(src, organ_cooldown, 2 MINUTES)

	var/list/eligible_organs = get_eligible_organs(mob)
	if(!length(eligible_organs))
		return
	var/organ_type = pick(eligible_organs)
	var/obj/item/organ/spawned_organ = new organ_type(mob.drop_location())

	var/damage = 0
	if(ismonkey(mob)) //monkeys are smaller and thus have less space for human-organ sized tumors
		damage += 15
	if(mob.getBruteLoss() <= 50)
		damage += 5
	if(damage > 0)
		mob.take_overall_damage(brute = damage)
	mob.visible_message(
		span_warning("\A [spawned_organ] is extruded from \the [mob]'s body and falls to the ground!"),
		span_warning("\A [spawned_organ] is extruded from your body and falls to the ground!")
	)

/datum/symptom/teratoma/proc/get_eligible_organs(mob/living/carbon/target)
	// blacklist, mostly for jank organs that shouldn't exist on their own
	var/static/list/blacklisted_organs
	if(isnull(blacklisted_organs))
		blacklisted_organs = typecacheof(list(
			/obj/item/organ/external/anime_bottom,
			/obj/item/organ/external/anime_head,
			/obj/item/organ/external/anime_middle,
			/obj/item/organ/external/floran_leaves,
			/obj/item/organ/external/wings,
			/obj/item/organ/external/wings/functional,
			/obj/item/organ/internal/body_egg,
			/obj/item/organ/internal/borer_body,
			/obj/item/organ/internal/empowered_borer_egg,
		))
		// we only want to blacklist the "parent" wing types, which should not exist on their own - the bioscrambler blacklist does the same thing.
		blacklisted_organs -= subtypesof(/obj/item/organ/external/wings/functional)
		blacklisted_organs -= typesof(/obj/item/organ/external/wings/moth)

	. = list()
	if(!iscarbon(target))
		return
	for(var/obj/item/organ/organ in target.organs)
		if(is_type_in_typecache(organ, blacklisted_organs))
			continue
		if(organ.organ_flags & ORGAN_SYNTHETIC)
			continue
		. |= organ.type

