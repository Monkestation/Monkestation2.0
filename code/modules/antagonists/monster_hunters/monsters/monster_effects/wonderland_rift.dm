/obj/effect/bnnuy
	name = "wonderland rift"
	desc = span_big(span_hypnophrase("FEED YOUR HEAD."))
	icon = 'monkestation/icons/mob/rabbit.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = parent_type::resistance_flags | SHUTTLE_CRUSH_PROOF
	invisibility = INVISIBILITY_OBSERVER
	/// The icon state applied to the image created for this rift.
	var/real_icon_state = "bnnuy-rift"
	/// The antag datum of the monster hunter that can see us.
	var/datum/antagonist/monsterhunter/hunter_antag
	/// Is this rabbit selected to drop the gun?
	var/drop_gun = FALSE
	/// Proximity monitor that gives the hunter x-ray vision
	var/datum/proximity_monitor/bnnuy_monitor/monitor

/obj/effect/bnnuy/Initialize(mapload, datum/antagonist/monsterhunter/hunter)
	. = ..()
	if(!istype(hunter) || QDELING(hunter) || QDELETED(hunter.owner) || !isopenturf(loc))
		return INITIALIZE_HINT_QDEL
	hunter_antag = hunter
	var/image/hunter_image = image(icon, src, real_icon_state, OBJ_LAYER)
	SET_PLANE_EXPLICIT(hunter_image, ABOVE_LIGHTING_PLANE, src)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/bnnuy_rift, "bnnuy_rift", hunter_image, hunter_antag.owner)
	AddComponent(/datum/component/redirect_attack_hand_from_turf, interact_check = CALLBACK(src, PROC_REF(verify_user_can_see)))
	AddElement(/datum/element/block_turf_fingerprints)
	monitor = new(src, 7)

/obj/effect/bnnuy/Destroy(force)
	QDEL_NULL(monitor)
	hunter_antag?.rabbits -= src
	hunter_antag = null
	return ..()

/obj/effect/bnnuy/examine(mob/user)
	. = ..()
	if(hunter_antag)
		. += span_info("Use your hunter weapon in order to tear open the rift. ") + span_warning("This will be visible to anyone nearby!")
		. += span_info("You have opened [hunter_antag.rifts_opened] out of [hunter_antag.total_rifts] rifts.")

/obj/effect/bnnuy/attackby(obj/item/weapon, mob/user, params)
	if(user.mind != hunter_antag.owner)
		if(isobserver(user))
			return
		else
			CRASH("Someone who wasn't a hunter or an observer clicked a wonderland rift??")
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	if(!istype(weapon, /obj/item/melee/trick_weapon))
		to_chat(user, span_warning("You must use your hunter weapon in order to tear open the wonderland rift!"))
		return
	balloon_alert(user, "opening rift!")
	user.visible_message(span_danger("[user] stabs \the [weapon] into the ground, beginning to slice through something unseen!"))
	if(!do_after(user, 10 SECONDS, src))
		return
	user.visible_message(span_danger("[user] plunges \the [weapon] deep into the ground, tearing it open!"), span_notice("You plunge \the [weapon] deep into the ground, slicing open the rift to the wonderland!"))
	open_rift(user)
	SEND_SIGNAL(hunter_antag, COMSIG_GAIN_INSIGHT)
	qdel(src)

/obj/effect/bnnuy/attack_hand(mob/living/user, list/modifiers)
	if(user?.mind != hunter_antag.owner)
		return SECONDARY_ATTACK_CALL_NORMAL
	to_chat(user, span_warning("You must use your hunter weapon in order to tear open the wonderland rift!"))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/effect/bnnuy/proc/verify_user_can_see(mob/user)
	return (user?.mind == hunter_antag.owner)

/obj/effect/bnnuy/proc/open_rift(mob/living/user)
	var/list/extra_logs = list()
	hunter_antag.rifts_opened++
	if(hunter_antag.rifts_opened == 1) //our first bunny
		user.put_in_hands(new /obj/item/clothing/mask/cursed_rabbit(drop_location()))
		extra_logs += "the cursed rabbit mask"
	user.put_in_hands(new /obj/item/rabbit_eye(drop_location()))
	if(drop_gun)
		give_gun(user)
		extra_logs += "the hunter's revolver"
	hunter_antag.rabbits -= src
	var/msg = "opened a wonderland rift ([hunter_antag.rifts_opened] / [hunter_antag.total_rifts]) at [AREACOORD(src)]"
	if(length(extra_logs) > 0)
		msg += ", which dropped [english_list(extra_logs)]"
	user.log_message(msg, LOG_GAME)
	new /obj/effect/anomaly/dimensional/wonderland/rift(get_turf(src), null, FALSE)
	var/rabbit_amount = max(rand(hunter_antag.rifts_opened, hunter_antag.rifts_opened + 2), 2)
	// spawn (benign) rabbits randomly around the station
	for(var/i = 1 to rabbit_amount)
		var/turf/target_turf = get_safe_random_station_turf_equal_weight()
		new /obj/effect/wonderland_rabbit_enter(target_turf)

/obj/effect/bnnuy/proc/give_gun(mob/living/user)
	user.put_in_hands(new /obj/item/gun/ballistic/revolver/hunter_revolver(drop_location()))
	var/datum/action/cooldown/spell/conjure_item/blood_silver/silverblood = new(user)
	silverblood.StartCooldown()
	silverblood.Grant(user)

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift
	add_ghost_version = TRUE
	/// The mind of the hunter that should see this rift.
	var/datum/mind/hunter_mind

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift/New(key, image/I, datum/mind/hunter_mind)
	src.hunter_mind = hunter_mind
	return ..(key, I, NONE)

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift/Destroy()
	. = ..()
	hunter_mind = null

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift/mobShouldSee(mob/target)
	return !isobserver(target) && target.mind == hunter_mind

// stolen from heretic rework lol
/datum/proximity_monitor/bnnuy_monitor
	/// Cooldown before we can give the hunter xray
	COOLDOWN_DECLARE(xray_cooldown)

/datum/proximity_monitor/bnnuy_monitor/on_entered(atom/source, mob/living/arrived, turf/old_loc)
	. = ..()
	if(!isliving(arrived) || !COOLDOWN_FINISHED(src, xray_cooldown))
		return
	var/obj/effect/bnnuy/bnnuy = host
	if(arrived.mind == bnnuy.hunter_antag.owner && arrived.client && !arrived.has_status_effect(/datum/status_effect/temporary_xray))
		arrived.apply_status_effect(/datum/status_effect/temporary_xray)
		arrived.playsound_local(get_turf(bnnuy), 'monkestation/sound/effects/rabbitlocator.ogg', vol = 75, vary = FALSE, pressure_affected = FALSE, falloff_distance = 0)
		COOLDOWN_START(src, xray_cooldown, 3 MINUTES)

/**
 * Effectively grants a temporary form of x-ray with a cooldown period.
 */
/datum/status_effect/temporary_xray
	id = "temp xray"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	duration = 8 SECONDS
	show_duration = TRUE

/datum/status_effect/temporary_xray/on_apply()
	owner.add_traits(list(TRAIT_XRAY_VISION, TRAIT_TRUE_NIGHT_VISION), TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	return TRUE

/datum/status_effect/temporary_xray/on_remove()
	owner.remove_traits(list(TRAIT_XRAY_VISION, TRAIT_TRUE_NIGHT_VISION), TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
