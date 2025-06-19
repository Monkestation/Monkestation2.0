/obj/item/melee/trick_weapon/hunter_axe
	name = "Hunter's Axe"
	desc = "A brute's tool of choice."
	ui_desc = "A simple axe for hunters that lean towards barbarian tactics, can transform into a double bladed axe."
	icon_state = "hunteraxe"
	base_icon_state = "hunteraxe"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	force = 20
	on_force = 25
	throwforce = 12
	reach = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

/obj/item/melee/trick_weapon/hunter_axe/apply_transform_component()
	AddComponent(/datum/component/two_handed, \
		wieldsound = 'sound/magic/clockwork/fellowship_armory.ogg', \
		force_multiplier = (on_force / force), \
		wield_callback = CALLBACK(src, PROC_REF(on_wield_change)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_wield_change)), \
	)

/obj/item/melee/trick_weapon/hunter_axe/proc/on_wield_change()
	enabled = HAS_TRAIT(src, TRAIT_WIELDED)
	block_chance = HAS_TRAIT(src, TRAIT_WIELDED) ? 75 : src::block_chance
	var/current_base_force = HAS_TRAIT(src, TRAIT_WIELDED) ? on_force : initial(on_force)
	force = UPGRADED_VAL(current_base_force, upgrade_level)
