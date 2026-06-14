/obj/item/organ/internal/brain/psyker
	name = "psyker brain"
	desc = "This brain is blue, split into two hemispheres, and has immense psychic powers. What kind of monstrosity would use that?"
	icon_state = "brain-psyker"
	actions_types = list(
		/datum/action/cooldown/spell/pointed/psychic_projection,
		/datum/action/cooldown/spell/charged/psychic_booster,
		/datum/action/cooldown/spell/forcewall/psychic_wall,
	)
	organ_traits = list(TRAIT_ADVANCEDTOOLUSER, TRAIT_LITERATE, TRAIT_CAN_STRIP, TRAIT_ANTIMAGIC_NO_SELFBLOCK)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/organ/internal/brain/psyker/on_insert(mob/living/carbon/inserted_into)
	. = ..()
	inserted_into.AddComponent(/datum/component/echolocation, blocking_trait = TRAIT_DUMB, echo_group = "psyker", echo_icon = "psyker", color_path = /datum/client_colour/psyker)
	inserted_into.AddComponent(/datum/component/anti_magic, antimagic_flags = MAGIC_RESISTANCE_MIND)

/obj/item/organ/internal/brain/psyker/on_remove(mob/living/carbon/removed_from)
	. = ..()
	qdel(removed_from.GetComponent(/datum/component/echolocation))
	qdel(removed_from.GetComponent(/datum/component/anti_magic))

/obj/item/organ/internal/brain/psyker/on_life(seconds_between_ticks, times_fired)
	. = ..()
	var/obj/item/bodypart/head/psyker/psyker_head = owner.get_bodypart(zone)
	if(istype(psyker_head))
		return
	if(!SPT_PROB(2, seconds_between_ticks))
		return
	to_chat(owner, span_userdanger("Your head hurts... It can't fit your brain!"))
	owner.adjust_disgust(33 * seconds_between_ticks)
	apply_organ_damage(5 * seconds_between_ticks, 199)

/obj/item/bodypart/head/psyker
	limb_id = BODYPART_ID_PSYKER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_DISFIGURED, TRAIT_BALD, TRAIT_SHAVED)
	head_flags = HEAD_LIPS|HEAD_EYEHOLES|HEAD_DEBRAIN

/obj/item/bodypart/head/psyker/try_attach_limb(mob/living/carbon/new_head_owner, special, abort)
	. = ..()
	if(!.)
		return
	new_head_owner.become_blind(bodypart_trait_source)

/obj/item/bodypart/head/psyker/drop_limb(special, dismembered, violent)
	owner.cure_blind(bodypart_trait_source)
	return ..()

/// flavorful variant of psykerizing that deals damage and sends messages before calling psykerize()
/mob/living/carbon/human/proc/slow_psykerize()
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD) || istype(get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/psyker))
		return
	to_chat(src, span_userdanger("You feel unwell..."))
	sleep(5 SECONDS)
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("You feel your skin ripping off!"))
	emote("scream")
	apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	sleep(5 SECONDS)
	if(!psykerize())
		to_chat(src, span_warning("The transformation subsides..."))
		return
	var/obj/item/bodypart/head/psyker_head = get_bodypart(BODY_ZONE_HEAD)
	psyker_head.receive_damage(brute = 50)
	to_chat(src, span_userdanger("Your head splits open! Your brain mutates!"))
	new /obj/effect/gibspawner/generic(drop_location(), src)
	emote("scream")

/// Proc with no side effects that turns someone into a psyker. returns FALSE if it could not psykerize.
/mob/living/carbon/human/proc/psykerize()
	var/obj/item/bodypart/head/old_head = get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/brain/old_brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/internal/old_eyes = get_organ_slot(ORGAN_SLOT_EYES)
	if(stat == DEAD || !old_head || !old_brain)
		return FALSE
	var/obj/item/bodypart/head/psyker/psyker_head = new()
	if(!psyker_head.replace_limb(src, special = TRUE))
		return FALSE
	qdel(old_head)
	var/obj/item/organ/internal/brain/psyker/psyker_brain = new()
	old_brain.before_organ_replacement(psyker_brain)
	old_brain.Remove(src, special = TRUE, no_id_transfer = TRUE)
	qdel(old_brain)
	psyker_brain.Insert(src, special = TRUE, drop_if_replaced = FALSE)
	if(old_eyes)
		qdel(old_eyes)
	return TRUE

/datum/action/cooldown/spell/pointed/psychic_projection
	name = "Psychic Projection"
	desc = "Project your psychics into a target to warp their view, and instill absolute terror that will cause them to fire their gun rapidly."
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	button_icon_state = "blind"
	school = SCHOOL_PSYCHIC
	cooldown_time = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE_MIND
	spell_max_level = 1
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cast_range = 5
	active_msg = "You prepare to psychically project to a target..."
	/// Duration of the effects.
	var/projection_duration = 10 SECONDS

/datum/action/cooldown/spell/pointed/psychic_projection/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_target = cast_on
	return !living_target.has_status_effect(/datum/status_effect/psychic_projection)

