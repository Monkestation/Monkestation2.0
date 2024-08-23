/obj/structure/closet/crate/coffin/sandstonesarcophagus
	name = "sandstone sarcophagus"
	desc = "It's a burial receptacle for the dearly departed. A sARcophaGUS, it usually contains a caDaVER."
	icon = 'monkestation/icons/obj/sandstone_structures.dmi'
	icon_state = "sarcophagus"
	resistance_flags = FIRE_PROOF
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/mineral/sandstone
	material_drop_amount = 8
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	can_install_electronics = FALSE

/obj/structure/closet/crate/engineering/meteor_shields
	name = "Hard-Kill Meteor Protection Satellites"
	desc = "Contains a 5 pack of HK-MPS capsules, which can be deployed into a full meteor defense satellite."
	var/spawn_amt = 5

/obj/structure/closet/crate/engineering/meteor_shields/PopulateContents()
	. = ..()
	for(var/i in 1 to spawn_amt)
		new /obj/item/meteor_shield_capsule(src)
