/mob/living/basic/bingle/
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

	maxHealth = 150
	health = 150
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	bodytemp_cold_damage_limit = TCMB

	obj_damage = 100
	melee_damage_lower = 10
	melee_damage_upper = 10
	melee_attack_cooldown = CLICK_CD_MELEE

	lighting_cutoff_red = 10
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35

	attack_verb_continuous = "bings"
	attack_verb_simple = "bing"
	attack_sound = 'sound/effects/blobattack.ogg' //'monkestation/code/moduoles/veth_misc_items/bingle/sound/bingle_attack.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	butcher_results = null
	var/evolved = FALSE

	light_outer_range = 4

/mob/living/basic/bingle/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!isliving(target))
		return ..()
	var/mob/living/mob_target = target
	mob_target.Disorient(6 SECONDS, 5, paralyze = 10 SECONDS, stack_status = FALSE)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	return ..()
/mob/living/basic/bingle/Initialize(mapload)
	. = ..()
	GLOB.bingle_mobs += src

/mob/living/basic/bingle/lord
	name = "bingle lord"
	real_name = "bingle lord"
	desc = "A rather large funny lil blue guy."
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglelord.dmi'
	icon_state = "binglelord"
	icon_living = "binglelord"
	icon_dead = "binglelord"

	melee_damage_lower = 20
	melee_damage_upper = 20
	var/pit_spawner = /datum/action/cooldown/bingle/spawn_hole

/mob/living/basic/bingle/lord/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/bingle/spawn_hole/makehole = new pit_spawner(src)
	makehole.Grant(src)
	GLOB.bingle_mobs += src

/mob/living/basic/bingle/Initialize(mapload)
	. = ..()
	RegisterSignal(src, BINGLE_EVOLVE, PROC_REF(evolve))

/mob/living/basic/bingle/Life(seconds_between_ticks, times_fired)
	. = ..()
	update_icon()

/mob/living/basic/bingle/lord/Life(seconds_between_ticks, times_fired)
	. = ..()
	update_icon()

/mob/living/basic/bingle/proc/evolve()
	var/mob/living/basic/bingle/bongle = src
	bongle.maxHealth = 300
	bongle.health = 300
	bongle.obj_damage = 100
	bongle.melee_damage_lower = 15
	bongle.melee_damage_upper = 20
	bongle.armour_penetration = 10

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
		/datum/reagent/consumable/ethanol
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

	// Pick 3-5 random chemicals and create smoke with each
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
