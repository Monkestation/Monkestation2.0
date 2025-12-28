//////////////////////////////////////////////////////////////////////////
//-------------------------Warlock basic staff--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/dark_staff
	name = "Channeling Staff"
	desc = "Pull darkness from the void, knitting it into a staff."
	panel = "Darkspawn"
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "shadow_staff"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	/// Staff object stored for the ability
	var/obj/item/gun/magic/darkspawn/staff
	/// Flags used for different effects that apply when a projectile hits something
	var/effect_flags

/datum/action/cooldown/spell/toggle/dark_staff/link_to(Target)
	. = ..()
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_DARKSPAWN_UPGRADE_ABILITY, PROC_REF(handle_upgrade))
		RegisterSignal(target, COMSIG_DARKSPAWN_DOWNGRADE_ABILITY, PROC_REF(handle_downgrade))

/datum/action/cooldown/spell/toggle/dark_staff/proc/handle_upgrade(atom/source, flag)
	effect_flags |= flag
	if(staff)
		staff.effect_flags = effect_flags
		if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
			staff.LoadComponent(/datum/component/light_eater)

/datum/action/cooldown/spell/toggle/dark_staff/proc/handle_downgrade(atom/source, flag)
	effect_flags -= flag
	if(staff)
		staff.effect_flags = effect_flags
		if(flag & STAFF_UPGRADE_LIGHTEATER)
			qdel(staff.GetComponent(/datum/component/light_eater))

/datum/action/cooldown/spell/toggle/dark_staff/process()
	active = !!owner?.is_holding_item_of_type(/obj/item/gun/magic/darkspawn)
	return ..()

/datum/action/cooldown/spell/toggle/dark_staff/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/dark_staff/Enable()
	owner.balloon_alert(owner, "shhouna")
	owner.visible_message(span_warning("[owner] knits shadows together into a staff!"), span_velvet("You summon your staff. Examine it to see what it does."))
	playsound(owner, 'sound/magic/darkspawn/pass_create.ogg', 50, 1)
	if(!staff)
		staff = new (owner)
	if(effect_flags & STAFF_UPGRADE_LIGHTEATER)
		staff.LoadComponent(/datum/component/light_eater)
	staff.effect_flags = effect_flags
	owner.put_in_hands(staff)

/datum/action/cooldown/spell/toggle/dark_staff/Disable()
	owner.balloon_alert(owner, "haoo")
	owner.visible_message(span_warning("[owner]'s staff dissipates!"), span_velvet("You dispel the staff."))
	playsound(owner, 'sound/magic/darkspawn/pass_dispel.ogg', 50, 1)
	staff.moveToNullspace()

//////////////////////////////////////////////////////////////////////////
//---------------------Warlock light eater ability----------------------// little bit of anti-fire too
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/extinguish
	name = "Extinguish"
	desc = "Extinguish all light around you."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "extinguish"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 60)
	cooldown_time = 30 SECONDS
	sound = 'sound/ambience/antag/darkspawn/veil_mind_gasp.ogg'
	aoe_radius = 6
	///Secret item stored in the ability to hit things with to trigger light eater
	var/obj/item/darkspawn_extinguish/bopper
	///List of objects seen at cast
	var/list/seen_things

/datum/action/cooldown/spell/aoe/extinguish/Grant(mob/grant_to)
	. = ..()
	bopper = new(src)

/datum/action/cooldown/spell/aoe/extinguish/Remove(mob/living/remove_from)
	QDEL_NULL(bopper)
	return ..()

/datum/action/cooldown/spell/aoe/extinguish/cast(atom/cast_on)
	seen_things = view(owner) //cash all things you can see
	. = ..()
	owner.balloon_alert(owner, "shwooh")
	to_chat(owner, span_velvet("You extinguish all lights."))

