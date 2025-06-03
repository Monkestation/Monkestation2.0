
/// Caliber used by Ballistic Kinetic weapons for miners (More specifically the proto shotgun)
#define MINER_SHOTGUN "kinetic shotgun"

/obj/item/gun/ballistic/shotgun/doublebarrel/kinetic
	name = "Kinetic Boomstick"
	desc = "A true classic with a miner twist."
	icon_state = "dshotgun"
	inhand_icon_state = "shotgun_db"
	worn_icon_state = ""
	recoil = 4
	pin = /obj/item/firing_pin/wastes //yes this is required, do NOT remove it
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BELT
	fire_sound = 'monkestation/code/modules/blueshift/sounds/shotgun_heavy.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/dual/kinetic
	unique_reskin = list()
	can_be_sawn_off = FALSE

/obj/item/ammo_box/magazine/internal/shot/dual/kinetic
	name = "kinetic double barrel shotgun internal magazine"
	desc = "how did you break my gun like this, please report whatever you did then feel bad!!!"
	ammo_type = /obj/item/ammo_casing/shotgun/kinetic
	caliber = MINER_SHOTGUN
	max_ammo = 2

/obj/item/ammo_casing/shotgun/kinetic
	name = "Kinetic Shell"
	desc = "A 12 gauge Shell loaded with kinetic projectiles."
	icon_state = "heshell"
	worn_icon_state = ""
	caliber = MINER_SHOTGUN
	pellets = 5
	variance = 40
	projectile_type = /obj/projectile/kinetic/shotgun

/obj/item/ammo_casing/shotgun/kinetic/sniperslug
	name = "Kinetic .50 BMG"
	desc = "If god did not want us to put 50 BMG in a 12 gauge, he would not have given them similar diameter!"
	icon_state = "stunshell"
	pellets = 1
	variance = 5
	projectile_type = /obj/projectile/kinetic/shotgun/sniperslug

/obj/projectile/kinetic/shotgun //NEEDS SKILLBASEDWEAPON = FALSE WHEN THE SMG GETS ADDED
	name = "magnum kinetic projectile"
	damage = 30
	range = 7
	icon_state = "cryoshot"
	projectile_piercing = list(PASSMOB)

/obj/projectile/kinetic/shotgun/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer, FALSE)

/obj/projectile/kinetic/shotgun/sniperslug //ALSO NEEDS SKILLBASEDWEAPON = FALSE WHEN THE SMG GETS ADDED
	name = ".50 BMG Kinetic"
	speed = 2
	damage = 150
	range = 10
	icon_state = "gaussstrong"
	projectile_piercing = NONE
