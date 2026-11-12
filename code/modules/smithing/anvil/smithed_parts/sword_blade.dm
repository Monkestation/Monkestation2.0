/obj/item/smithed_part/weapon_part/sword_blade
	icon_state = "blade"
	base_name = "sword blade"
	weapon_name = "sword"

	finished_desc = "A forged two handed sword. Bulky, but hits hard."

	weapon_inhand_icon_state = "sword"
	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "blade-hilt"
	worn_icon = 'icons/modules/smithing/forge_weapon_worn.dmi'
	worn_icon_state = "sword_back"

/obj/item/smithed_part/weapon_part/sword_blade/finish_weapon()
	sharpness = SHARP_EDGED
	wound_bonus = 5
	bare_wound_bonus = 15
	armour_penetration = 40 * (smithed_quality / 100)

	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK

	attack_speed = CLICK_CD_LARGE_WEAPON

	force = floor(((material_stats.density + material_stats.hardness) / 7.5) * (smithed_quality * 0.01))
	throwforce = floor(force * 0.7)

	unwield_force = floor(force * 0.75)
	wield_force = force

	w_class = WEIGHT_CLASS_BULKY
	..()

	AddComponent(/datum/component/two_handed, \
		force_unwielded=unwield_force, \
		force_wielded=wield_force, \
	)