/datum/action/cooldown/spell/aoe/extinguish/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(isopenturf(victim)) // extinguish the air
		var/turf/open/victim_turf = victim
		if(victim_turf.blocks_air)
			return
		for(var/obj/effect/hotspot/hotspot in victim_turf)
			qdel(hotspot)
		var/datum/gas_mixture/turf_air = victim_turf.air
		if(turf_air)
			// set temperature to "normal" if its hot
			if(turf_air.temperature > T20C)
				turf_air.temperature = T20C
			// remove flammable gases in general
			for(var/gas_type in list(/datum/gas/plasma, /datum/gas/tritium, /datum/gas/hydrogen, /datum/gas/freon))
				turf_air.assert_gas(gas_type)
				turf_air.gases[gas_type][MOLES] = 0
			turf_air.garbage_collect()
			victim_turf.air_update_turf(FALSE, FALSE)
		return
	if(!seen_things || !(victim in seen_things))//no putting out on the other side of walls
		return
	if(ishuman(victim))//put out any
		var/mob/living/carbon/human/target = victim
		if(target.can_block_magic(antimagic_flags, charge_cost = 1))
			return
		target.extinguish_mob()
		if(target.bodytemperature > target.standard_body_temperature)
			target.bodytemperature = target.standard_body_temperature
	else if(istype(victim, /obj/structure/glowshroom))
		var/obj/structure/glowshroom/glowshroom = victim
		var/datum/plant_gene/trait/glow/glow_trait = locate() in glowshroom.myseed?.genes
		if(glow_trait && !istype(glow_trait, /datum/plant_gene/trait/glow/shadow))
			glowshroom.myseed.genes -= glow_trait
			qdel(glow_trait)
			glowshroom.set_light(0)
	else if(isobj(victim))//put out any items too
		var/obj/target = victim
		target.extinguish()
	// extinguish owner as well
	if(isliving(owner))
		var/mob/living/living_owner = owner
		living_owner.extinguish_mob()
		if(living_owner.bodytemperature > living_owner.standard_body_temperature)
			living_owner.bodytemperature = living_owner.standard_body_temperature
	SEND_SIGNAL(bopper, COMSIG_LIGHT_EATER_EAT, victim, bopper, TRUE)

/obj/item/darkspawn_extinguish
	name = "extinguish"
	desc = "you shouldn't be seeing this, it's just used for the spell and nothing else"

/obj/item/darkspawn_extinguish/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)

//////////////////////////////////////////////////////////////////////////
//---------------------Mess up an APC pretty badly----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/null_charge
	name = "Null Charge"
	desc = "Meddle with the powergrid via a functioning APC, causing a temporary stationwide power outage. Breaks the APC in the process."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "null_charge"

	antimagic_flags = NONE
	panel = "Darkspawn"
	check_flags =  AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	cooldown_time = 10 MINUTES
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 200)
	hand_path = /obj/item/melee/touch_attack/darkspawn

