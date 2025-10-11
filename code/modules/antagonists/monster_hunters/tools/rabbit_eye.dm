/obj/item/rabbit_eye
	name = "Rabbit Eye"
	desc = "An item that resonates with trick weapons."
	icon_state = "rabbit_eye"
	icon = 'monkestation/icons/obj/items/monster_hunter.dmi'
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/rabbit_eye/proc/upgrade(obj/item/melee/trick_weapon/weapon, mob/user)
	if(weapon.upgrade_level >= 3)
		user.balloon_alert(user, "already fully upgraded!")
		return
	weapon.upgrade_weapon()
	balloon_alert(user, "[src] crumbles away...")
	playsound(src, 'monkestation/sound/effects/weaponsmithing.ogg', vol = 50)
	qdel(src)
