//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

/obj/item/badmin_stone/lag
	name = "Lag Stone"
	desc = "The bane of a coder's existence."
	color = "#20B2AA"
	ability_text = list(
		"HELP INTENT: Set a point on the station, or if a point is already set, teleport back to it. Stuns you for a while, but heals you alot.",
		"DISARM INTENT: Shoot a disorienting projectile.",
		"HARM INTENT: Swap places with the victim, and then fire a projectile."
	)
	spell_types = list(
		/datum/action/cooldown/spell/infinity/doppelgangers,
		/datum/action/cooldown/spell/infinity/shuffle
	)
	gauntlet_spell_types = list(
		/datum/action/cooldown/spell/lag_stone_timestop
	)
	stone_type = LAG_STONE
	var/turf/teleport_point

/obj/item/badmin_stone/lag/help_act(atom/target, mob/user, proximity_flag)
	var/turf/target_turf = get_turf(target)
	if(target_turf == teleport_point)
		to_chat(user, span_notice("You unset [target_turf] as your teleportation point."))
		teleport_point = null
		return
	if(!teleport_point || !istype(teleport_point))
		if(proximity_flag)
			to_chat(user, span_notice("You set [target_turf] as your teleportation point."))
			teleport_point = target_turf
		return
	else
		user.visible_message(span_danger("[user] melts into the air and warps away!"), span_notice("We warp to our location, but doing so saps our strength..."))
		do_teleport(user, teleport_point, channel = TELEPORT_CHANNEL_BLUESPACE)
		if(isliving(user))
			var/mob/living/living_user = user
			living_user.Paralyze(450)
			living_user.heal_overall_damage(45, 45, 45, null, TRUE)

/obj/item/badmin_stone/lag/harm_act(atom/target, mob/user, proximity_flag)
	if(!isliving(target))
		to_chat(user, span_notice("You can only switch places with living targets!"))
		return
	var/turf/target_turf = get_turf(target)
	var/turf/user_turf = get_turf(user)
	user.visible_message(span_danger("[user] flickers out, and in their place, [target] appears!"))
	target.visible_message(span_danger("[target] flickers out, and in their place, [user] appears!"))
	do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_BLUESPACE)
	do_teleport(target, user_turf, channel = TELEPORT_CHANNEL_BLUESPACE)
	fire_projectile(/obj/projectile/magic/arcane_barrage, user_turf)
	user.changeNext_move(CLICK_CD_RANGE)

/obj/item/badmin_stone/lag/disarm_act(atom/target, mob/user, proximity_flag)
	fire_projectile(/obj/projectile/magic/lag_stone, target)
	user.changeNext_move(CLICK_CD_RANGE)

/////////////////////////////////////////////
/////////////////// SPELLS //////////////////
/////////////////////////////////////////////

/datum/action/cooldown/spell/infinity/doppelgangers
	name = "Lag Stone: Doppelgangers"
	desc = "Summon a bunch of (harmless) look-alikes of you!"
	button_icon_state = "doppelganger"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "lag"
	cooldown_time = 180 SECONDS
	var/doppelganger_amount = 4

/datum/action/cooldown/spell/infinity/doppelgangers/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	var/mob/living/living_caster = cast_on
	for(var/i = 1 to doppelganger_amount)
		var/mob/living/simple_animal/hostile/illusion/escape/doppelganger = new(cast_on.loc)
		doppelganger.setDir(cast_on.dir)
		doppelganger.Copy_Parent(living_caster, 30 SECONDS, 100)
		doppelganger.target = null
		random_step(doppelganger, 5, 100)

/datum/action/cooldown/spell/infinity/shuffle
	name = "Lag Stone: The Shuffle"
	desc = "Swap everyone in your view's position!"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "lag"
	cooldown_time = 75 SECONDS

/datum/action/cooldown/spell/infinity/shuffle/cast(atom/cast_on)
	. = ..()
	var/list/mobs = list()
	var/list/moblocs = list()
	for(var/mob/living/viewable_living in view(7, cast_on))
		moblocs += viewable_living.loc
		mobs += viewable_living
	shuffle_inplace(mobs)
	shuffle_inplace(moblocs)
	for(var/mob/living/living in mobs)
		if(!LAZYLEN(moblocs))
			break
		living.forceMove(moblocs[moblocs.len])
		moblocs.len -= 1

/datum/action/cooldown/spell/lag_stone_timestop
	name = "Lag Stone: Summon Lag"
	desc = "Summon a large bout of lag within a 5-tile radius. Very infuriating. Badmin Stone holders are immune, however."
	button_icon = 'monkestation/icons/obj/infinity.dmi'
	button_icon_state = "lagfield"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "lag"
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE
	cooldown_time = 75 SECONDS
	var/timestop_range = 2
	var/timestop_duration = 10 SECONDS

/datum/action/cooldown/spell/lag_stone_timestop/cast(atom/cast_on)
	. = ..()
	new /obj/effect/timestop/lag_stone(get_turf(cast_on), timestop_range, timestop_duration)

/obj/effect/timestop/lag_stone
	name = "lagfield"
	desc = "Oh no. OH NO."
	freezerange = 4
	duration = 175
	start_sound = 'monkestation/sound/effects/unnatural_clock_noises.ogg'

/obj/effect/timestop/lag_stone/Initialize(mapload, radius, time, list/immune_atoms, start)
	. = ..()
	var/matrix/ntransform = matrix(transform)
	ntransform.Scale(2)
	animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)

/////////////////////////////////////////////
/////////////////// ITEMS ///////////////////
/////////////////////////////////////////////

/obj/projectile/magic/lag_stone
	name = "lagbeam"
	icon_state = "omnilaser"
	stutter = 15
	jitter = 15
	eyeblur = 15
	stamina = 5

/obj/projectile/magic/lag_stone/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		if(blocked != 100)
			living_target.apply_status_effect(/datum/status_effect/dizziness)
