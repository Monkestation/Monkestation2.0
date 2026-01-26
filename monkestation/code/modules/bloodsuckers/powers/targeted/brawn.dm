/datum/action/cooldown/bloodsucker/targeted/brawn
	name = "Brawn"
	desc = "Deal terrible damage with your bare hands, or knock those grabbing you to the floor. Higher levels allow you to snap restraints or break closets."
	button_icon_state = "power_strength"
	power_explanation = "Brawn:\n\
		Click any person to bash into them or knock a grabber down. Only one of these can be done per use.\n\
		Punching a Cyborg will heavily EMP them in addition to deal damage.\n\
		Higher levels will increase the damage and knockdown when punching someone.\n\
		At level 2, you gain the ability to snap handcuffs and straightjackets, which will also knock anyone grabbing you down at the same time.\n\
		You can break normal handcuffs and straightjackets, but not silver handcuffs or bolas.\n\
		At level 3, you get the ability to break closets open, either from inside or outside.\n\
		At level 5, you get the ability to break even silver handcuffs. Use wisely - security is unlikely to try and capture you alive again after the first time!"
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 8
	cooldown_time = 9 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "Select a target."

/datum/action/cooldown/bloodsucker/targeted/brawn/upgrade_power()
	. = ..()

	if (level_current >= 5)
		check_flags |= BP_ALLOW_WHILE_SILVER_CUFFED

/datum/action/cooldown/bloodsucker/targeted/brawn/can_use(mob/living/carbon/user, trigger_flags)
	if (user.handcuffed && !check_level(2, "break restraints"))
		return FALSE
	return ..()

/datum/action/cooldown/bloodsucker/targeted/brawn/ActivatePower(trigger_flags)
	// Did we break out of our handcuffs/locker and/or knock a grabber down?
	var/broke_restraints = break_restraints()
	var/escaped_puller = escape_puller()
	if(broke_restraints || escaped_puller)
		power_activated_sucessfully()
		return FALSE
	// Did neither, now we can PUNCH.
	return ..()

// Look at 'biodegrade.dm' for reference
/datum/action/cooldown/bloodsucker/targeted/brawn/proc/break_restraints()
	var/mob/living/carbon/human/user = owner
	var/used = FALSE

	// Remove Handcuffs
	var/obj/cuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	if(istype(cuffs) && level_current >= 2)
		user.visible_message(
			span_warning("[user] discards [user.p_their()] restraints like it's nothing!"),
			span_warning("We break through our restraints!"),
		)
		user.clear_cuffs(cuffs, TRUE)
		used = TRUE

	// Remove Straightjackets
	if(user.wear_suit?.breakouttime && level_current >=2)
		var/obj/item/clothing/suit/straightjacket = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		user.visible_message(
			span_warning("[user] rips straight through [user.p_their()] [straightjacket]!"),
			span_warning("We tear through our [straightjacket]!"),
		)
		user.temporarilyRemoveItemFromInventory(straightjacket, force = TRUE)
		if(straightjacket && user.wear_suit == straightjacket)
			qdel(straightjacket)
		used = TRUE

	// Breaks out of lockers
	if(istype(user.loc, /obj/structure/closet) && check_level(3, "bash open closets"))
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE
		closet.visible_message(
			span_warning("[closet] tears apart as [user] bashes it open from within!"),
			span_warning("[closet] tears apart as you bash it open from within!"),
		)
		to_chat(user, span_warning("We bash [closet] wide open!"))
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, closet), 1)
		used = TRUE

	// Did we end up using our ability? If so, play the sound effect and return TRUE
	if(used)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, 1, -1)
	return used

// This is its own proc because its done twice, to repeat code copypaste.
/datum/action/cooldown/bloodsucker/targeted/brawn/proc/break_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	closet?.bust_open()

