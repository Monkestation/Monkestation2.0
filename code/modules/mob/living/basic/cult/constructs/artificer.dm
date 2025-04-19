/mob/living/basic/construct/artificer
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining the Cult of Nar'Sie's armies."
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm_continuous = "viciously beats"
	response_harm_simple = "viciously beat"
	obj_damage = 60
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "rams"
	attack_verb_simple = "ram"
	attack_sound = 'sound/weapons/punch2.ogg'
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)
	playstyle_string = "<b>You are an Artificer. You are incredibly weak and fragile, \
		but you are able to construct fortifications, use magic missile, and repair allied constructs, shades, \
		and yourself (by clicking on them). Additionally, <i>and most important of all,</i> you can create new constructs \
		by producing soulstones to capture souls, and shells to place those soulstones into.</b>"

	can_repair = TRUE
	can_repair_self = TRUE
	smashes_walls = TRUE
	construct_type = "Artificer"
	///The health HUD applied to this mob.
	var/health_hud = DATA_HUD_MEDICAL_ADVANCED

/mob/living/basic/construct/artificer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	var/datum/atom_hud/datahud = GLOB.huds[health_hud]
	datahud.show_to(src)

/// Hostile NPC version. Heals nearby constructs and cult structures, avoids targets that aren't extremely hurt.
/mob/living/basic/construct/artificer/hostile
	ai_controller = /datum/ai_controller/basic_controller/artificer
	smashes_walls = FALSE
	melee_attack_cooldown = 2 SECONDS

// Alternate artificer themes
/mob/living/basic/construct/artificer/angelic
	desc = "A bulbous construct dedicated to building and maintaining holy armies."
	theme = THEME_HOLY
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/soulstone/purified,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)

/mob/living/basic/construct/artificer/angelic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ANGELIC, INNATE_TRAIT)

/mob/living/basic/construct/artificer/mystic
	theme = THEME_WIZARD
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone/mystic,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)

/mob/living/basic/construct/artificer/noncult
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone/noncult,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/innate/cult/create_rune/revive,
	)

/mob/living/basic/construct/artificer/perfect
	icon_state = "artificer2"
	icon_living = "artificer2"
	icon_dead = "artificer2"
	icon = 'monkestation/code/modules/bloody_cult/icons/mob.dmi'
	see_in_dark = 7
	new_glow = TRUE
	construct_spells = list(
		/datum/action/cooldown/spell/conjure/cult_floor,
		/datum/action/cooldown/spell/conjure/cult_wall,
		/datum/action/cooldown/spell/conjure/soulstone,
		/datum/action/cooldown/spell/conjure/construct/lesser,
		/datum/action/cooldown/spell/pointed/conjure/struct,
		/datum/action/cooldown/spell/pointed/conjure/door,
		/datum/action/cooldown/spell/pointed/conjure/pylon,
		/datum/action/cooldown/spell/pointed/conjure/hex,
		)
	var/mob/living/basic/construct/heal_target = null
	var/obj/effect/overlay/artificerray/ray = null
	var/heal_range = 2
	var/list/minions = list()
	var/list/satellites = list()

/obj/abstract/satellite
	mouse_opacity = 0
	invisibility = 101
	icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi'
	icon_state = null

/mob/living/basic/construct/artificer/perfect/proc/update_satellites()
	var/turf/T = get_turf(src)
	while(satellites.len < 3)
		var/obj/abstract/satellite/S = new(T)
		satellites.Add(S)
	var/obj/abstract/satellite/satellite_A = satellites[1]
	var/obj/abstract/satellite/satellite_B = satellites[2]
	var/obj/abstract/satellite/satellite_C = satellites[3]
	satellite_A.forceMove(get_step(T, turn(dir, 180)))//behind
	satellite_B.forceMove(get_step(T, turn(dir, 135)))//behind on one side
	satellite_C.forceMove(get_step(T, turn(dir, 225)))//behind on the other side

/mob/living/basic/construct/artificer/perfect/Life()
	. = ..()
	if(. && heal_target)
		heal_target.health = min(heal_target.maxHealth, heal_target.health + round(heal_target.maxHealth/10))
		heal_target.update_icons()
		anim(target = heal_target, a_icon = 'icons/effects/effects.dmi', flick_anim = "const_heal", plane = ABOVE_LIGHTING_PLANE)
		move_ray()
	update_satellites()

/mob/living/basic/construct/artificer/perfect/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..()
	if (ray)
		move_ray()
	update_satellites()

/mob/living/basic/construct/artificer/perfect/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	. = ..()
	if (ray)
		move_ray()
	update_satellites()

/mob/living/basic/construct/artificer/perfect/proc/start_ray(var/mob/living/basic/construct/target)
	if (!istype(target))
		return
	if (locate(src) in target.healers)
		to_chat(src, span_warning("You are already healing \the [target].") )
		return
	if (ray)
		end_ray()
	target.healers.Add(src)
	heal_target = target
	ray = new (loc)
	to_chat(src, span_notice("You are now healing \the [target].") )
	move_ray()

/mob/living/basic/construct/artificer/perfect/UnarmedAttack(mob/living/basic/construct/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(isconstruct(attack_target) && (attack_target.health < attack_target.maxHealth))
		start_ray(attack_target)

/mob/living/basic/construct/artificer/perfect/proc/move_ray()
	if(heal_target && ray && heal_target.health < heal_target.maxHealth && get_dist(heal_target, src) <= heal_range && isturf(loc) && isturf(heal_target.loc))
		ray.forceMove(loc)
		var/disty = heal_target.y - src.y
		var/distx = heal_target.x - src.x
		var/newangle
		if(!disty)
			if(distx >= 0)
				newangle = 90
			else
				newangle = 270
		else
			newangle = arctan(distx/disty)
			if(disty < 0)
				newangle += 180
			else if(distx < 0)
				newangle += 360
		var/matrix/M = matrix()
		if (ray.oldloc_source && ray.oldloc_target && get_dist(src, ray.oldloc_source) <= 1 && get_dist(heal_target, ray.oldloc_target) <= 1)
			animate(ray, transform = turn(M.Scale(1, sqrt(distx*distx+disty*disty)), newangle), time = 1)
		else
			ray.transform = turn(M.Scale(1, sqrt(distx*distx+disty*disty)), newangle)
		ray.oldloc_source = src.loc
		ray.oldloc_target = heal_target.loc
	else
		end_ray()

/mob/living/basic/construct/artificer/perfect/proc/end_ray()
	if (heal_target)
		heal_target.healers.Remove(src)
		heal_target = null
	if (ray)
		QDEL_NULL(ray)

/obj/effect/overlay/artificerray
	name = "ray"
	icon = 'monkestation/code/modules/bloody_cult/icons/96x96.dmi'
	icon_state = "artificer_ray"
	layer = FLY_LAYER
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -29
	var/turf/oldloc_source = null
	var/turf/oldloc_target = null

/obj/effect/overlay/artificerray/narsie_act()
	return

/obj/effect/overlay/artificerray/ex_act()
	return

/obj/effect/overlay/artificerray/emp_act()
	return

/obj/effect/overlay/artificerray/blob_act()
	return

/obj/effect/overlay/artificerray/singularity_act()
	return
