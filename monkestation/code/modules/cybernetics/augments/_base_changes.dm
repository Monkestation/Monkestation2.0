/datum/bodypart_overlay/simple/proc/unique_properties(obj/item/organ/internal/cyberimp/called_from)
	return

/obj/item/organ/internal/cyberimp
	organ_flags = ORGAN_ROBOTIC

	///are we a visual implant
	var/visual_implant = FALSE
	/// The bodypart overlay datum we should apply to whatever mob we are put into
	var/datum/bodypart_overlay/simple/bodypart_overlay
	/// What limb we are inside of, used for tracking when and how to remove our overlays and all that
	var/obj/item/bodypart/ownerlimb
	///how many times we failed to hack this
	var/failed_count = 0

/obj/item/organ/internal/cyberimp/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)
	if(implant_overlay) // <- this is old code that is better replaced with bodypart_overlays
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	update_icon()

/obj/item/organ/internal/cyberimp/Destroy()
	if(ownerlimb && visual_implant)
		remove_from_limb()
	return ..()

/obj/item/organ/internal/cyberimp/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	var/obj/item/bodypart/limb = receiver.get_bodypart(deprecise_zone(zone))
	. = ..()
	if(visual_implant)
		if(!. || QDELETED(limb))
			return FALSE

		ownerlimb = limb
		add_to_limb(ownerlimb)

/obj/item/organ/internal/cyberimp/add_to_limb(obj/item/bodypart/bodypart)
	ownerlimb = bodypart
	var/bodypart_overlay_path = src::bodypart_overlay
	if(ispath(bodypart_overlay_path))
		bodypart_overlay = new bodypart_overlay_path
		bodypart_overlay.unique_properties(src)
		ownerlimb.add_bodypart_overlay(bodypart_overlay)
	owner?.update_body_parts()
	return ..()

/obj/item/organ/internal/cyberimp/remove_from_limb()
	if(istype(bodypart_overlay))
		ownerlimb.remove_bodypart_overlay(bodypart_overlay)
		QDEL_NULL(bodypart_overlay)
	ownerlimb = null
	owner.update_body_parts()
	return ..()
