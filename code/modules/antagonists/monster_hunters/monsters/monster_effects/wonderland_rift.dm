/obj/effect/bnnuy
	name = "wonderland rift"
	desc = span_big(span_hypnophrase("FEED YOUR HEAD."))
	icon = 'icons/mob/wonderland_rabbit.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = parent_type::resistance_flags | SHUTTLE_CRUSH_PROOF
	invisibility = INVISIBILITY_OBSERVER
	/// The icon state applied to the image created for this rift.
	var/real_icon_state = "bnnuy-rift"
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
	if(!istype(hunter) || QDELING(hunter) || QDELETED(hunter.owner) || !isopenturf(loc))
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
		. += span_info("Use your hunter weapon to tear it open. ") + span_warning("Anyone nearby will see you do it!")
		. += span_info("You have opened [hunter_antag.rabbits_spotted] out of 5 rifts.")

/obj/effect/bnnuy/attack_hand(mob/living/user, list/modifiers)
	if(user?.mind != hunter_mind)
		return SECONDARY_ATTACK_CALL_NORMAL
	balloon_alert(user, "use your hunter weapon!")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/effect/bnnuy/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.mind != hunter_mind)
		return NONE
	if(being_used || DOING_INTERACTION_WITH_TARGET(user, src))
		return ITEM_INTERACT_BLOCKING
	if(!istype(tool, /obj/item/melee/trick_weapon))
		balloon_alert(user, "use your hunter weapon!")
		return ITEM_INTERACT_BLOCKING
	// gonna have to try a bit harder than that to interrupt them
	ADD_TRAIT(user, TRAIT_PUSHIMMUNE, REF(src))
	balloon_alert(user, "tearing it open...")
	user.visible_message(span_danger("[user] stabs [tool] into the ground, beginning to slice through something unseen!"))
	var/obj/effect/abstract/wonderland_tear/tear = new(loc, user)
	var/list/rift_images = list()
	if(far_image)
		rift_images += far_image
	var/datum/atom_hud/alternate_appearance/basic/rift_appearance = alternate_appearances?["white_rabbit"]
	if(rift_appearance)
		rift_images += rift_appearance.image
	for(var/image/rift_image as anything in rift_images)
		animate(rift_image, transform = matrix().Scale(1.25, 0.85), time = 0.3 SECONDS, loop = -1)
		animate(transform = matrix(), time = 0.7 SECONDS)
	var/finished = do_after(user, 10 SECONDS, src)
	REMOVE_TRAIT(user, TRAIT_PUSHIMMUNE, REF(src))
	if(!finished || being_used)
		tear.fizzle()
		for(var/image/rift_image as anything in rift_images)
			animate(rift_image, transform = matrix(), time = 0.2 SECONDS)
		return ITEM_INTERACT_SUCCESS
	tear.burst()
	being_used = TRUE
	user.visible_message(
		span_danger("[user] plunges [tool] deep into the ground, tearing it open!"),
		span_notice("You plunge [tool] deep into the ground, slicing the rift open!"),
		span_hear("You hear loud, echoing slicing!")
	)
	spotted(user)
	SEND_SIGNAL(hunter_antag, COMSIG_GAIN_INSIGHT)
	new /obj/effect/anomaly/dimensional/wonderland/rift(get_turf(src), null, FALSE)
	spawn_wonderland_rabbits()
	icon = 'icons/mob/rabbit.dmi'
	real_icon_state = "rabbit_hole"
	update_bnnuy_image()
	update_far_image(user)
	QDEL_IN(src, 8 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/effect/bnnuy/proc/spawn_wonderland_rabbits()
	var/opened = hunter_antag.rabbits_spotted
	for(var/turf/rabbit_turf as anything in pick_noise_station_turfs(max(rand(opened, opened + 2), 2), 4))
		new /obj/effect/wonderland_rabbit_enter(rabbit_turf, hunter_antag)

/// makes the image that sits on the rabbit itself, the one you can actually click
/obj/effect/bnnuy/proc/create_bnnuy_image() as /image
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
	var/turf/anchor = get_dist(hunter_turf, src) <= 1 ? get_turf(src) : hunter_turf
	far_image = image(icon, anchor, real_icon_state, BELOW_MOB_LAYER)
	far_image.pixel_x = (x - anchor.x) * ICON_SIZE_X
	far_image.pixel_y = (y - anchor.y) * ICON_SIZE_Y
	if(anchor == hunter_turf)
		far_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	SET_PLANE_EXPLICIT(far_image, ABOVE_LIGHTING_PLANE, anchor)
	hunter?.client?.images |= far_image

/obj/effect/bnnuy/proc/verify_user_can_see(mob/user)
	return (user?.mind == hunter_mind)

/obj/effect/bnnuy/proc/spotted(mob/living/user)
	var/list/extra_logs = list()
	switch(hunter_antag?.rabbits_spotted)
		if(0)
			to_chat(user, span_boldnotice("(WRITER TODO) red queen - rift one, here's the mask. she thinks ur kinda clumsy at this"))
		if(1)
			to_chat(user, span_boldnotice("(WRITER TODO) red queen - rift two, here's the revolver"))
		if(2)
			to_chat(user, span_boldnotice("(WRITER TODO) red queen - rift three, here's the armor. halfway there"))
		if(3)
			to_chat(user, span_boldnotice("(WRITER TODO) red queen - rift four. ur slipping, manners and face both"))
		if(4)
			to_chat(user, span_boldnotice("(WRITER TODO) red queen - rift five, edge of the board. she stops guiding u and just watches"))
			to_chat(user, span_hypnophrase("(WRITER TODO) narrator - something else behind her voice finds this funny"))
	if(hunter_antag)
		if(hunter_antag.rabbits_spotted == 0) //our first bunny
			user.put_in_hands(new /obj/item/clothing/mask/cursed_rabbit(drop_location()))
			extra_logs += "the cursed rabbit mask"
		else if(hunter_antag.rabbits_spotted == 1) //our second bnnuy!
			give_gun(user)
			extra_logs += "the hunter's revolver"
		else if(hunter_antag.rabbits_spotted == 2)
			user.put_in_hands(new /obj/item/storage/box/queens_huntsman(drop_location()))
			extra_logs += "the huntsman kit"
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
