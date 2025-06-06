/// Pirate trooper subtype
/mob/living/basic/trooper/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	response_help_continuous = "pushes"
	response_help_simple = "push"
	speak_emote = list("yarrs")
	faction = list(FACTION_PIRATE)
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate

	/// The amount of money to steal with a melee attack
	var/plunder_credits = 25

/mob/living/basic/trooper/pirate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plundering_attacks, plunder_amount = plunder_credits)

/mob/living/basic/trooper/pirate/melee
	name = "Pirate Swashbuckler"
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration = 75
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate/melee)
	//MONKESTATION EDIT START - We use `light_(outer|inner)_range` instead of just `light_range`
	/* //MONKESTATION EDIT ORIGINAL
	light_range = 2
	*/
	light_outer_range = 2
	//MONKESTATION EDIT END
	light_power = 2.5
	light_color = COLOR_SOFT_RED
	loot = list(
		/obj/effect/mob_spawn/corpse/human/pirate/melee,
		/obj/item/melee/energy/sword/pirate,
	)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/melee
	r_hand = /obj/item/melee/energy/sword/pirate
	plunder_credits = 50 //they hit hard so they steal more

/mob/living/basic/trooper/pirate/melee/space
	name = "Space Pirate Swashbuckler"
	unsuitable_atmos_damage = 0
	//MONKESTATION EDIT START - We use `bodytemp_cold_damage_limit` instead of `minimum_survivable_temperature`
	/* //MONKESTATION EDIT ORIGINAL
	minimum_survivable_temperature = 0
	*/
	bodytemp_cold_damage_limit = -1
	//MONKESTATION EDIT END
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate/melee/space)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/melee/space

/mob/living/basic/trooper/pirate/melee/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/basic/trooper/pirate/ranged
	name = "Pirate Gunner"
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate/ranged)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/ranged
	r_hand = /obj/item/gun/energy/laser
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	/// Type of bullet we use
	var/projectiletype = /obj/projectile/beam/laser
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/weapons/laser.ogg'
	/// number of burst shots
	var/burst_shots = 2
	/// Time between taking shots
	var/ranged_cooldown = 6 SECONDS

/mob/living/basic/trooper/pirate/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = projectiletype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
	)

/mob/living/basic/trooper/pirate/ranged/space
	name = "Space Pirate Gunner"
	unsuitable_atmos_damage = 0
	//MONKESTATION EDIT START - We use `bodytemp_cold_damage_limit` instead of `minimum_survivable_temperature`
	/* //MONKESTATION EDIT ORIGINAL
	minimum_survivable_temperature = 0
	*/
	bodytemp_cold_damage_limit = -1
	//MONKESTATION EDIT END
	loot = list(/obj/effect/mob_spawn/corpse/human/pirate/ranged/space)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/pirate/ranged/space
	r_hand = /obj/item/gun/energy/e_gun/lethal

/mob/living/basic/trooper/pirate/ranged/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
