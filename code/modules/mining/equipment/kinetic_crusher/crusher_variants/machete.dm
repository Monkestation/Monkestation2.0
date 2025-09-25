/obj/item/kinetic_crusher/machete
	icon = 'icons/obj/mining.dmi'
	icon_state = "PKMachete"
	inhand_icon_state = "PKMachete0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "PKMachete0"
	name = "proto-kinetic machete"
	desc = "Recent breakthroughs with proto-kinetic technology have led to improved designs for the early proto-kinetic crusher, namely the ability to pack all \
	the same technology into a smaller more portable package. The machete design was chosen as to make a much easier to handle and less cumbersome frame. Of course \
	the smaller package means that the power is not as high as the original crusher design, but the different shell makes it capable of blocking basic attacks."
	force = 15
	block_chance = 25
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	armour_penetration = 0
	armour_ignorance = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("slashes", "cuts", "cleaves", "chops", "swipes")
	attack_verb_simple = list("cleave", "chop", "cut", "swipe", "slash")
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = NONE
	light_system = OVERLAY_LIGHT
	light_outer_range = 5
	light_on = FALSE
	charged = TRUE
	charge_time = 10
	detonation_damage = 35
	backstab_bonus = 20
	overrides_main = TRUE
	overrides_twohandrequired = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 15
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/machete/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 4 SECONDS, \
		effectiveness = 130, \
	)
