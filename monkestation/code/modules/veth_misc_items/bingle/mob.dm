/mob/living/basic/bingle
	name = "bingle"
	real_name = "bingle"
	desc = "A funny lil blue guy."
	speak_emote = list("screeches", "whines", "blurbles", "bingles")
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/bingles.dmi'
	icon_state = "bingle"
	icon_living = "bingle"
	icon_dead = "bingle"
	istate = ISTATE_HARM

	mob_biotypes = MOB_BEAST
	pass_flags = PASSTABLE

	maxHealth = 100
	health = 100
	habitable_atmos = null
	bodytemp_cold_damage_limit = -1
	bodytemp_heat_damage_limit = INFINITY

	obj_damage = 70
	melee_damage_lower = 5
	melee_damage_upper = 5
	melee_attack_cooldown = CLICK_CD_MELEE

	lighting_cutoff_red = 10
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35

	attack_verb_continuous = "bings"
	attack_verb_simple = "bing"
	attack_sound = 'sound/effects/blobattack.ogg' //'monkestation/code/moduoles/veth_misc_items/bingle/sound/bingle_attack.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	butcher_results = null

	light_outer_range = 4

	var/evolved = FALSE
	/// The pit from which this bingle came.
	var/obj/structure/bingle_hole/linked_pit
	var/static/list/bingle_traits = list(
		TRAIT_BINGLE,
		TRAIT_CLUMSY,
		TRAIT_DUMB,
		TRAIT_NO_PAIN_EFFECTS,
	)

/mob/living/basic/bingle/Initialize(mapload, obj/structure/bingle_hole/origin_pit)
	. = ..()
	RegisterSignal(src, COMSIG_LIVING_BINGLE_EVOLVE, PROC_REF(evolve))
	add_traits(bingle_traits, INNATE_TRAIT)
	set_linked_pit(origin_pit)

/mob/living/basic/bingle/Destroy()
	if(linked_pit)
		UnregisterSignal(linked_pit, COMSIG_QDELETING)
	linked_pit = null
	return ..()

/mob/living/basic/bingle/proc/set_linked_pit(obj/structure/bingle_hole/new_pit)
	if(linked_pit)
		UnregisterSignal(linked_pit, COMSIG_QDELETING)
		linked_pit = null
	if(!QDELETED(new_pit))
		RegisterSignal(new_pit, COMSIG_QDELETING, PROC_REF(on_pit_destruction))
		linked_pit = new_pit

/mob/living/basic/bingle/proc/on_pit_destruction()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		gib()

/mob/living/basic/bingle/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!isliving(target))
		return ..()
	var/mob/living/mob_target = target
	mob_target.Disorient(3 SECONDS)
	mob_target.stamina?.adjust(-32)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	return ..()

/mob/living/basic/bingle/mind_initialize()
	. = ..()
	if(!IS_BINGLE(src))
		mind.add_antag_datum(/datum/antagonist/bingle)

/mob/living/basic/bingle/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	update_icon()
	if(!linked_pit || get_dist(src, linked_pit) > linked_pit.healing_range)
		return
	if(adjust_health(-5 * seconds_per_tick, updating_health = FALSE))
		updatehealth()
		new /obj/effect/temp_visual/heal(get_turf(src), COLOR_BLUE_LIGHT)

/mob/living/basic/bingle/lord
	name = "bingle lord"
	real_name = "bingle lord"
	desc = "A rather large funny lil blue guy."
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglelord.dmi'
	icon_state = "binglelord"
	icon_living = "binglelord"
	icon_dead = "binglelord"

	melee_damage_lower = 10
	melee_damage_upper = 15
	var/pit_spawner = /datum/action/cooldown/bingle/spawn_hole

/mob/living/basic/bingle/lord/Initialize(mapload, obj/structure/bingle_hole/origin_pit)
	. = ..()
	var/datum/action/cooldown/bingle/spawn_hole/makehole = new pit_spawner(src)
	makehole.Grant(src)