/datum/action/cooldown/spell/touch/null_charge/is_valid_target(atom/cast_on)
	if(!istype(cast_on, /obj/machinery/power/apc))
		return FALSE
	var/obj/machinery/power/apc/target = cast_on
	if(target.machine_stat & BROKEN)
		to_chat(owner, span_danger("This [target] no longer functions enough for access to the power grid."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/null_charge/cast_on_hand_hit(obj/item/melee/touch_attack/hand, obj/machinery/power/apc/target, mob/living/carbon/human/caster)
	if(!target || !istype(target))//sanity check
		return FALSE

	//Turn it off for the time being
	owner.balloon_alert(owner, "xlahwa")
	target.set_light(0)
	target.visible_message(span_warning("The [target] flickers and begins to grow dark."))

	to_chat(caster, span_velvet("You dim the APC's screen and carefully begin siphoning its power into the void."))
	if(!do_after(caster, 5 SECONDS, target, hidden = TRUE))
		//Whoops!  The APC's light turns back on
		to_chat(caster, span_velvet("Your concentration breaks and the APC suddenly repowers!"))
		target.set_light(2)
		target.visible_message(span_warning("The [target] begins glowing brightly!"))
		return FALSE

	if(target.machine_stat & BROKEN)
		to_chat(owner, span_danger("This [target] no longer functions enough for access to the power grid."))
		return FALSE

	//We did it
	var/datum/antagonist/darkspawn/darkspawn = IS_DARKSPAWN(owner)
	if(darkspawn)
		darkspawn.block_psi(60 SECONDS, type)
	owner.balloon_alert(owner, "...SHWOOH!")
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", ANNOUNCER_POWEROFF)
	power_fail(30, 40)
	to_chat(caster, span_velvet("You return the APC's power to the void, destroying it and disabling all others."))
	target.set_broken()
	return TRUE

//////////////////////////////////////////////////////////////////////////
//-----------------------Drain enemy, heal ally-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/extract
	name = "Extract"
	desc = "Drain a target's life force or bestow it to an ally."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "extract"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 7
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 2)
	///The mob being targeted by the ability
	var/mob/living/channeled
	///The beam visual drawn by the ability
	var/datum/beam/visual
	///How much damage or healing happens every process tick
	var/damage_amount = 2
	///The cooldown duration, only applied when the ability ends
	var/actual_cooldown = 15 SECONDS
	///Boolean, whether or not the spell is healing the target
	var/healing = FALSE
	///counts up each process tick, when reaching 5 prints a balloon alert and resets
	var/balloon_counter = 0

/datum/action/cooldown/spell/pointed/extract/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/spell/pointed/extract/Grant(mob/grant_to)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/pointed/extract/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.can_block_magic(antimagic_flags, charge_cost = 1))
		return FALSE
	if(living_cast_on.stat == DEAD)
		to_chat(owner, span_warning("[cast_on] is dead!"))
		return FALSE
	if(cast_on == owner)
		to_chat(owner, span_warning("can't cast it on yourself!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/extract/process()
	if(channeled)
		balloon_counter++
		if(!owner.mind)
			cancel()
			return
		if(!visual || QDELETED(visual))
			cancel()
			return
		if(!healing && channeled.stat == DEAD)
			cancel()
			return
		if(healing && channeled.health >= channeled.maxHealth)
			cancel()
			return
		if(get_dist(owner, channeled) > cast_range)
			cancel()
			return
		if(!SEND_SIGNAL(owner.mind, COMSIG_MIND_CHECK_ANTAG_RESOURCE, ANTAG_RESOURCE_DARKSPAWN, resource_costs[ANTAG_RESOURCE_DARKSPAWN]))
			cancel()
			return
		SEND_SIGNAL(owner.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, resource_costs)
		if(balloon_counter >= 5)
			balloon_counter = 0
			owner.balloon_alert(owner, "...thum...")
		if(healing)
			channeled.heal_ordered_damage(damage_amount, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
		else
			channeled.apply_damage(damage_amount, BURN)
			if(isliving(owner))
				var/mob/living/healed = owner
				healed.heal_ordered_damage(damage_amount, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE))
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/cooldown/spell/pointed/extract/Trigger(trigger_flags, atom/target)
	if(cancel())
		return FALSE
	. = ..()

/obj/effect/ebeam/darkspawn
	name = "void beam"

/datum/action/cooldown/spell/pointed/extract/cast(mob/living/cast_on)
	. = ..()
	owner.balloon_alert(owner, "qokxlez")
	visual = owner.Beam(cast_on, "slingbeam", 'icons/mob/simple/darkspawn.dmi' , INFINITY, cast_range)
	channeled = cast_on
	healing = IS_TEAM_DARKSPAWN(channeled)

/datum/action/cooldown/spell/pointed/extract/proc/cancel()
	balloon_counter = 0
	if(visual)
		qdel(visual)
	if(channeled)
		channeled = null
		StartCooldown(actual_cooldown)
		owner.balloon_alert(owner, "...qokshe")
		return TRUE
	return FALSE

//////////////////////////////////////////////////////////////////////////
//------------------Literally just goliath tendrils---------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_build/abyssal_call
	name = "Abyssal Call"
	desc = "Summon abyssal tendrils from beyond the veil to grasp an enemy."
	button_icon_state = "abyssal_call"
	cast_range = 10
	cast_time = 0
	object_type = /obj/effect/goliath_tentacle/darkspawn/original
	cooldown_time = 10 SECONDS
	can_density = TRUE
	language_final = "Xylt'he kkxla'thamara"

//////////////////////////////////////////////////////////////////////////
//--------------Gives everyone nearby Blindness------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/mass_blindness
	name = "Mass Blindness"
	desc = "Forces brief blindness on all nearby enemies."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "mass_hallucination"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 30)
	cooldown_time = 30 SECONDS
	sound = 'sound/ambience/antag/darkspawn/veil_mind_scream.ogg'
	var/amount = 10 SECONDS

/datum/action/cooldown/spell/aoe/mass_blindness/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "h'ellekth'ele")

