
/// Caliber used by Ballistic Kinetic weapons for miners (More specifically the proto shotgun)
#define MINER_SHOTGUN "kinetic shotgun"

/obj/item/gun/ballistic/shotgun/doublebarrel/kinetic //FIX ALL THE DESCRIPTIONS BEFORE YOU PUT THIS UP AT ALL RAHHHGGGGG
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
	projectile_type = /obj/projectile/plasma/kineticshotgun

/obj/item/ammo_casing/shotgun/kinetic/sniperslug
	name = "Kinetic .50 BMG"
	desc = "If god did not want us to put 50 BMG in a 12 gauge, he would not have given them similar diameter!"
	icon_state = "stunshell"
	pellets = 1
	variance = 5
	projectile_type = /obj/projectile/plasma/kineticshotgun/sniperslug

/obj/projectile/kinetic/shotgun
	name = "magnum kinetic projectile"
	damage = 35
	range = 7
	icon_state = "cryoshot"
	projectile_piercing = PASSMOB
	Skillbasedweapon = FALSE

/obj/projectile/plasma/kineticshotgun //subtype of plasma instead of kinetic so it can mine walls. Cant be used off of lavaland or off the wastes of icemoon anyways so...
	name = "magnum kinetic projectile"
	icon_state = "cryoshot"
	damage_type = BRUTE
	armor_flag = BOMB
	damage = 35  //totals 175 damage letting them kill watchers instantly and penetrates targets for crowd controla
	range = 7
	dismemberment = 0
	projectile_piercing = PASSMOB
	impact_effect_type = /obj/effect/temp_visual/kinetic_blast
	mine_range = 1
	tracer_type = ""
	muzzle_type = ""
	impact_type = ""

/obj/projectile/plasma/kineticshotgun/sniperslug // long range but cant hit the oneshot breakpoint of a watcher and does not penetrate targets
	name = ".50 BMG Kinetic"
	speed = 0.4
	damage = 150
	range = 10
	icon_state = "gaussstrong"
	projectile_piercing = NONE

/obj/item/storage/box/kinetic/shotgun
	name = "box of kinetic shells"
	desc = "A box full of kinetic projectile magazines, specifically for the proto-kinetic SMG.\
	It is specially designed to only hold proto-kinetic magazines, and also fit inside of explorer webbing."
	icon_state = "rubbershot_box"
	illustration = "rubbershot_box"

/obj/item/storage/box/kinetic/shotgun/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic,
	))

/obj/item/storage/box/kinetic/shotgun/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic(src)

/obj/item/storage/box/kinetic/shotgun/sniperslug
	name = "box of .50 BMG Kinetic"
	desc = "A box full of kinetic projectile magazines, specifically for the proto-kinetic SMG.\
	It is specially designed to only hold proto-kinetic magazines, and also fit inside of explorer webbing."
	icon_state = "rubbershot_box"
	illustration = "rubbershot_box"

/obj/item/storage/box/kinetic/shotgun/shotgun/sniperslug/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic/shotgun/sniperslug,
	))

/obj/item/storage/box/kinetic/shotgun/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic/shotgun/sniperslug(src)
