
GLOBAL_LIST_INIT(balaclava_options, list(
	"Lift" = "balaclava1_up",
	"Tight" = "balaclava1",
	"Loose" = "balaclava2",
	"Open" = "balaclava3",
))

/obj/item/clothing/mask/balaclava
	name = "balaclava"
	desc = "LOADSAMONEY"
	worn_icon = 'icons/mob/clothing/mask.dmi'
	icon_state = "balaclava1"
	inhand_icon_state = "balaclava"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	slot_flags = ITEM_SLOT_MASK | ITEM_SLOT_NECK
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/adjust)
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/adjust)
	alternate_worn_layer = UNDER_SUIT_LAYER
	var/list/balaclava_designs = list()

/obj/item/clothing/mask/balaclava/Initialize(mapload)
	. = ..()
	balaclava_designs = list(
		"Lift" = image(icon = src.icon, icon_state = "balaclava1_up"),
		"Tight" = image(icon = src.icon, icon_state = "balaclava1"),
		"Loose" = image(icon = src.icon, icon_state = "balaclava2"),
		"Open" = image(icon = src.icon, icon_state = "balaclava3"),
		)

/obj/item/clothing/mask/balaclava/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/choice = show_radial_menu(user,src, balaclava_designs, custom_check = FALSE, radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE

	if(src && choice && !user.incapacitated() && in_range(user,src))
		var/list/options = GLOB.balaclava_options
		icon_state = options[choice]
		update_item_action_buttons()
		var/handling_text = "adjust"
		switch(choice)
			if("Lift")
				handling_text = "lift up"
				flags_inv &= ~visor_flags_inv
			if("Tight")
				handling_text = "tighten"
				flags_inv |= visor_flags_inv
			if("Loose")
				handling_text = "loosen"
				flags_inv |= visor_flags_inv
			if("Open")
				handling_text = "open"
				flags_inv &= ~visor_flags_inv
		to_chat(user, span_notice("You [handling_text] [src]."))
		user.update_worn_neck()
		user.update_worn_mask()
		if(iscarbon(user))
			var/mob/living/carbon/carbon_user = user
			carbon_user.update_body_parts()
		return TRUE

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
