/mob/living/simple_animal/hostile/hex
	name = "\improper Hex"
	desc = "A lesser construct, crafted by an Artificer."
	stop_automated_movement_when_pulled = 1
	movement_type = FLYING
	icon = 'monkestation/code/modules/bloody_cult/icons/mob.dmi'
	icon_state = "hex"
	icon_living = "hex"
	icon_dead = "hex"
	speak_chance = 0
	turns_per_move = 8
	speed = 0.2
	maxHealth = 50
	health = 50
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	projectilesound = 'monkestation/code/modules/bloody_cult/sound/forge.ogg'
	projectiletype = /obj/projectile/bloodslash
	move_to_delay = 1
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 15
	//attack_sound = 'sound/weapons/rapidslice.ogg'
	speed = 5
	faction = list("cult")
	var/mob/living/basic/construct/artificer/perfect/master = null
	var/no_master = TRUE
	var/glow_color = "#FFFFFF"

	var/image/master_glow = null
	var/image/harm_glow = null

	var/mode = HEX_MODE_ROAMING
	var/passive = FALSE
	var/turf/guard_spot = null

	//Used to determine behavior
	var/stance = HOSTILE_STANCE_IDLE
	/*
	HEX_MODE_ROAMING 	: Usual mob roaming behaviour.
	HEX_MODE_GUARD 		: Stands in place. If it spots an enemy, will chase it, then attempt to return to the spot where they were placed.
	HEX_MODE_ESCORT		: Follows the Artificer that summoned them around if they're close enough, otherwise stays idle. Shoots at enemies but doesn't chase them.
	*/

/mob/living/simple_animal/hostile/hex/New()
	..()
	setupglow(glow_color)
	update_harmglow()
	animate(src, pixel_y = 4 * 1 , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 2 * 1, time = 10, loop = -1, easing = SINE_EASING)

/mob/living/simple_animal/hostile/hex/Initialize(mapload)
	. = ..()
	toggle_ai(AI_ON)

/mob/living/simple_animal/hostile/hex/FindTarget(list/possible_targets)
	if(stance != HOSTILE_STANCE_ATTACK && stance != HOSTILE_STANCE_ATTACKING)
		return
	. = ..()

/mob/living/simple_animal/hostile/hex/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	..()
	update_icons()

/mob/living/simple_animal/hostile/hex/update_icons()
	. = ..()
	overlays = 0

	var/damage = maxHealth - health
	var/icon/damageicon
	if (damage > (2*maxHealth/3))
		damageicon = icon(icon, "wraith2_damage_high")//fits well enough
	else if (damage > (maxHealth/3))
		damageicon = icon(icon, "wraith2_damage_low")
	if (damageicon)
		damageicon.Blend(glow_color, ICON_ADD)
		var/image/damage_overlay = image(icon = damageicon)
		damage_overlay.plane = ABOVE_LIGHTING_PLANE
		overlays += damage_overlay

	setupglow(glow_color)
	update_harmglow()

/mob/living/simple_animal/hostile/hex/proc/setupglow(var/_glowcolor = "#FFFFFF")
	glow_color = _glowcolor
	overlays -= master_glow
	var/icon/glowicon = icon(icon, "glow-[icon_state]")
	glowicon.Blend(_glowcolor, ICON_ADD)
	master_glow = image(icon = glowicon)
	master_glow.plane = ABOVE_LIGHTING_PLANE
	overlays += master_glow

/mob/living/simple_animal/hostile/hex/proc/update_harmglow()
	overlays -= harm_glow
	harm_glow = image(icon, src, "[passive ? "glow-hex-passive" : "glow-hex-harm"]")
	harm_glow.plane = ABOVE_LIGHTING_PLANE+1
	overlays += harm_glow

/mob/living/simple_animal/hostile/hex/Destroy()
	if (master)
		master.minions.Remove(src)
		if (IS_CULTIST(master))
			master.DisplayUI("Cultist Right Panel")
	master = null
	..()

