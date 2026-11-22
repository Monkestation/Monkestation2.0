/obj/item/smithed_part/weapon_part/tanto
	icon_state = "katanablade"
	base_name = "tanto blade"
	weapon_name = "tanto"

	finished_desc = "A forged tanto, similar to a katana, but shorter for one-handed use."

	weapon_inhand_icon_state = "katana"
	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "katana-hilt"
	worn_icon = 'icons/modules/smithing/forge_weapon_worn.dmi'
	worn_icon_state = "katana_back"

/obj/item/smithed_part/weapon_part/tanto/finish_weapon()
	sharpness = SHARP_EDGED
	wound_bonus = 5
	bare_wound_bonus = 15 //Someone please add a suicide act where you sudoku.
	armour_penetration = 15 * (smithed_quality / 100)


	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT | ITEM_SLOT_BELT

	attack_speed = CLICK_CD_LIGHT_WEAPON

	force = floor(((material_stats.density + material_stats.hardness) / 10.25) * (smithed_quality * 0.01))
	throwforce = floor(force * 0.75)
	w_class = WEIGHT_CLASS_NORMAL
	..()
