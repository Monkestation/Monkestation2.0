/obj/item/knife/scrimshaw_knife
	name = "enchanted bonecarving knife"
	desc = "A fragile blade used by tribals in the scrimshawing of ritual bones."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "envyknife"
	inhand_icon_state = "envyknife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	custom_materials = list(/datum/material/bone = SMALL_MATERIAL_AMOUNT)

/obj/item/knife/scrimshaw_knife/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	visible_message(span_notice("[src] shatters into pieces!"))
	qdel(src)

/datum/orderable_item/mining/scrimshaw_knife
	item_path = /obj/item/knife/scrimshaw_knife
	cost_per_order = 5000