/datum/action/cooldown/spell/aoe/mass_blindness/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim))
		return
	var/mob/living/target = victim
	if(IS_TEAM_DARKSPAWN(target)) //don't fuck with allies
		return
	if(target.can_block_magic(antimagic_flags, charge_cost = 1))
		return
	blind(target)

/datum/action/cooldown/spell/aoe/mass_blindness/proc/blind(mob/living/target)
	target.adjust_temp_blindness(amount)
	target.adjust_hallucinations(amount * 3)

//////////////////////////////////////////////////////////////////////////
//---------------------Detain and capture ability-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/seize //Stuns and mutes a human target for 10 seconds
	name = "Seize"
	desc = "Restrain a target's mental faculties, preventing speech and actions of any kind for a moderate duration."
	panel = "Darkspawn"
	button_icon_state = "seize"
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 35)
	cooldown_time = 30 SECONDS
	cast_range = 10
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	///duration of stun when used at close range
	var/stun_duration = 10 SECONDS

/datum/action/cooldown/spell/pointed/seize/before_cast(atom/cast_on)
	. = ..()
	if(!cast_on || !isliving(cast_on))
		return . | SPELL_CANCEL_CAST
	var/mob/living/carbon/target = cast_on
	if(istype(target) && target.stat)
		to_chat(owner, span_warning("[target] must be conscious!"))
		return . | SPELL_CANCEL_CAST
	if(IS_TEAM_DARKSPAWN(target))
		to_chat(owner, span_warning("You cannot seize allies!"))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/seize/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return

	if(iscarbon(owner))
		var/mob/living/carbon/user = owner
		if(!(user.check_obscured_slots() & ITEM_SLOT_EYES)) //only show if the eyes are visible
			user.visible_message(span_warning("<b>[user]'s eyes flash a deep purple</b>"))

	owner.balloon_alert(owner, "sskr'aya")

	var/mob/living/target = cast_on
	if(target.can_block_magic(antimagic_flags, charge_cost = 1))
		return

	var/distance = get_dist(target, owner)
	if (distance <= 2)
		target.visible_message(span_danger("[target] suddenly collapses..."))
		to_chat(target, span_userdanger("A purple light flashes through your mind, and you lose control of your movements!"))
		target.Paralyze(stun_duration)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.adjust_silence(10 SECONDS)
	else //Distant glare
		var/loss = max(60 - (distance * 10), 0)
		target.stamina.adjust(-loss)
		target.adjust_stutter(loss)
		to_chat(target, span_userdanger("A purple light flashes through your mind, and exhaustion floods your body..."))

//////////////////////////////////////////////////////////////////////////
//----------------------Basically a fancy jaunt-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/quantum_disruption
	name = "Quantum disruption"
	desc = "Disrupt the flow of possibilities, where you are, where you could be."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "quantum_disruption"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 80)
	cooldown_time = 60 SECONDS
	/// For how long are we jaunting?
	jaunt_duration = 8 SECONDS
	/// For how long we become immobilized after exiting the jaunt
	jaunt_in_time = 0 SECONDS
	/// For how long we become immobilized when using this spell
	jaunt_out_time = 0.33 SECONDS
	//min distance for a decoy to keep away from the hidden jaunter
	var/decoy_min_distance = 5
	//effects for going in and out of jaunt
	jaunt_in_type = /obj/effect/temp_visual/quantum_disruption
	jaunt_out_type = /obj/effect/temp_visual/quantum_disruption/out
	/// Sound played when entering the jaunt
	sound = 'sound/magic/darkspawn/kingcrimson_start.ogg'
	/// Sound played when exiting the jaunt
	exit_jaunt_sound = 'sound/magic/darkspawn/kingcrimson_end.ogg'

/obj/effect/temp_visual/quantum_disruption
	name = "warlock jaunt in"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "blank"
	duration = 0
