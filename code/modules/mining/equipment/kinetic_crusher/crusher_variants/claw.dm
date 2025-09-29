/obj/item/kinetic_crusher/claw
	icon = 'icons/obj/mining.dmi'
	icon_state = "PKClaw"
	inhand_icon_state = "PKClaw0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = NONE
	name = "proto-kinetic claws"
	desc = "Truely the most compact version of the crusher ever made, its small enough to fit in your backpack and still function as a crusher. \
	Best used when attacking from behind, rewarding those capable of landing what we call a 'critical hit' \
	(DISCLAIMER) The shell is made to fit over gloves, so dont try to wear it like a glove."
	force = 5
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 4
	armour_penetration = 0
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/pierce.ogg'
	attack_verb_continuous = list("swipes", "slashes", "cuts", "slaps")
	attack_verb_simple = list("swipe", "slash", "cut", "slap")
	sharpness = SHARP_POINTY
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT
	light_outer_range = 4
	light_on = FALSE
	charged = TRUE
	charge_time = 2
	detonation_damage = 40
	backstab_bonus = 120
	overrides_main = TRUE
	overrides_twohandrequired = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 5
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/claw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 5 SECONDS, \
		effectiveness = 100, \
	)
