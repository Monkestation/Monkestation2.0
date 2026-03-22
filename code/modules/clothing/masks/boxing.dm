/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY"
	icon_state = "balaclava"
	inhand_icon_state = "balaclava"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/adjust)
	alternate_worn_layer = UNDER_SUIT_LAYER //monkestation edit

/obj/item/clothing/mask/balaclava/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/luchador
	name = "Luchador Mask"
	desc = "Worn by robust fighters, flying high to defeat their foes!"
	icon_state = "luchag"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/head/frenchberet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("luchador_replacement.json", "luchador"), end_string = " OLE!", end_string_chance = 25, uppercase = TRUE, slots = ITEM_SLOT_MASK)

/obj/item/clothing/mask/luchador/tecnicos
	name = "Tecnicos Mask"
	desc = "Worn by robust fighters who uphold justice and fight honorably."
	icon_state = "luchador"

/obj/item/clothing/mask/luchador/rudos
	name = "Rudos Mask"
	desc = "Worn by robust fighters who are willing to do anything to win."
	icon_state = "luchar"

/obj/item/clothing/mask/thermal_balaclava
	name = "thermal balaclava"
	desc = "Protects your face from the cold."
	worn_icon = 'icons/mob/clothing/mask.dmi'
	icon_state = "rus_balaclava"
	worn_icon_state = "rus_balaclava"
	inhand_icon_state = "balaclava"
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_NECK
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	alternate_worn_layer = UNDER_SUIT_LAYER
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
