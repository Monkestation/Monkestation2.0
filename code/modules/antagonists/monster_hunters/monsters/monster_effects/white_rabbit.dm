/obj/effect/bnnuy
	name = "white rabbit"
	desc = span_big(span_hypnophrase("FEED YOUR HEAD."))
	icon = 'icons/mob/rabbit.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = parent_type::resistance_flags | SHUTTLE_CRUSH_PROOF
	invisibility = INVISIBILITY_OBSERVER
	/// The icon state applied to the image created for this rabbit.
	var/real_icon_state = "white_rabbit"
	/// The antag datum of the monster hunter that can see us.
	var/datum/antagonist/monsterhunter/hunter_antag
	/// The mind of the monster hunter that can see us.
	var/datum/mind/hunter_mind
	/// A copy of our image pinned to the hunter's own turf and shifted over to us, so it still draws when our turf is hidden.
	var/image/far_image
	/// Has the rabbit already whispered?
	var/being_used = FALSE

/obj/effect/bnnuy/Initialize(mapload, datum/antagonist/monsterhunter/hunter)
	. = ..()
	if(!istype(hunter) || QDELING(hunter) || QDELETED(hunter.owner) || !isopenturf(loc) || QDELING(loc))
		return INITIALIZE_HINT_QDEL
	hunter_antag = hunter
	hunter_mind = hunter.owner
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/white_rabbit, "white_rabbit", create_bnnuy_image(), NONE, hunter_mind)
	update_far_image(hunter_mind.current)
	AddComponent(/datum/component/redirect_attack_hand_from_turf, adjust_for_pixel_shift = FALSE, interact_check = CALLBACK(src, PROC_REF(verify_user_can_see)))

/obj/effect/bnnuy/Destroy(force)
	hunter_antag?.rabbits -= src
	hunter_antag = null
	hunter_mind?.current?.client?.images -= far_image
	hunter_mind = null
	far_image = null
	return ..()

/obj/effect/bnnuy/examine(mob/user)
	. = ..()
	if(hunter_antag)
		. += span_info("You have found [hunter_antag.rabbits_spotted] out of 5 rabbits.")

/obj/effect/bnnuy/attack_hand(mob/living/user, list/modifiers)
	if(user?.mind != hunter_mind)
		return SECONDARY_ATTACK_CALL_NORMAL
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(being_used)
		return
	being_used = TRUE
	spotted(user)
	SEND_SIGNAL(hunter_antag, COMSIG_GAIN_INSIGHT)
	icon = 'icons/mob/rabbit.dmi'
	real_icon_state = "rabbit_hole"
	update_bnnuy_image()
	update_far_image(user)
	QDEL_IN(src, 8 SECONDS)

/// makes the image that sits on the rabbit itself, the one you can actually click
/obj/effect/bnnuy/proc/create_bnnuy_image() as /image
	RETURN_TYPE(/image)
	var/image/new_image = image(icon, src, real_icon_state, BELOW_MOB_LAYER)
	SET_PLANE_EXPLICIT(new_image, ABOVE_LIGHTING_PLANE, src)
	return new_image

/// swaps the on-rabbit image for a fresh one, mostly so it picks up the new icon state
/obj/effect/bnnuy/proc/update_bnnuy_image()
	remove_alt_appearance("white_rabbit")
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/white_rabbit, "white_rabbit", create_bnnuy_image(), NONE, hunter_mind)

/// redoes the copy pinned to the hunter's own turf (so it still shows through walls), needs redoing whenever they move
/obj/effect/bnnuy/proc/update_far_image(mob/living/hunter)
	hunter?.client?.images -= far_image
	far_image = null
	var/turf/hunter_turf = get_turf(hunter)
	if(being_used || !hunter_turf || hunter_turf.z != z)
		return
	far_image = image(icon, hunter_turf, real_icon_state, BELOW_MOB_LAYER)
	far_image.pixel_x = (x - hunter_turf.x) * ICON_SIZE_X
	far_image.pixel_y = (y - hunter_turf.y) * ICON_SIZE_Y
	far_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	SET_PLANE_EXPLICIT(far_image, ABOVE_LIGHTING_PLANE, hunter_turf)
	hunter?.client?.images |= far_image

/obj/effect/bnnuy/proc/verify_user_can_see(mob/user)
	return (user?.mind == hunter_mind)

/obj/effect/bnnuy/proc/spotted(mob/living/user)
	var/list/extra_logs = list()
	if(hunter_antag)
		if(hunter_antag.rabbits_spotted == 0) //our first bunny
			user.put_in_hands(new /obj/item/clothing/mask/cursed_rabbit(drop_location()))
			extra_logs += "the cursed rabbit mask"
		else if(hunter_antag.rabbits_spotted == 1) //our second bnnuy!
			give_gun(user)
			extra_logs += "the hunter's revolver"
	user.put_in_hands(new /obj/item/rabbit_eye(drop_location()))
	hunter_antag?.rabbits -= src
	var/msg = "claimed a white rabbit at [AREACOORD(src)]"
	if(length(extra_logs) > 0)
		msg += ", which dropped [english_list(extra_logs)]"
	user.log_message(msg, LOG_GAME)

/obj/effect/bnnuy/proc/give_gun(mob/living/user)
	user.put_in_hands(new /obj/item/gun/ballistic/revolver/hunter_revolver(drop_location()))
	var/datum/action/cooldown/spell/conjure_item/blood_silver/silverblood = new
	silverblood.StartCooldown()
	silverblood.Grant(user)
	hunter_antag.powers += silverblood

/datum/atom_hud/alternate_appearance/basic/white_rabbit
	/// The mind of the hunter who gets to see the rabbit
	var/datum/mind/hunter_mind

/datum/atom_hud/alternate_appearance/basic/white_rabbit/New(key, image/I, options = NONE, datum/mind/hunter_mind)
	src.hunter_mind = hunter_mind
	return ..()

/datum/atom_hud/alternate_appearance/basic/white_rabbit/mobShouldSee(mob/viewer)
	return viewer.mind == hunter_mind
