/obj/vehicle/sealed/mecha/vendozer
	desc = "The Ultimate statement of dissatisfaction towards the station, the Vendozer wrecks havoc to all that has disgruntled this employee."
	name = "\proper The Vendozer"
	icon = 'icons/mecha/largetanks.dmi'
	icon_state = "vendozer"
	base_icon_state = "vendozer"
	SET_BASE_PIXEL(-24, 0)
	step_energy_drain = 50 // 5x drain holy fuck
	movedelay = 5.25 // slowish.
	max_integrity = 750 // shes fat, very fucking fat
	armor_type = /datum/armor/vendozer
	max_temperature = 25000
	force = 60 // dont get hit
	internal_damage_threshold = 18
	wreckage = null
	mech_type = EXOSUIT_MODULE_TANK
	mecha_flags = OMNIDIRECTIONAL_ATTACKS
	bumpsmash = TRUE
	var/crushdmglower = 10
	var/crushdmgupper = 15
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/pipegun,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(/obj/item/mecha_parts/mecha_equipment/generator),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 1,
		MECHA_ARMOR = 3,  // this one can be modified!
	)

/datum/armor/vendozer
	melee = 50
	bullet = 35
	laser = 25
	energy = 25
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/vendozer/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		for(var/mob/living/carbon/human/future_pancake in loc)
			run_over(future_pancake)

/obj/vehicle/sealed/mecha/vendozer/proc/run_over(mob/living/carbon/human/crushed)
	log_combat(src, crushed, "run over", addition = "(DAMTYPE: [uppertext(BRUTE)])")
	crushed.visible_message(
		span_danger("[src] drives over [crushed]!"),
		span_userdanger("[src] drives over you!"),
	)

	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	var/damage = rand(crushdmglower, crushdmgupper)
	crushed.apply_damage(2 * damage, BRUTE, BODY_ZONE_HEAD)
	crushed.apply_damage(2 * damage, BRUTE, BODY_ZONE_CHEST)
	crushed.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_LEG)
	crushed.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_LEG)
	crushed.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_ARM)
	crushed.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_ARM)

	add_mob_blood(crushed)

	var/turf/below_us = get_turf(src)
	below_us.add_mob_blood(crushed)

	AddComponent(/datum/component/blood_walk, \
		blood_type = /obj/effect/decal/cleanable/blood/tracks, \
		target_dir_change = TRUE, \
		transfer_blood_dna = TRUE, \
		max_blood = 4)

/obj/vehicle/sealed/mecha/vendozer/admeme
	desc = "You pissed off god, or corporate, good luck."
	name = "\improper Vendozer, Doom edition"
	icon = 'icons/mecha/largetanks.dmi'
	icon_state = "vendozer"
	base_icon_state = "vendozer"
	SET_BASE_PIXEL(-24, 0)
	step_energy_drain = 1
	movedelay = 0.7
	max_integrity = 1750
	armor_type = /datum/armor/vendozermeme
	max_temperature = 25000
	force = 95
	internal_damage_threshold = 18
	wreckage = null
	mech_type = EXOSUIT_MODULE_TRASHTANK
	mecha_flags = OMNIDIRECTIONAL_ATTACKS
	bumpsmash = TRUE
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/mininuke,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(/obj/item/mecha_parts/mecha_equipment/generator),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 1,
		MECHA_ARMOR = 3,
	)

/datum/armor/vendozermeme
	melee = 70
	bullet = 75
	laser = 75
	energy = 75
	bomb = 100
	fire = 100
	acid = 100
