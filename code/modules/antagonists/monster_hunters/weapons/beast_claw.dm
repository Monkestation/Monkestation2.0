/obj/item/melee/trick_weapon/beast_claw
	name = "\improper Beast Claw"
	desc = "The bones seem to still be twitching."
	ui_desc = "A claw made from the bones of monster. It can be transformed into a heavier, more wound-inducing version."
	icon_state = "beast_claw"
	base_icon_state = "beast_claw"
	w_class =  WEIGHT_CLASS_SMALL
	block_chance = 20
	force = 18
	on_force = 23
	throwforce = 10
	wound_bonus = 25
	bare_wound_bonus = 35
	demolition_mod = 1.5 //ripping through doors and windows should be a little easier with a claw shouldnt it?
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/fwoosh.ogg'
	damtype = BRUTE //why can i not make things do wounds i want
	attack_verb_continuous = list("rips", "claws", "gashes", "tears", "lacerates", "dices", "cuts", "attacks")
	attack_verb_simple = list("rip", "claw", "gash", "tear", "lacerate", "dice", "cut", "attack" )

/obj/item/melee/trick_weapon/beast_claw/apply_transform_component()
	AddComponent(/datum/component/transforming, \
		force_on = on_force, \
		w_class_on = WEIGHT_CLASS_BULKY, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/trick_weapon/beast_claw/on_transform(obj/item/source, mob/user, active)
	. = ..()
	balloon_alert(user, active ? "extended" : "collapsed")
	if(active)
		playsound(src, 'sound/weapons/fwoosh.ogg', vol = 50)
	wound_bonus = enabled ? 45 : initial(wound_bonus)
	return COMPONENT_NO_DEFAULT_MESSAGE