/datum/action/cooldown/bloodsucker/targeted/brawn/proc/escape_puller()
	if(!owner.pulledby) // || owner.pulledby.grab_state <= GRAB_PASSIVE)
		return FALSE
	var/mob/pulled_mob = owner.pulledby
	var/pull_power = pulled_mob.grab_state
	playsound(get_turf(pulled_mob), 'sound/effects/woodhit.ogg', 75, 1, -1)
	// Knock Down (if Living)
	if(isliving(pulled_mob))
		var/mob/living/hit_target = pulled_mob
		hit_target.Knockdown(pull_power * 10 + 10)
	// Knock Back (before Knockdown, which probably cancels pull)
	var/send_dir = get_dir(owner, pulled_mob)
	var/turf/turf_thrown_at = get_ranged_target_turf(pulled_mob, send_dir, pull_power + 1)
	owner.newtonian_move(send_dir) // Bounce back in 0 G
	pulled_mob.throw_at(turf_thrown_at, pull_power + 1, TRUE, owner, FALSE) // Throw distance based on grab state! Harder grabs punished more aggressively.
	// /proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	log_combat(owner, pulled_mob, "used Brawn power")
	owner.visible_message(
		span_warning("[owner] tears free of [pulled_mob]'s grasp!"),
		span_warning("You shrug off [pulled_mob]'s grasp!"),
	)
	owner.pulledby = null // It's already done, but JUST IN CASE.
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/brawn/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	// Target Type: Mob
	if(isliving(target_atom))
		var/mob/living/target = target_atom
		var/mob/living/carbon/carbonuser = user
		//You know what I'm just going to take the average of the user's limbs max damage instead of dealing with 2 hands
		var/obj/item/bodypart/user_active_arm = carbonuser.get_active_hand()
		var/hitStrength = user_active_arm.unarmed_damage_high * 1.25 + 2
		// Knockdown!
		var/powerlevel = min(5, 1 + level_current)
		if(rand(5 + powerlevel) >= 5)
			target.visible_message(
				span_danger("[user] lands a vicious punch, sending [target] away!"), \
				span_userdanger("[user] has landed a horrifying punch on you, sending you flying!"),
			)
			target.Knockdown(min(5, rand(10, 10 * powerlevel)))
		// Attack!
		owner.balloon_alert(owner, "you punch [target]!")
		playsound(get_turf(target), 'sound/weapons/punch4.ogg', 60, 1, -1)
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(target.zone_selected))
		target.apply_damage(hitStrength, BRUTE, affecting)
		// Knockback
		var/send_dir = get_dir(owner, target)
		var/turf/turf_thrown_at = get_ranged_target_turf(target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		target.throw_at(turf_thrown_at, powerlevel, TRUE, owner) //new /datum/forced_movement(target, get_ranged_target_turf(target, send_dir, (hitStrength / 4)), 1, FALSE)
		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(target))
			target.emp_act(EMP_HEAVY)
	// Target Type: Locker
	else if(istype(target_atom, /obj/structure/closet))
		if(!check_level(3, "bash open closets"))
			return
		var/obj/structure/closet/target_closet = target_atom
		user.balloon_alert(user, "you prepare to bash [target_closet] open...")
		if(!do_after(user, 2.5 SECONDS, target_closet, hidden = TRUE))
			user.balloon_alert(user, "interrupted!")
			return FALSE
		target_closet.visible_message(span_danger("[target_closet] breaks open as [user] bashes it!"))
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, target_closet), 1)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, TRUE, -1)

/datum/action/cooldown/bloodsucker/targeted/brawn/proc/check_level(needed_level, action)
	if(needed_level > level_current)
		owner.balloon_alert(owner, "[needed_level - level_current] more level\s needed to [action]")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/brawn/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom) || istype(target_atom, /obj/machinery/door) || istype(target_atom, /obj/structure/closet)

/datum/action/cooldown/bloodsucker/targeted/brawn/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	if(!.) // Disable range notice for Brawn.
		return FALSE
	// Must outside Closet to target anyone!
	if(!isturf(owner.loc))
		return FALSE
	// Target Type: Living
	if(isliving(target_atom))
		if(HAS_TRAIT(owner, TRAIT_PACIFISM))
			to_chat(owner, span_warning("You don't want to harm other living beings!"))
			return FALSE
		return TRUE
	// Target Type: Door
	else if(istype(target_atom, /obj/machinery/door))
		return TRUE
	// Target Type: Locker
	else if(istype(target_atom, /obj/structure/closet))
		return TRUE
	return FALSE
