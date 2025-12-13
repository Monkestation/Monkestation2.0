//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

/obj/item/badmin_stone/syndie
	name = "Syndie Stone"
	desc = "Power, baby. Raw power."
	color = "#ff0130"
	force = 30
	stone_type = SYNDIE_STONE
	ability_text = list(
		"HELP INTENT: Emag any piece of machinery.",
		"DISARM INTENT: Let out an empulse with you as the epicenter. Only works every 75 seconds.",
		"HARM INTENT: Fire a laser. Only works every 2.5 seconds."
	)
	spell_types = list(
		/datum/action/cooldown/spell/infinity/regenerate,
		/datum/action/cooldown/spell/infinity/syndie_bullcharge,
		/datum/action/cooldown/spell/infinity/syndie_jump
	)
	gauntlet_spell_types = list(
		/datum/action/cooldown/spell/aoe/shockwave/syndie_stone
	)
	var/next_emp = 0
	var/next_laser = 0

/obj/item/badmin_stone/syndie/help_act(atom/target, mob/user, proximity_flag)
	if(ismachinery(target))
		var/obj/machinery/target_machinery = target
		target_machinery.emag_act(user)

/obj/item/badmin_stone/syndie/disarm_act(atom/target, mob/user, proximity_flag)
	if(next_emp > world.time)
		to_chat(span_danger("You need to wait [DisplayTimeText(next_emp - world.time)] to do that again!"))
		return
	empulse(user, 5, 3)
	next_emp = world.time + 60 SECONDS

/obj/item/badmin_stone/syndie/harm_act(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		if(next_laser > world.time)
			to_chat(span_danger("You need to wait [DisplayTimeText(next_laser - world.time)] to do that again!"))
			return
		fire_projectile(/obj/projectile/beam/laser, target)
		user.changeNext_move(CLICK_CD_RANGE)
		next_laser = world.time + 2.5 SECONDS

/obj/item/badmin_stone/syndie/give_abilities(mob/living/living_mob, gauntlet)
	. = ..()
	ADD_TRAIT(living_mob, TRAIT_THERMAL_VISION, SYNDIE_STONE_TRAIT)

/obj/item/badmin_stone/syndie/remove_abilities(mob/living/living_mob)
	. = ..()
	REMOVE_TRAIT(living_mob, TRAIT_THERMAL_VISION, SYNDIE_STONE_TRAIT)

/////////////////////////////////////////////
/////////////////// SPELLS //////////////////
/////////////////////////////////////////////

/datum/action/cooldown/spell/aoe/shockwave/syndie_stone
	name = "Syndie Stone: Shockwave"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "syndie"
	aoe_radius = 8

/datum/action/cooldown/spell/infinity/regenerate
	name = "Syndie Stone: Regenerate"
	desc = "Regenerate 4 health per second. Requires you to stand still."
	button_icon_state = "regenerate"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "syndie"

/datum/action/cooldown/spell/infinity/regenerate/cast(atom/cast_on)
	. = ..()
	if(isliving(cast_on))
		var/mob/living/living_caster = cast_on
		if(living_caster.on_fire)
			to_chat(living_caster, span_notice("The fire interferes with your regeneration!"))
			reset_spell_cooldown()
			return
		if(living_caster.stat == DEAD)
			to_chat(living_caster, span_notice("You can't regenerate out of death."))
			reset_spell_cooldown()
			return
		while(do_after(living_caster, 10, living_caster))
			living_caster.visible_message(span_notice("[living_caster]'s wounds heal!"))
			living_caster.heal_overall_damage(4, 4, 4, null, TRUE)
			living_caster.adjustToxLoss(-4, forced = TRUE)
			living_caster.adjustOxyLoss(-4)
			if(living_caster.getBruteLoss() + living_caster.getFireLoss() < 1)
				to_chat(living_caster, span_notice("You are fully healed."))
				return

/datum/action/cooldown/spell/infinity/syndie_bullcharge
	name = "Syndie Stone: Bull Charge"
	desc = "Imbue yourself with power, and charge forward, smashing through anyone or anything in your way!"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "syndie"
	sound = 'sound/magic/repulse.ogg'
	cooldown_time = 20 SECONDS
	var/charge_strong = TRUE
	var/charging = FALSE

/datum/action/cooldown/spell/infinity/syndie_bullcharge/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_BUMP, PROC_REF(charge))

/datum/action/cooldown/spell/infinity/syndie_bullcharge/Remove(mob/living/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_BUMP)

/datum/action/cooldown/spell/infinity/syndie_bullcharge/cast(atom/cast_on)
	. = ..()
	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_caster = cast_on
		ADD_TRAIT(carbon_caster, TRAIT_IGNORESLOWDOWN, YEET_TRAIT)
		if(charge_strong)
			ADD_TRAIT(carbon_caster, TRAIT_STUNIMMUNE, YEET_TRAIT)
		charging = TRUE
		carbon_caster.move_force = INFINITY
		carbon_caster.visible_message(span_danger("[carbon_caster] charges!"))
		addtimer(CALLBACK(src, PROC_REF(done), carbon_caster), 50)