/mob/living/basic/bingle/armored
	icon_state = "bingle_armored"
	maxHealth = 300
	obj_damage = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	armour_penetration = 20
	evolved = TRUE

/mob/living/basic/bingle/proc/evolve()
	var/mob/living/basic/bingle/bongle = src
	bongle.maxHealth = 160
	bongle.health = 160
	bongle.obj_damage = 100
	bongle.melee_damage_lower = 10
	bongle.melee_damage_upper = 10
	bongle.armour_penetration = 0

/mob/living/basic/bingle/update_icon()
	. = ..()
	if(evolved)
		if(istate & ISTATE_HARM)
			icon_state = "binglearmored_combat"
		else
			icon_state = "binglearmored"
		return
	else if(istate & ISTATE_HARM)
		icon_state = "bingle_combat"
	else
		icon_state = "bingle"

/mob/living/basic/bingle/lord/update_icon()
	. = ..()
	if(istate & ISTATE_HARM)
		icon_state = "binglelord_combat"
	else
		icon_state = "binglelord"

/mob/living/basic/bingle/death(gibbed)
	. = ..()

	var/list/possible_chems = list(
		/datum/reagent/smoke_powder,
		/datum/reagent/toxin/plasma,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/drug/methamphetamine,
		/datum/reagent/toxin/histamine,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/water,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/colorful_reagent,
		/datum/reagent/glitter,
		/datum/reagent/consumable/sugar,
		/datum/reagent/lube,
		/datum/reagent/consumable/salt,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/omnizine,
		/datum/reagent/consumable/honey,
		/datum/reagent/clf3,
		/datum/reagent/fluorosurfactant,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/tea,
		/datum/reagent/medicine/ephedrine,
		/datum/reagent/medicine/diphenhydramine,
		/datum/reagent/consumable/garlic,
		/datum/reagent/consumable/banana,
		/datum/reagent/iron,
		/datum/reagent/copper,
		/datum/reagent/silver,
		/datum/reagent/gold,
		/datum/reagent/uranium,
		/datum/reagent/medicine/strange_reagent,
		/datum/reagent/toxin/acid,
		/datum/reagent/napalm,
		/datum/reagent/thermite,
		/datum/reagent/drug/krokodil,
		/datum/reagent/drug/bath_salts,
		/datum/reagent/drug/aranesp,
		/datum/reagent/consumable/pineapplejuice,
		/datum/reagent/consumable/tomatojuice,
		/datum/reagent/consumable/potato_juice,
		/datum/reagent/consumable/limejuice,
		/datum/reagent/consumable/orangejuice
	)

	// Pick 3-5 random chemicals and create smoke with each
	var/chemicals_to_use = rand(3, 5)
	for(var/i = 1 to chemicals_to_use)
		var/chemical_type = pick(possible_chems)
		do_chem_smoke(
			range = 2,
			holder = src,
			location = get_turf(src),
			reagent_type = chemical_type,
			reagent_volume = rand(5, 15),
			log = TRUE
		)
	if(!gibbed)
		src.gib()

/mob/living/basic/bingle/lord/death(gibbed)
	. = ..()

	var/list/possible_chems = list(
		/datum/reagent/smoke_powder,
		/datum/reagent/toxin/plasma,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/drug/methamphetamine,
		/datum/reagent/toxin/histamine,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/water,
		/datum/reagent/consumable/ethanol
	)

	// Pick 10-15 random chemicals and create smoke with each
	var/chemicals_to_use = rand(10, 15)
	for(var/i = 1 to chemicals_to_use)
		var/chemical_type = pick(possible_chems)
		do_chem_smoke(
			range = 2,
			holder = src,
			location = get_turf(src),
			reagent_type = chemical_type,
			reagent_volume = rand(5, 15),
			log = TRUE
		)
	if(!gibbed)
		src.gib()
