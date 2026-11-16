/obj/item/smithed_part/weapon_part/pickaxe_head
	icon_state = "pickaxehead"
	base_name = "pickaxe head"
	worn_icon = 'icons/modules/smithing/forge_weapon_worn.dmi'
	weapon_name = "pickaxe"
	weapon_inhand_icon_state = "pickaxe"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	hilt_icon = 'icons/modules/smithing/forge_items.dmi'
	hilt_icon_state = "pickaxe-hilt"

	finished_desc = "A forged pickaxe. Diggin' time."

/obj/item/smithed_part/weapon_part/pickaxe_head/finish_weapon()
	tool_behaviour = TOOL_MINING

	usesound = list('sound/effects/pickaxe/picaxe1.ogg', 'sound/effects/pickaxe/picaxe2.ogg', 'sound/effects/pickaxe/picaxe3.ogg')
	attack_verb_continuous = list("hits", "pierces", "slices", "attacks")
	attack_verb_simple = list("hit", "pierce", "slice", "attack")

	toolspeed = 1 / max(floor(((material_stats.density + material_stats.hardness) / 25) * (smithed_quality * 0.01)),1)
	force = floor(((material_stats.density + material_stats.hardness) / 20) * (smithed_quality * 0.01))

	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	throwforce = force * 1.5
	w_class = WEIGHT_CLASS_NORMAL
	..()