/obj/effect/temp_visual/quantum_disruption/out
	name = "warlock jaunt out"
	icon = 'icons/mob/simple/mob.dmi'
	icon_state = "slasherj_end"
	duration = 1.3


	/**
 * Begin the jaunt, and the entire jaunt chain.
 * Puts owner in the phased mob holder here.
 */
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/quantum_disruption/do_jaunt(mob/living/jaunter)
	//createes distraction clone
	var/mob/living/simple_animal/hostile/illusion/darkspawn/decoy = new(get_turf(jaunter))
	decoy.Copy_Parent(jaunter, jaunt_duration, 100, 20) //closely follows regular player stats so it's not painfully obvious (still sorta is)
	decoy.cached_multiplicative_slowdown = jaunter.cached_multiplicative_slowdown
	decoy.GiveTarget(owner) //so it starts running right away
	decoy.Goto(owner, decoy.move_to_delay, decoy_min_distance)

	. = ..()



//////////////////////////////////////////////////////////////////////////
//----------------I stole blood beam from blood cultists----------------// (and made it better)
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/shadow_beam
	name = "Void beam"
	desc = "After a short delay, fire a huge beam of void terrain across the entire station."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "shadow_beam"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 90 SECONDS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100) //big fuckin layzer
	sound = null
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY //lol
	///boolean, whether or not the spell is being charged
	var/charging = FALSE
	///how many times the charge sound effect plays, also affects delay, sorta like a cast time
	var/charge_ticks = 2 //1 second per tick
	///turf of the caster at the moment of casting starting
	var/turf/targets_from
	///turf targeted for the center of the beam
	var/turf/targets_to

/datum/action/cooldown/spell/pointed/shadow_beam/can_cast_spell(feedback)
	if(charging)
		return
	return ..()

/datum/action/cooldown/spell/pointed/shadow_beam/cast(atom/cast_on)
	. = ..()
	if(charging)
		return

	targets_from = get_turf(owner)
	targets_to = get_turf(cast_on)

	owner.balloon_alert(owner, "qwo...")
	to_chat(owner, span_velvet("You start building up psionic energy."))
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(start_beam), owner) //so the reticle doesn't continue to show even after clicking

/datum/action/cooldown/spell/pointed/shadow_beam/proc/start_beam(mob/user)
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user) //visual effect
	if(do_after(user, charge_ticks SECONDS, user))
		INVOKE_ASYNC(src, PROC_REF(fire_beam), user)
	charging = FALSE

/datum/action/cooldown/spell/pointed/shadow_beam/proc/charge(mob/user, times = charge_ticks, first = TRUE)
	if(!charging)
		return
	if(times <= 0)
		return
	var/power = charge_ticks - times //grow in sound volume and added sound range as it charges
	var/volume = min(10 + (power * 20), 60)
	playsound(user, 'sound/effects/magic.ogg', volume, TRUE, power)
	playsound(user, 'sound/magic/darkspawn/devour_will_begin.ogg', volume, TRUE, power)
	if(first)
		new /obj/effect/temp_visual/cult/rune_spawn/rune1(user.loc, 2 SECONDS, "#21007F")
	else
		new /obj/effect/temp_visual/cult/rune_spawn/rune1/reverse(user.loc, 2 SECONDS, "#21007F")
	addtimer(CALLBACK(src, PROC_REF(charge), user, times - 1, !first), 1 SECONDS)

/obj/effect/temp_visual/cult/rune_spawn/rune1/reverse //spins the other way, that's it
	turnedness = 179

/datum/action/cooldown/spell/pointed/shadow_beam/proc/fire_beam(mob/user)
	if(!targets_from || !targets_to) //sanity check
		return
	user.balloon_alert(user, "...GX'KSHA!")
	if(IS_DARKSPAWN(user))
		var/datum/antagonist/darkspawn/darkspawn = IS_DARKSPAWN(user)
		darkspawn.block_psi(30 SECONDS, type)

	playsound(user, 'sound/magic/darkspawn/devour_will_end.ogg', 100, FALSE, 30)
	//split in two so the targeted tile is always in the center of the beam
	for(var/turf/step_target in get_line(targets_from, targets_to))
		spawn_ground(step_target)

	//extrapolate a new end target along the line using an angle
	var/turf/distant_target = get_turf_in_angle(get_angle(targets_from, targets_to), targets_to, 100) //100 tiles past the end point, roughly following the angle of the original line

	for(var/turf/step_target in get_line(targets_to, distant_target))
		spawn_ground(step_target)

