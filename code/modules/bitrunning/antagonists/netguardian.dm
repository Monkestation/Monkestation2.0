/datum/antagonist/bitrunning_glitch/netguardian
	name = ROLE_NETGUARDIAN
	threat = 90
	show_in_antagpanel = TRUE

/mob/living/basic/netguardian
	name = "netguardian prime"
	desc = "The last line of defense against organic intrusion. It doesn't appear happy to see you."
	icon = 'icons/mob/nonhuman-player/netguardian.dmi'
	icon_state = "netguardian"
	icon_living = "netguardian"
	icon_dead = "crash"
	pixel_x = -8
	base_pixel_x = -8

	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	mob_size = MOB_SIZE_HUGE

	health = 500
	maxHealth = 500
	melee_damage_lower = 45
	melee_damage_upper = 65

	attack_verb_continuous = "drills"
	attack_verb_simple = "drills"
	attack_sound = 'sound/weapons/drill.ogg'
	attack_vis_effect = ATTACK_EFFECT_MECHFIRE
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"

	faction = list(
		FACTION_BOSS,
		FACTION_HIVEBOT,
		FACTION_HOSTILE,
		FACTION_SPIDER,
		FACTION_STICKMAN,
		ROLE_ALIEN,
		ROLE_GLITCH,
		ROLE_SYNDICATE,
	)

	speech_span = SPAN_ROBOT
	death_message = "malfunctions!"

	lighting_cutoff_red = 30
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 20

	habitable_atmos = null
	bodytemp_cold_damage_limit = TCMB
	ai_controller = /datum/ai_controller/basic_controller/netguardian
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_PATH_HUD = HUD_LIST_LIST)
	bodytemp_heat_damage_limit = INFINITY
	bodytemp_cold_damage_limit = -1

/mob/living/basic/netguardian/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	AddComponent(/datum/component/ranged_attacks, \
		casing_type = /obj/item/ammo_casing/c46x30mm, \
		projectile_sound = 'sound/weapons/gun/smg/shot.ogg', \
		burst_shots = 6 \
	)

	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/netguardian/rockets = new(src)
	rockets.Grant(src)
	ai_controller.set_blackboard_key(BB_NETGUARDIAN_ROCKET_ABILITY, rockets)

	AddElement(/datum/element/simple_flying)
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/netguardian/death(gibbed)
	do_sparks(number = 3, cardinal_only = TRUE, source = src)
	playsound(src, 'sound/mecha/weapdestr.ogg', 100)
	return ..()

/mob/living/basic/netguardian/update_overlays()
	. = ..()
	if (stat == DEAD)
		return
	. += emissive_appearance(icon, "netguardian_emissive", src)

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/netguardian
	name = "2E Rocket Launcher"
	button_icon = 'icons/obj/weapons/guns/ammo.dmi'
	button_icon_state = "rocketbundle"
	cooldown_time = 30 SECONDS
	default_projectile_spread = 15
	projectile_type = /obj/projectile/bullet/rocket
	shot_count = 3

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/netguardian/Activate(atom/target_atom)
	var/mob/living/player = owner
	playsound(player, 'sound/mecha/skyfall_power_up.ogg', 120)
	player.say("target acquired.", "machine")

	var/overlay_icon = 'icons/mob/nonhuman-player/netguardian.dmi'
	var/list/overlays = list()
	overlays += mutable_appearance(overlay_icon, "scan")
	overlays += mutable_appearance(overlay_icon, "rockets")
	overlays += emissive_appearance(overlay_icon, "scan", player)
	player.add_overlay(overlays)

	StartCooldown()
	if(!do_after(player, 1.5 SECONDS))
		player.balloon_alert(player, "cancelled")
		StartCooldown(cooldown_time * 0.2)
		player.cut_overlay(overlays)
		return TRUE

	player.cut_overlay(overlays)
	attack_sequence(owner, target_atom)
	return TRUE

/datum/ai_controller/basic_controller/netguardian
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_wounded_target,
		/datum/ai_planning_subtree/targeted_mob_ability/fire_rockets,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/netguardian,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/netguardian
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/netguardian

/datum/ai_behavior/basic_ranged_attack/netguardian
	action_cooldown = 1 SECONDS
	avoid_friendly_fire = TRUE

/datum/ai_planning_subtree/targeted_mob_ability/fire_rockets
	ability_key = BB_NETGUARDIAN_ROCKET_ABILITY
	finish_planning = FALSE
