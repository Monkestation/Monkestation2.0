/obj/item/clothing/suit/cetanoid_suit
	name = "\improper cybernetic suit"
	desc = "A cybernetic suit used by Cetanoids to walk and breath."
	icon = 'icons/obj/clothing/suits/spacesuit.dmi' //using spacesuit.dmi as placeholder sprite
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	worn_icon_digitigrade = 'monkestation/icons/mob/clothing/species/suit_digi.dmi'
	icon_state = "space"
	inhand_icon_state = "s_suit"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/cetanoid_suit/equipped(var/mob/living/carbon/human/wearer, slot)
	. = ..()
	if((slot & ITEM_SLOT_OCLOTHING))
		if(istype(wearer.get_organ_slot(ORGAN_SLOT_LUNGS),/obj/item/organ/internal/lungs/cetanoid)) //do we have cetanoid lungs?
			var/obj/item/organ/internal/lungs/cetanoid/lungs = wearer.get_organ_slot(ORGAN_SLOT_LUNGS)
			lungs.suffocating = FALSE //yay we can breathe

		if(wearer.dna.species.id == SPECIES_CETANOID)
			if(!wearer.get_bodypart(BODY_ZONE_L_LEG))
				var/obj/item/bodypart/leg/leg = new /obj/item/bodypart/leg/left/robot/digitigrade()
				if(!leg.try_attach_limb(wearer))
					QDEL_NULL(leg) //delete the leg if we cant attach it

			if(!wearer.get_bodypart(BODY_ZONE_R_LEG))
				var/obj/item/bodypart/leg/leg = new /obj/item/bodypart/leg/right/robot/digitigrade()
				if(!leg.try_attach_limb(wearer))
					QDEL_NULL(leg) //delete the leg if we cant attach it


/obj/item/clothing/suit/cetanoid_suit/dropped(var/mob/living/carbon/human/wearer)
	. = ..()
	if(istype(wearer.get_organ_slot(ORGAN_SLOT_LUNGS),/obj/item/organ/internal/lungs/cetanoid)) //do we have cetanoid lungs?
		var/obj/item/organ/internal/lungs/cetanoid/lungs = wearer.get_organ_slot(ORGAN_SLOT_LUNGS)
		lungs.suffocating = TRUE //uh oh no suit you're dying

	if(wearer.dna.species.id == SPECIES_CETANOID)
		if(wearer.get_bodypart(BODY_ZONE_L_LEG))
			var/obj/item/bodypart/leg/left/target = wearer.get_bodypart(BODY_ZONE_L_LEG)
			if(istype(target,/obj/item/bodypart/leg/left/robot/digitigrade)) //if we have a non-digitigrade robot leg, don't delete it!
				QDEL_NULL(target) //no suit, no legs
		if(wearer.get_bodypart(BODY_ZONE_R_LEG))
			var/obj/item/bodypart/leg/right/target = wearer.get_bodypart(BODY_ZONE_R_LEG)
			if(istype(target,/obj/item/bodypart/leg/right/robot/digitigrade)) //if we have a non-digitigrade robot leg, don't delete it!
				QDEL_NULL(target) //no suit, no legs