/datum/action/cooldown/spell/pointed/shadow_beam/proc/spawn_ground(turf/target)
	for(var/turf/realtile in RANGE_TURFS(1, target)) //bit of aoe around the line (probably super fucking intensive lol)
		var/obj/effect/temp_visual/darkspawn/chasm/effect = locate() in realtile.contents
		if(!effect) //to prevent multiple visuals from appearing on the same tile and doing more damage than intended
			effect = new(realtile)

/obj/effect/temp_visual/darkspawn
	name = "echoing void"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	anchored = TRUE
	move_resist = INFINITY

/obj/effect/temp_visual/darkspawn/chasm //a slow field that eventually explodes
	icon_state = "consuming"
	duration = 4 SECONDS //functions as the delay until the explosion, just make sure it's not shorter than 1.1 seconds or it fucks up the animation
	plane = WALL_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	alpha = 0

/obj/effect/temp_visual/darkspawn/chasm/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	animate(src, 1.1 SECONDS, alpha = 255) //fade into existence

/obj/effect/temp_visual/darkspawn/chasm/proc/on_entered(datum/source, atom/movable/AM, ...)
	if(isliving(AM))
		var/mob/living/target = AM
		if(!IS_TEAM_DARKSPAWN(target))
			target.apply_status_effect(/datum/status_effect/speed_boost, 1 SECONDS, 3, type) //slow field, makes it harder to escape

/obj/effect/temp_visual/darkspawn/chasm/Destroy()
	new/obj/effect/temp_visual/darkspawn/detonate(get_turf(src))
	return ..()

/obj/effect/temp_visual/darkspawn/detonate //the explosion effect, applies damage when it disappears
	icon_state = "detonate"
	plane = WALL_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	duration = 2

/obj/effect/temp_visual/darkspawn/detonate/Destroy()
	var/turf/tile_location = get_turf(src)
	for(var/mob/living/victim in tile_location.contents)
		if(IS_TEAM_DARKSPAWN(victim))
			victim.heal_ordered_damage(90, list(BURN, BRUTE, TOX, OXY, CLONE, STAMINA))
		else if(!victim.can_block_magic(MAGIC_RESISTANCE_MIND))
			victim.take_overall_damage(10, 50, 200) //skill issue if you don't dodge it (won't crit if you're full hp)
	. = ..()

//////////////////////////////////////////////////////////////////////////
//-------------------I stole heirophant's burst ability-----------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/null_burst
	name = "Null Burst"
	desc = "After a short delay, create an explosion of void terrain at the targeted location."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "null_burst"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 90 SECONDS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100) //big fuckin boom
	sound = null
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY //lol
	///boolean, whether or not the ability is actively being casted
	var/charging = FALSE
	///how many times the charge sound effect plays, also affects delay, sorta like a cast time
	var/charge_ticks = 2 //1 second per tick
	///the targeted location for the burst
	var/turf/targets_to
	///radius of the burst aoe
	var/burst_range = 4
	///modifies the delay between waves in the burst
	var/spread_speed = 1

/datum/action/cooldown/spell/pointed/null_burst/can_cast_spell(feedback)
	if(charging)
		return
	return ..()

/datum/action/cooldown/spell/pointed/null_burst/is_valid_target(atom/cast_on) //can target yourself if you really want to
	return TRUE

/datum/action/cooldown/spell/pointed/null_burst/cast(atom/cast_on)
	. = ..()
	if(charging)
		return

	targets_to = get_turf(cast_on)

	owner.balloon_alert(owner, "qwo...")
	to_chat(owner, span_velvet("You start building up psionic energy."))
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(start_beam), owner) //so the reticle doesn't continue to show even after clicking

/datum/action/cooldown/spell/pointed/null_burst/proc/start_beam(mob/user)
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(charge), user) //visual effect
	if(do_after(user, charge_ticks SECONDS, user))
		INVOKE_ASYNC(src, PROC_REF(burst), user)
	charging = FALSE

