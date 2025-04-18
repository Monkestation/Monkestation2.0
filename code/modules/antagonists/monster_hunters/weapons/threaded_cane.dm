/obj/item/melee/trick_weapon/threaded_cane
	name = "Threaded Cane"
	desc = "A blind man's whip."
	ui_desc = "A cane made out of heavy metal, can transform into a whip to strike foes from afar."
	icon_state = "threaded_cane"
	icon_state_preview = "threaded_cane_active"
	base_icon_state = "threaded_cane"
	inhand_icon_state = "threaded_cane"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	on_force = 15
	force = 18
	throwforce = 12
	active_thrown_force = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

/obj/item/melee/trick_weapon/threaded_cane/on_transform(obj/item/source, mob/user, active)
	. = ..()
	balloon_alert(user, active ? "extended" : "collapsed")
	if(active)
		playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', vol = 50)
	reach = active ? 2 : 1
	return COMPONENT_NO_DEFAULT_MESSAGE
