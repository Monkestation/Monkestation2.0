/obj/item/clothing/head/fish_bowl
	name = "\improper fish bowl helmet"
	desc = "A fish bowl helmet worn by Cetanoids."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "fishbowl"

/obj/item/clothing/head/fish_bowl/equipped(var/mob/living/carbon/human/wearer, slot)
	. = ..()
	if((slot & ITEM_SLOT_HEAD))
		if(istype(wearer.get_organ_slot(ORGAN_SLOT_LUNGS),/obj/item/organ/internal/lungs/cetanoid)) //do we have cetanoid lungs?
			var/obj/item/organ/internal/lungs/cetanoid/lungs = wearer.get_organ_slot(ORGAN_SLOT_LUNGS)
			lungs.no_helmet = FALSE //yay we can breathe

/obj/item/clothing/head/fish_bowl/dropped(var/mob/living/carbon/human/wearer)
	. = ..()
	if(istype(wearer.get_organ_slot(ORGAN_SLOT_LUNGS),/obj/item/organ/internal/lungs/cetanoid)) //do we have cetanoid lungs?
		var/obj/item/organ/internal/lungs/cetanoid/lungs = wearer.get_organ_slot(ORGAN_SLOT_LUNGS)
		lungs.no_helmet = TRUE //uh oh no helmet you're dying
