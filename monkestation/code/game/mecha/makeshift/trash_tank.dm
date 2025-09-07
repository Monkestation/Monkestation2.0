/obj/vehicle/sealed/mecha/trash_tank
	desc = "A trashcart that seems to be repurposed as the basis of a tank hull. with a turret and an electric engine strapped into it. It's a miracle it's even working"
	name = "trash tank"
	icon = 'monkestation/icons/mecha/makeshift_mechs.dmi'
	icon_state = "trash_tank"
	base_icon_state = "trash_tank"
	silicon_icon_state = "null"
	max_integrity = 200
	force = 20
	movedelay = 1.5
	stepsound = 'monkestation/sound/mecha/tank_treads.ogg'
	turnsound = 'monkestation/sound/mecha/tank_treads.ogg'
	mecha_flags = IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE //can't strafe bruv
	armor_type = /datum/armor/scrap_tank //mediocre armor, do you expect any better?
	internal_damage_threshold = 60 //Its got shitty durability
	var/crushdmglower = 2
	var/crushdmgupper = 5
	wreckage = /obj/structure/closet/crate/trashcart
	mech_type = EXOSUIT_MODULE_TRASHTANK
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 1,
		MECHA_POWER = 0,
		MECHA_ARMOR = 0,
	)

/datum/armor/scrap_tank
	melee = 30
	bullet = 20
	laser = 20
	energy = 10
	bomb = 20
	fire = 70
	acid = 60

/datum/armor/scrap_tank/uparmoured
	melee = 60
	bullet = 40
	laser = 40
	energy = 20
	fire = 70
	acid = 60

/obj/vehicle/sealed/mecha/trash_tank/proc/upgrade()
	name = "up-armoured trash tank"
	icon_state = "trash_tank-armoured"
	base_icon_state = "trash_tank-armoured"
	update_appearance()

	armor_type = /datum/armor/scrap_tank/uparmoured


/obj/vehicle/sealed/mecha/trash_tank/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(has_gravity())
		for(var/mob/living/carbon/human/future_pancake in loc)
			run_over(future_pancake)

/obj/vehicle/sealed/mecha/trash_tank/proc/run_over(mob/living/carbon/human/crushed)
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

