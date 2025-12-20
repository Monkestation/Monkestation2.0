/obj/item/clothing/head/earmuffs
	name = "earmuffs"
	desc = "Goes on your head, and protects your hearing from loud noises while slowly healing your ears."
	icon = 'icons/obj/clothing/ears.dmi'
	worn_icon = 'icons/mob/clothing/ears.dmi'
	icon_state = "earmuffs"
	inhand_icon_state = "earmuffs"
	strip_delay = 15
	equip_delay_other = 25
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_COMMAND * 1.5

/obj/item/clothing/head/earmuffs/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/earhealing)
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_HEAD))

/obj/item/clothing/head/earmuffs/debug
	name = "debug earmuffs"
	desc = "Wearing these sends a chat message for every sound played. Walking to ignore footsteps is highly recommended."
	clothing_traits = list(TRAIT_SOUND_DEBUGGED)
