/obj/item/radio/headset/headset_cent/impostorsr
	keyslot2 = null

/obj/item/radio/headset/chameleon/advanced
	special_desc = "A chameleon headset employed by the Syndicate in infiltration operations. \
	This particular model features flashbang protection, and the ability to amplify your volume."
	command = TRUE
	freerange = TRUE

/obj/item/radio/headset/chameleon/advanced/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/clothing/head/pizza
	name = "dogginos manager hat"
	desc = "Looks like something a Sol general would wear."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head.dmi'
	icon_state = "dominosleader"
