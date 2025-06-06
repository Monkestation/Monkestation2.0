/obj/item/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	custom_fire_overlay = "paperplane_onfire"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50

	var/hit_probability = 2 //%
	var/obj/item/paper/internalPaper

	//monkestation edit start
	/// How long does getting shot in the eyes knock you down for?
	var/knockdown_duration = 4 SECONDS
	/// How much eye damage does it deal at minimum on eye impact?
	var/impact_eye_damage_lower = 6
	/// How much eye damage does it deal at maximum on eye impact?
	var/impact_eye_damage_higher = 8
	/// Does it get deleted when hitting anything or landing?
	var/delete_on_impact = FALSE
	//monkestation edit end
/obj/item/paperplane/syndicate
	desc = "Paper, masterfully folded in the shape of a plane."
	throwforce = 20 //same as throwing stars, but no chance of embedding.
	hit_probability = 100 //guaranteed to cause eye damage when it hits a mob.

/obj/item/paperplane/Initialize(mapload, obj/item/paper/newPaper)
	. = ..()
	pixel_x = base_pixel_x + rand(-9, 9)
	pixel_y = base_pixel_y + rand(-8, 8)
	if(newPaper)
		internalPaper = newPaper
		flags_1 = newPaper.flags_1
		color = newPaper.color
		newPaper.forceMove(src)
	else
		internalPaper = new(src)
	if(internalPaper.icon_state == "cpaper" || internalPaper.icon_state == "cpaper_words")
		icon_state = "paperplane_carbon" // It's the purple carbon copy. Use the purple paper plane
	update_appearance()

/obj/item/paperplane/Exited(atom/movable/gone, direction)
	. = ..()
	if (internalPaper == gone)
		internalPaper = null
		if(!QDELETED(src))
			qdel(src)

/obj/item/paperplane/Destroy()
	internalPaper = null
	return ..()

/obj/item/paperplane/suicide_act(mob/living/user)
	var/obj/item/organ/internal/eyes/eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	user.Stun(200)
	user.visible_message(span_suicide("[user] jams [src] in [user.p_their()] nose. It looks like [user.p_theyre()] trying to commit suicide!"))
	user.adjust_eye_blur(12 SECONDS)
	if(eyes)
		eyes.apply_organ_damage(rand(impact_eye_damage_lower, impact_eye_damage_higher)) //monkestation edit
	sleep(1 SECONDS)
	return BRUTELOSS

/obj/item/paperplane/update_overlays()
	. = ..()
	for(var/stamp in internalPaper.stamp_cache)
		. += "paperplane_[stamp]"

/obj/item/paperplane/attack_self(mob/user)
	balloon_alert(user, "unfolded")

	var/atom/location = drop_location()
	// Need to keep a reference to the internal paper
	// when we move it out of the plane, our ref gets set to null
	var/obj/item/paper/internal_paper = internalPaper
	internal_paper.forceMove(location)
	// This will as a side effect, qdel the paper plane, making the user's hands empty

	user.put_in_hands(internal_paper)

/obj/item/paperplane/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(burn_paper_product_attackby_check(P, user))
		return
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, span_warning("You should unfold [src] before changing it!"))
		return

	else if(istype(P, /obj/item/stamp)) //we don't randomize stamps on a paperplane
		internalPaper.attackby(P, user) //spoofed attack to update internal paper.
		update_appearance()
		add_fingerprint(user)
		return

	return ..()


/obj/item/paperplane/throw_at(atom/target, range, speed, mob/thrower, spin=FALSE, diagonals_first = FALSE, datum/callback/callback, gentle, quickstart = TRUE)
	. = ..(target, range, speed, thrower, FALSE, diagonals_first, callback, quickstart = quickstart)

/obj/item/paperplane/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscarbon(hit_atom))
		var/mob/living/carbon/C = hit_atom
		if(C.can_catch_item(TRUE))
			var/datum/action/innate/origami/origami_action = locate() in C.actions
			if(origami_action?.active) //if they're a master of origami and have the ability turned on, force throwmode on so they'll automatically catch the plane.
				C.throw_mode_on(THROW_MODE_TOGGLE)

	if(..() || !ishuman(hit_atom))//if the plane is caught or it hits a nonhuman
		return
	//monkestation edit
	if(delete_on_impact)
		qdel(src)
	//monkestation edit end
	var/mob/living/carbon/human/H = hit_atom
	var/obj/item/organ/internal/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
	if(prob(hit_probability))
		if(H.is_eyes_covered())
			return
		//monkestation edit
		if(delete_on_impact)
			qdel(src)
		//monkestation edit end
		visible_message(span_danger("\The [src] hits [H] in the eye[eyes ? "" : " socket"]!"))
		H.adjust_eye_blur(12 SECONDS)
		eyes?.apply_organ_damage(rand(impact_eye_damage_lower, impact_eye_damage_higher))
		H.Knockdown(knockdown_duration)
		H.emote("scream")
		if(delete_on_impact)
			qdel(src)

/obj/item/paper/examine(mob/user)
	. = ..()
	if(!can_be_folded)
		return
	. += span_notice("Alt-click [src] to fold it into a paper plane.")

/obj/item/paper/AltClick(mob/living/user, obj/item/I)
	if(!user.can_perform_action(src, NEED_DEXTERITY|NEED_HANDS))
		return
	if(istype(src, /obj/item/paper/carbon))
		var/obj/item/paper/carbon/Carbon = src
		if(!Carbon.copied)
			to_chat(user, span_notice("Take off the carbon copy first."))
			return
	if(!can_be_folded)
		to_chat(user, span_notice("This paper cannot be folded into a plane."))
		return
	//Origami Master
	var/datum/action/innate/origami/origami_action = locate() in user.actions
	if(origami_action?.active)
		make_plane(user, I, /obj/item/paperplane/syndicate)
	else
		make_plane(user, I, /obj/item/paperplane)

/**
 * Paper plane folding
 *
 * Arguments:
 * * mob/living/user - who's folding
 * * obj/item/I - what's being folded
 * * obj/item/paperplane/plane_type - what it will be folded into (path)
 */
/obj/item/paper/proc/make_plane(mob/living/user, obj/item/I, obj/item/paperplane/plane_type = /obj/item/paperplane)
	balloon_alert(user, "folded into a plane")
	user.temporarilyRemoveItemFromInventory(src)
	I = new plane_type(loc, src)
	if(user.Adjacent(I))
		user.put_in_hands(I)