/datum/action/cooldown/spell/pointed/null_burst/proc/charge(mob/user, times = charge_ticks, first = TRUE)
	if(!charging)
		return
	if(times <= 0)
		return
	var/power = charge_ticks - times //grow in sound volume and added sound range as it charges
	var/volume = min(10 + (power * 20), 60)
	playsound(user, 'sound/effects/magic.ogg', volume, TRUE, power)
	playsound(user, 'sound/magic/darkspawn/devour_will_begin.ogg', volume, TRUE, power)
	if(first)
		new /obj/effect/temp_visual/cult/rune_spawn/rune1(user.loc, 2 SECONDS, "#21007F")
	else
		new /obj/effect/temp_visual/cult/rune_spawn/rune1/reverse(user.loc, 2 SECONDS, "#21007F")
	addtimer(CALLBACK(src, PROC_REF(charge), user, times - 1, !first), 1 SECONDS)

/datum/action/cooldown/spell/pointed/null_burst/proc/burst(mob/user)
	if(!targets_to)
		return

	user.balloon_alert(user, "...GWO'KSHA!")
	if(IS_DARKSPAWN(user))
		var/datum/antagonist/darkspawn/darkspawn = IS_DARKSPAWN(user)
		darkspawn.block_psi(30 SECONDS, type)

	playsound(user, 'sound/magic/darkspawn/devour_will_end.ogg', 100, FALSE, 30)
	playsound(targets_to,'sound/magic/darkspawn/divulge_end.ogg', 70, TRUE, burst_range)

	var/last_dist = 0
	var/real_delay = 0
	for(var/t in spiral_range_turfs(burst_range, targets_to))
		var/turf/T = t
		if(!T)
			continue
		var/dist = get_dist(targets_to, T)
		if(dist > last_dist)
			last_dist = dist
			real_delay += (0.1 SECONDS) + (min(burst_range - last_dist, 1.2 SECONDS) * spread_speed) //gets faster as it gets further out
		addtimer(CALLBACK(src, PROC_REF(spawn_ground), T), real_delay) //spawns turf with a callback to avoid using sleep() in a loop like heiro does

/datum/action/cooldown/spell/pointed/null_burst/proc/spawn_ground(turf/target)
	new /obj/effect/temp_visual/darkspawn/chasm(target)

//////////////////////////////////////////////////////////////////////////
//----------------------I stole genetics rust wave  --------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/cone/staggered/shadowflame
	name = "Shadowflame Gout"
	desc = "Release a burst of shadowflame, rapidly sapping the heat of any individual."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "veiling_touch"
	panel = "Darkspawn"
	sound = 'sound/magic/demon_dies.ogg'

	school = SCHOOL_EVOCATION
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	cooldown_time = 60 SECONDS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100) //dangerous, high CC, and area denial

	delay_between_level = 0.3 SECONDS //longer delay
	cone_levels = 5 //longer cone
	respect_density = TRUE

/datum/action/cooldown/spell/cone/staggered/shadowflame/cast(atom/cast_on)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/shadowflame(get_step(cast_on, cast_on.dir), cast_on.dir)

/datum/action/cooldown/spell/cone/staggered/shadowflame/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	target_turf.extinguish()

/datum/action/cooldown/spell/cone/staggered/shadowflame/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_TEAM_DARKSPAWN(target_mob)) //no friendly fire
		return
	to_chat(target_mob, span_userdanger("A wave of darkness engulfs you!"))
	if(target_mob.reagents)
		target_mob.reagents.add_reagent(/datum/reagent/consumable/frostoil, 5)
		target_mob.reagents.add_reagent(/datum/reagent/shadowfrost, 10)
		target_mob.reagents.add_reagent(/datum/reagent/fluorine, 10)

/datum/action/cooldown/spell/cone/staggered/shadowflame/calculate_cone_shape(current_level)
	// At the first level (that isn't level 1) we will be small
	if(current_level == 2)
		return 3
	// At the max level, we turn small again
	if(current_level == cone_levels)
		return 3
	// Otherwise, all levels in between will be wider
	return 5

/obj/effect/temp_visual/dir_setting/shadowflame/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

/obj/effect/temp_visual/dir_setting/shadowflame
	icon = 'icons/effects/160x160.dmi'
	icon_state = "shadow_gout"
	duration = 3 SECONDS
