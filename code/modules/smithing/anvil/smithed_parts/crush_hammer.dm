/obj/item/smithed_part/weapon_part/crush_hammer
	icon_state = "hammerhead"
	base_name = "crush-hammer head"
	weapon_name = "crush-hammer"

	finished_desc = "A forged two handed hammer. Bulky, but hits very hard."

	weapon_inhand_icon_state = "crush_hammer"
	hilt_icon = 'code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "hammer-hilt"
	worn_icon = 'code/modules/smithing/icons/forge_weapon_worn.dmi'
	worn_icon_state = "hammer_back"

/obj/item/smithed_part/weapon_part/crush_hammer/finish_weapon()
	wound_bonus = 20
	armour_penetration = 60 * (smithed_quality / 100)

	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK

	attack_speed = CLICK_CD_BULKY_WEAPON

	force = round(((material_stats.density + material_stats.hardness) / 7) * (smithed_quality * 0.01))
	throwforce = round(force * 0.5)

	unwield_force = round(force * 0.75)
	wield_force = force

	AddComponent(/datum/component/two_handed, \
		force_unwielded=unwield_force, \
		force_wielded=wield_force, \
	)
	w_class = WEIGHT_CLASS_BULKY
	..()
