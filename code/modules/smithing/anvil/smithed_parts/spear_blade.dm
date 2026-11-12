/obj/item/smithed_part/weapon_part/spear_blade
	icon_state = "spearhead"
	base_name = "spear blade"
	weapon_name = "spear"

	finished_desc = "A forged spear, good reach when wielded. Likely to embed if thrown."

	weapon_inhand_icon_state = "spear"
	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "spear-hilt"
	worn_icon = 'icons/modules/smithing/forge_weapon_worn.dmi'
	worn_icon_state = "spear_back"



/obj/item/smithed_part/weapon_part/spear_blade/finish_weapon()
	sharpness = SHARP_POINTY
	embed_type = /datum/embedding/spear_blade
	armour_penetration = 40 * (smithed_quality / 100)

	force = floor(((material_stats.density + material_stats.hardness) / 9) * (smithed_quality * 0.01))
	wield_force = floor(force * 1.25)
	unwield_force = force
	throwforce = force * 1.25

	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK

	w_class = WEIGHT_CLASS_BULKY

	..()

	AddComponent(/datum/component/multi_hit, icon_state = "stab", height = 2)
	AddComponent(/datum/component/two_handed, \
		force_unwielded=unwield_force, \
		force_wielded=wield_force, \
		wield_callback=CALLBACK(src,TYPE_PROC_REF(/obj/item/smithed_part/weapon_part/spear_blade,wield_callback),src), \
		unwield_callback=CALLBACK(src,TYPE_PROC_REF(/obj/item/smithed_part/weapon_part/spear_blade,unwield_callback),src), \
	)

/obj/item/smithed_part/weapon_part/spear_blade/proc/wield_callback(obj/item/parent)
	parent.reach = 2

/obj/item/smithed_part/weapon_part/spear_blade/proc/unwield_callback(obj/item/parent)
	parent.reach = 1

/datum/embedding/spear_blade
	embed_chance = 65
	impact_pain_mult = 2
	remove_pain_mult = 4
	fall_chance = 10
	ignore_throwspeed_threshold = TRUE