/datum/action/cooldown/spell/infinity/syndie_bullcharge/proc/done(mob/living/carbon/user)
	user.move_force = initial(user.move_force)
	REMOVE_TRAIT(user, TRAIT_IGNORESLOWDOWN, YEET_TRAIT)
	if(charge_strong)
		REMOVE_TRAIT(user, TRAIT_STUNIMMUNE, YEET_TRAIT)
	user.visible_message(span_danger("[user] relaxes..."))

/datum/action/cooldown/spell/infinity/syndie_bullcharge/proc/charge(atom/movable/source, atom/target)
	SIGNAL_HANDLER
	if(charging)
		if(!iscarbon(owner))
			return
		var/mob/living/carbon/carbon_owner = owner
		if(!isliving(target))
			return
		var/mob/living/living_target = target
		carbon_owner.visible_message(span_danger("[carbon_owner] rams into [living_target]!"))
		if(charge_strong)
			living_target.Paralyze(7.5 SECONDS)
			living_target.adjustBruteLoss(20)
			carbon_owner.heal_overall_damage(12.5, 12.5, 12.5)
		else
			living_target.Paralyze(5 SECONDS)
			living_target.adjustBruteLoss(12)
			carbon_owner.heal_overall_damage(7.5, 7.5, 7.5)

/datum/action/cooldown/spell/infinity/syndie_jump
	name = "Syndie Stone: Super Jump"
	desc = "Leap across the station to wherever you'd like!"
	button_icon_state = "jump"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "syndie"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/infinity/syndie_jump/cast(atom/cast_on)
	. = ..()
	if(istype(get_area(cast_on), /area/centcom/wizard_station) || istype(get_area(cast_on), /area/centcom/thanos_farm))
		to_chat(cast_on, span_warning("You can't jump here!"))
		return
	if(isliving(cast_on))
		INVOKE_ASYNC(src, PROC_REF(do_jaunt), cast_on)

/datum/action/cooldown/spell/infinity/syndie_jump/proc/do_jaunt(mob/living/target)
	ADD_TRAIT(target, TRAIT_NO_TRANSFORM, type)
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/phased_mob/spell_jaunt/infinity/holder = new(mobloc)

	var/mob/living/passenger
	if(isliving(target.pulling) && target.grab_state >= GRAB_AGGRESSIVE)
		passenger = target.pulling
		holder.passenger = passenger
		ADD_TRAIT(passenger, TRAIT_NO_TRANSFORM, type)

	target.visible_message(span_bolddanger("[target] LEAPS[passenger ? ", bringing [passenger] up with them" : ""]!"))
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		ADD_TRAIT(carbon_target, TRAIT_BOMBIMMUNE, type)
	if(passenger)
		animate(passenger, pixel_y = 128, alpha = 0, time = 4.5, easing = LINEAR_EASING)
	animate(target, pixel_y = 128, alpha = 0, time = 4.5, easing = LINEAR_EASING)
	sleep(4.5)

	if(passenger)
		passenger.forceMove(holder)
		passenger.reset_perspective(holder)
		REMOVE_TRAIT(passenger, TRAIT_NO_TRANSFORM, type)
	target.forceMove(holder)
	target.reset_perspective(holder)
	REMOVE_TRAIT(target, TRAIT_NO_TRANSFORM, type)

	sleep(7.5 SECONDS)
	if(target.loc != holder && (passenger && passenger.loc != holder))
		qdel(holder)
		return
	mobloc = get_turf(target.loc)
	target.mobility_flags &= ~MOBILITY_MOVE
	if(passenger)
		passenger.mobility_flags &= ~MOBILITY_MOVE
	holder.reappearing = TRUE

	if(passenger)
		passenger.forceMove(mobloc)
		passenger.Paralyze(75)
	target.visible_message(span_bolddanger("[target] slams down from above[passenger ? ", slamming [passenger] down to the floor" : ""]!"))
	playsound(target, 'sound/effects/bang.ogg', 50, 1)
	explosion(mobloc, 0, 0, 2, 3)
	target.forceMove(mobloc)
	target.setDir(holder.dir)
	animate(target, pixel_y = 0, alpha = 255, time = 4.5, easing = LINEAR_EASING)
	if(passenger)
		passenger.setDir(holder.dir)
		animate(passenger, pixel_y = 0, alpha = 255, time = 4.5, easing = LINEAR_EASING)
	sleep(4.5)
	target.opacity = initial(target.opacity)
	target.mouse_opacity = initial(target.mouse_opacity)
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		REMOVE_TRAIT(carbon_target, TRAIT_BOMBIMMUNE, type)
	for(var/mob/living/living in mobloc)
		if(living.stat >= HARD_CRIT)
			living.visible_message(span_bolddanger("[living] is pancaked by [target]'s slam!"))
			new /obj/item/food/pancakes(mobloc)
			living.gib()
	qdel(holder)
	if(!QDELETED(target))
		if(mobloc.density)
			for(var/direction in GLOB.alldirs)
				var/turf/turf = get_step(mobloc, direction)
				if(turf)
					if(target.Move(turf))
						break
		target.mobility_flags |= MOBILITY_MOVE
	if(!QDELETED(passenger))
		passenger.mobility_flags |= MOBILITY_MOVE