/datum/action/cooldown/spell/pointed/psychic_projection/cast(mob/living/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Your mind feels weird, but it passes momentarily."))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE
	to_chat(cast_on, span_userdanger("Your mind gets twisted!"))
	cast_on.emote("scream")
	cast_on.apply_status_effect(/datum/status_effect/psychic_projection, projection_duration)
	return TRUE

/// Status effect that adds a weird view to its owner and causes them to rapidly shoot a firearm in their general direction.
/datum/status_effect/psychic_projection
	id = "psychic_projection"
	alert_type = null
	remove_on_fullheal = TRUE
	tick_interval = 0.2 SECONDS
	/// Times the target has dry fired a weapon.
	var/times_dry_fired = 0
	/// Needs to reach times_dry_fired for the next dry fire to happen.
	var/firing_delay = 0

/datum/status_effect/psychic_projection/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/psychic_projection/on_apply()
	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		return FALSE
	game_plane_master_controller.add_filter("psychic_wave", 10, wave_filter(240, 240, 3, 0, WAVE_SIDEWAYS))
	game_plane_master_controller.add_filter("psychic_blur", 10, angular_blur_filter(0, 0, 3))
	return TRUE

/datum/status_effect/psychic_projection/on_remove()
	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(!game_plane_master_controller)
		return
	game_plane_master_controller.remove_filter("psychic_blur")
	game_plane_master_controller.remove_filter("psychic_wave")

/datum/status_effect/psychic_projection/tick(seconds_between_ticks, times_fired)
	var/obj/item/gun/held_gun = owner?.is_holding_item_of_type(/obj/item/gun)
	if(!held_gun)
		return
	if(!held_gun.can_shoot())
		if(firing_delay < times_dry_fired)
			firing_delay++
			return
		firing_delay = 0
		times_dry_fired++
	else
		times_dry_fired = 0
	var/turf/target_turf = get_offset_target_turf(get_ranged_target_turf(owner, owner.dir, 7), dx = rand(-1, 1), dy = rand(-1, 1))
	held_gun.process_fire(target_turf, owner, TRUE, null, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
	held_gun.semicd = FALSE

/datum/action/cooldown/spell/charged/psychic_booster
	name = "Psychic Booster"
	desc = "Charge up your mind to shoot firearms faster and home in on your targets. Think smarter, not harder."
	button_icon_state = "projectile"
	sound = 'sound/weapons/gun/shotgun/rack.ogg'
	school = SCHOOL_PSYCHIC
	cooldown_time = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE_MIND
	spell_max_level = 1
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	channel_message = span_notice("You focus on your trigger fingers...")
	charge_overlay_icon = 'icons/effects/effects.dmi'
	charge_overlay_state = "purplesparkles"
	channel_time = 5 SECONDS
	/// Are we currently active?
	var/boosted = FALSE
	/// How long the effect lasts for?
	var/effect_time = 10 SECONDS

/datum/action/cooldown/spell/charged/psychic_booster/Destroy()
	if(boosted)
		stop_effects()
	return ..()

/datum/action/cooldown/spell/charged/psychic_booster/Remove(mob/living/remove_from)
	if(boosted)
		stop_effects()
	return ..()

/datum/action/cooldown/spell/charged/psychic_booster/cast(atom/cast_on)
	. = ..()
	if(boosted)
		return
	boosted = TRUE
	to_chat(owner, span_boldnotice("Your trigger fingers feel stronger."))
	ADD_TRAIT(cast_on, TRAIT_DOUBLE_TAP, type)
	RegisterSignal(cast_on, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE, PROC_REF(modify_projectile))
	addtimer(CALLBACK(src, PROC_REF(stop_effects)), effect_time)

/datum/action/cooldown/spell/charged/psychic_booster/proc/stop_effects()
	boosted = FALSE
	to_chat(owner, span_danger("Your trigger fingers feel weaker."))
	REMOVE_TRAIT(owner, TRAIT_DOUBLE_TAP, type)
	UnregisterSignal(owner, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE)

/datum/action/cooldown/spell/charged/psychic_booster/proc/modify_projectile(datum/source, obj/projectile/bullet, atom/firer, atom/original_target)
	var/atom/target = original_target
	if(isturf(target) || (isobj(target) && !target.density)) //if weird target, we try to compensate in our homing
		for(var/mob/living/shooting_target in range(1, get_turf(target)))
			if(shooting_target == firer)
				continue
			target = shooting_target
			break
	if(!bullet.can_hit_target(target, direct_target = TRUE, ignore_loc = TRUE))
		return
	bullet.original = target
	bullet.homing_turn_speed = 30
	bullet.set_homing_target(target)

/datum/action/cooldown/spell/forcewall/psychic_wall
	name = "Psychic Wall"
	desc = "Form a psychic wall, able to deflect projectiles and prevent things from going through."
	school = SCHOOL_PSYCHIC
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 0 SECONDS
	antimagic_flags = MAGIC_RESISTANCE_MIND
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	spell_max_level = 1
	invocation_type = INVOCATION_NONE
	wall_type = /obj/structure/forcefield/psychic

/datum/action/cooldown/spell/forcewall/psychic_wall/spawn_wall(turf/cast_turf)
	. = ..()
	play_fov_effect(cast_turf, 5, "forcefield", time = 10 SECONDS)