/mob/living/simple_animal/hostile/hex/Life()
	if (mode != HEX_MODE_ROAMING)
		stop_automated_movement = 1
	. = ..()
	handle_automated_action()
	if (!no_master)
		if (!master || QDELETED(master) || master.stat == DEAD)
			adjustBruteLoss(20)//we shortly die out after our master's demise
			mode = HEX_MODE_ROAMING
	switch(mode)
		if (HEX_MODE_GUARD)
			if (stance == HOSTILE_STANCE_IDLE)
				if (!guard_spot)
					guard_spot = get_turf(src)
				else
					var/turf/T = get_turf(src)
					if (T != guard_spot)
						if ((T.z == guard_spot.z) && (get_dist(T, guard_spot) < 50))
							Goto(guard_spot, move_to_delay, 0)
						else
							guard_spot = get_turf(src)
					else
						dir = turn(dir, -90)
		if (HEX_MODE_ESCORT)
			escort_routine()
		else
			guard_spot = null

/mob/living/simple_animal/hostile/hex/proc/escort_routine()
	guard_spot = null
	var/escorts = 0
	var/spot = 0
	for (var/mob/living/simple_animal/hostile/hex/H in master.minions)
		if (H.mode == HEX_MODE_ESCORT)
			escorts++
		if (H == src)
			spot = escorts
	if (escorts == 1)
		Goto(master.satellites[1], move_to_delay, 0)//trailing behind
		if (!target && (loc == get_turf(master.satellites[1])))
			dir = master.dir
	else
		Goto(master.satellites[spot+1], move_to_delay, 0)//trailing on each sides
		if (!target && (loc == get_turf(master.satellites[spot+1])))
			dir = master.dir

/mob/living/simple_animal/hostile/hex/Cross(var/atom/movable/mover, var/turf/target, var/height = 1.5, var/air_group = 0)
	if(istype(mover, /obj/projectile/bloodslash))//stop hitting yourself ffs!
		return 1
	if ((mode == HEX_MODE_ESCORT) && (istype(mover, /mob/living/simple_animal/hostile/hex) || (mover == master)))//Escort mode is janky otherwise
		return 1

	return ..()

/mob/living/simple_animal/hostile/hex/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, var/glide_size_override = 0)
	. = ..()
	if (target)
		dir = get_dir(src, target)

/mob/living/simple_animal/hostile/hex/forceMove(atom/destination, step_x = 0, step_y = 0, no_tp = FALSE, harderforce = FALSE, glide_size_override = 0)
	. = ..()
	if (target)
		dir = get_dir(src, target)

/mob/living/simple_animal/hostile/hex/death(var/gibbed = FALSE)
	..(TRUE) //If they qdel, they gib regardless
	visible_message(span_warning("\The [src] collapses in a shattered heap. ") )
	qdel (src)

/mob/living/simple_animal/hostile/hex/PickTarget(list/Targets)
	if (passive)
		Targets = list()

	for(var/mob/the_target as anything in Targets)
		if(ismob(the_target))
			var/mob/M = the_target
			if(IS_CULTIST(M))
				Targets -= M
			if (iscarbon(M))
				var/mob/living/carbon/C = M
				if (istype(C.handcuffed, /obj/item/restraints/handcuffs/cult)) //hex don't attack prisoners
					Targets -= M
			if (locate(/obj/effect/stun_indicator) in M)//or people that got stun paper'd
				Targets -= M
			if (locate(/obj/effect/cult_ritual/conversion) in M.loc)//or people that stand on top of an active conversion rune
				Targets -= M
	. = ..()

/mob/living/simple_animal/hostile/hex/MoveToTarget()
	if (mode == HEX_MODE_ESCORT)
		stop_automated_movement = 1
		if(!target || !CanAttack(target))
			LoseTarget()
			return
		if(isturf(loc))
			if(target in ListTargets())
				dir = get_dir(src, target)
				if(get_dist(src, target) >= 2 && ranged_cooldown <= 0)
					OpenFire(target)
				if(target.Adjacent(src))
					AttackingTarget()
				return
		stance = HOSTILE_STANCE_IDLE
		walk(src, 0)
		LoseAggro()
	else
		..()

/mob/living/simple_animal/hostile/hex/narsie_act()
	return

/mob/living/simple_animal/hostile/hex/CanAttack(mob/living/the_target)
	if(istype(the_target))
		if(IS_CULTIST(the_target) || isconstruct(the_target) || istype(the_target, /mob/living/simple_animal/hostile/hex))
			return
		if("cult" in the_target.faction)
			return
	. = ..()
