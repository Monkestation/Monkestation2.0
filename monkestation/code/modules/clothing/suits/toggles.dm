//for making masks
//this is some of the worst code i've seen i don't even want to save it, i just want it to stop harddeleting
/obj/item/clothing/suit/armor/secduster/Initialize(mapload)
	MakeMask()
	return ..()

/obj/item/clothing/suit/armor/secduster/Destroy()
	if(!QDELETED(mask))
		mask.suit = null
	mask = null
	return ..()

/obj/item/clothing/mask/breath/sec_bandana/dropped(mob/living/user)
	if(suit)
		suit.mask = null
		user?.update_action_buttons()
	return ..()

/obj/item/clothing/suit/armor/secduster/proc/MakeMask()
	if(!masktype)
		return
	if(!mask)
		var/obj/item/clothing/mask/breath/sec_bandana/W = new masktype(src)
		W.suit = src
		mask = W

/obj/item/clothing/suit/armor/secduster/ui_action_click(mob/user, actiontype)
	. = ..()
	ToggleMask(user)

/obj/item/clothing/suit/armor/secduster/equipped(mob/user, slot)
	if(!masktype)
		return
	if(!(slot & ITEM_SLOT_OCLOTHING))
		RemoveMask(user)
	return ..()

/obj/item/clothing/suit/armor/secduster/proc/RemoveMask(mob/user)
	if(!mask)
		return
	suittoggled = FALSE
	if(!ishuman(mask.loc))
		return
	var/mob/living/carbon/H = mask.loc
	H.transferItemToLoc(mask, src, TRUE)
	H.update_worn_oversuit()
	to_chat(H, "<span class='notice'>You pull down the bandana.</span>")
	playsound(src.loc, 'sound/items/handling/cloth_drop.ogg', 50, 1)
	user.update_action_buttons()


/obj/item/clothing/suit/armor/secduster/dropped(mob/living/user)
	. = ..()
	if(!QDELETED(user))
		RemoveMask(user)

/obj/item/clothing/suit/armor/secduster/proc/ToggleMask(mob/user)
	var/mob/living/carbon/human/H = src.loc
	if(!masktype)
		return
	if(!mask)
		return
	if(suittoggled)
		RemoveMask(user)
		return
	if(!ishuman(H))
		return
	if(H.wear_suit != src)
		to_chat(H, "<span class='warning'>You must be wearing [src] to toggle the bandana!</span>")
		return
	if(H.wear_mask)
		to_chat(H, "<span class='warning'>You're already wearing something on your face!</span>")
		return
	else if(H.equip_to_slot_if_possible(mask,ITEM_SLOT_MASK,0,0,1))
		to_chat(H, "<span class='notice'>You pull up the bandana over your face.</span>")
		suittoggled = TRUE
		H.update_worn_oversuit()
		playsound(H, 'sound/items/handling/cloth_drop.ogg', 50, 1)
