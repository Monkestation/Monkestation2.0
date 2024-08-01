/obj/item/clothing/accessory/cetanoid_legs
	name = "\improper cetanoid legs"
	icon = 'monkestation/icons/obj/clothing/accessories/cetanoid_legs.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/accessories/cetanoid_legs.dmi'
	icon_state = "cetanoid_legs"
	desc = "A pair of cybernetic legs designed to be installed onto a jumpsuit."
	w_class = WEIGHT_CLASS_SMALL

	var/obj/item/bodypart/leg/left/stored_l_leg //store our legs so people dont just take their suit off and put it back on to heal
	var/obj/item/bodypart/leg/left/stored_r_leg

	var/overlay_color = COLOR_ASSISTANT_GRAY

/obj/item/clothing/accessory/cetanoid_legs/New()
	. = ..()
	var/mutable_appearance/color_overlay = mutable_appearance(icon, "overlay")
	color_overlay.color = overlay_color
	src.add_overlay(color_overlay)

/obj/item/clothing/accessory/cetanoid_legs/on_uniform_equipped(obj/item/clothing/under/source, mob/living/carbon/user, slot)
	. = ..()
	if((slot & ITEM_SLOT_ICLOTHING))
		if(istype(user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL),/obj/item/organ/external/tail/cetanoid)) //do we have a cetanoid tail?
			var/obj/item/organ/external/tail/cetanoid/tail = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
			tail.no_suit = FALSE //no swimming for you bozo

		if(user.dna.species.id == SPECIES_CETANOID)
			if(!user.get_bodypart(BODY_ZONE_L_LEG))
				if(!stored_l_leg)
					var/obj/item/bodypart/leg/leg = new /obj/item/bodypart/leg/left/robot/digitigrade()
					leg.try_attach_limb(user)
				else
					stored_l_leg.try_attach_limb(user)

			if(!user.get_bodypart(BODY_ZONE_R_LEG))
				if(!stored_r_leg)
					var/obj/item/bodypart/leg/leg = new /obj/item/bodypart/leg/right/robot/digitigrade()
					leg.try_attach_limb(user)
				else
					stored_r_leg.try_attach_limb(user)
		else
			worn_icon = null

/obj/item/clothing/accessory/cetanoid_legs/on_uniform_dropped(obj/item/clothing/under/source, mob/living/carbon/user)
	. = ..()
	if(istype(user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL),/obj/item/organ/external/tail/cetanoid)) //do we have a cetanoid tail?
		var/obj/item/organ/external/tail/cetanoid/tail = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
		tail.no_suit = TRUE //yay we can swim fast

	if(user.dna.species.id == SPECIES_CETANOID)
		if(user.get_bodypart(BODY_ZONE_L_LEG))
			var/obj/item/bodypart/leg/left/target = user.get_bodypart(BODY_ZONE_L_LEG)
			if(istype(target,/obj/item/bodypart/leg/left/robot/digitigrade)) //if we have a non-digitigrade robot leg, don't store it!
				target.drop_limb()
				target.forceMove(src)
				stored_l_leg = target
		if(user.get_bodypart(BODY_ZONE_R_LEG))
			var/obj/item/bodypart/leg/right/target = user.get_bodypart(BODY_ZONE_R_LEG)
			if(istype(target,/obj/item/bodypart/leg/right/robot/digitigrade)) //if we have a non-digitigrade robot leg, don't store it!
				target.drop_limb()
				target.forceMove(src)
				stored_r_leg = target

	worn_icon = 'monkestation/icons/mob/clothing/accessories/cetanoid_legs.dmi'

/obj/item/clothing/accessory/cetanoid_legs/command/captain
	icon_state = "gold"

/obj/item/clothing/accessory/cetanoid_legs/command
	overlay_color = COLOR_COMMAND_BLUE

/obj/item/clothing/accessory/cetanoid_legs/security
	overlay_color = COLOR_SECURITY_RED

/obj/item/clothing/accessory/cetanoid_legs/cargo
	overlay_color = COLOR_CARGO_BROWN

/obj/item/clothing/accessory/cetanoid_legs/engineering
	overlay_color = COLOR_ENGINEERING_ORANGE

/obj/item/clothing/accessory/cetanoid_legs/science
	overlay_color = COLOR_SCIENCE_PINK

/obj/item/clothing/accessory/cetanoid_legs/medical
	overlay_color = COLOR_MEDICAL_BLUE

/obj/item/clothing/accessory/cetanoid_legs/service
	overlay_color = COLOR_SERVICE_LIME
