/obj/item/smithed_part/weapon_part/staff_head
	icon_state = "staffhead"
	base_name = "staff head"
	weapon_name = "staff"

	finished_desc = "A smithed staff. Only deals stamina damage, but capable of blocking hits."

	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "staff-hilt"
	worn_icon = 'icons/modules/smithing/forge_weapon_worn.dmi'
	worn_icon_state = "staff_back"

/obj/item/smithed_part/weapon_part/staff_head/finish_weapon()
	damtype = STAMINA

	AddComponent(/datum/component/multi_hit, icon_state = "swipe", width = 3, continues_travel = TRUE)

	wound_bonus = -20 //no

	block_chance = floor(((material_stats.hardness + material_stats.density)/10) * (smithed_quality/100))

	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK

	attack_speed = CLICK_CD_LARGE_WEAPON

	force = floor(((material_stats.density + material_stats.hardness) / 8) * (smithed_quality * 0.01))
	wield_force = force * 1.75 //You get hit with a metal fucking club
	unwield_force = force

	throwforce = force * 0.1 // good luck whipping a staff at something
	w_class = WEIGHT_CLASS_HUGE
	..()

	AddComponent(/datum/component/two_handed, \
		force_unwielded=unwield_force, \
		force_wielded=wield_force, \
		wield_callback=CALLBACK(src,TYPE_PROC_REF(/obj/item/smithed_part/weapon_part/staff_head,wield_callback),src), \
		unwield_callback=CALLBACK(src,TYPE_PROC_REF(/obj/item/smithed_part/weapon_part/staff_head,unwield_callback),src), \
	)

/obj/item/smithed_part/weapon_part/staff_head/proc/wield_callback(obj/item/parent)
	parent.reach = 2

/obj/item/smithed_part/weapon_part/staff_head/proc/unwield_callback(obj/item/parent)
	parent.reach = 1
