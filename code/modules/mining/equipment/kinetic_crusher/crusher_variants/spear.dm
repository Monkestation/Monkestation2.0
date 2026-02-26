/obj/item/kinetic_crusher/spear
	icon = 'icons/obj/mining.dmi'
	icon_state = "PKSpear"
	inhand_icon_state = "PKSpear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	worn_icon = 'icons/mob/clothing/back.dmi'
	worn_icon_state = "PKSpear0"
	name = "proto-kinetic spear"
	desc = "Having finally invested in better Proto-kinetic tech, research and development was able to cobble together this new proto-kinetic weapon. By compacting all the tecnology \
	we were able to fit it all into a spear styled case. No longer will proto-kinetic crushers be for the most skilled and suicidal, but now they will be available to the most cautious \
	paranoid miners, now able to enjoy the (slightly lower) power of a crusher, while maintaining a (barely) minimum safe distance."
	force = 0
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	throwforce = 5
	throw_speed = 4
	armour_penetration = 20
	armour_ignorance = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("pierces", "stabs", "impales", "pokes", "jabs")
	attack_verb_simple = list("imaple", "stab", "pierce", "jab", "poke")
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT
	light_outer_range = 8
	light_on = FALSE
	charged = TRUE
	charge_time = 15
	detonation_damage = 45
	backstab_bonus = 20
	reach = 2
	overrides_main = TRUE
	overrides_twohandrequired = FALSE
	override_twohandedsprite = TRUE
	force_wielded = 15
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)
	AddComponent(/datum/component/butchering, \
		speed = 6 SECONDS, \
		effectiveness = 90, \
	)

/obj/item/kinetic_crusher/spear/update_icon_state()
	inhand_icon_state = "PKSpear[HAS_TRAIT(src, TRAIT_WIELDED)]" // this is not icon_state and not supported by 2hcomponent
	return ..()
