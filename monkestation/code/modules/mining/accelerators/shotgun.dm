
/// Caliber used by Ballistic Kinetic weapons for miners (More specifically the proto shotgun)
#define MINER_SHOTGUN "kinetic shotgun"

/obj/item/gun/ballistic/shotgun/doublebarrel/kinetic //FIX ALL THE DESCRIPTIONS BEFORE YOU PUT THIS UP AT ALL RAHHHGGGGG
	name = "Kinetic Boomstick"
	desc = "A true classic with a miner twist."
	icon_state = "dshotgun"
	inhand_icon_state = "shotgun_db"
	worn_icon_state = ""
	recoil = 3
	force = 20
	armour_penetration = 5
	pin = /obj/item/firing_pin/wastes //yes this is required, do NOT remove it
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	fire_sound = 'monkestation/code/modules/blueshift/sounds/shotgun_heavy.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/dual/kinetic
	unique_reskin = list()
	can_be_sawn_off = FALSE
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("slashes", "cuts", "cleaves", "chops", "swipes")
	attack_verb_simple = list("cleave", "chop", "cut", "swipe", "slash")
	pb_knockback = 0 //you may have your point blank, but you dont get a fling

/obj/item/ammo_box/magazine/internal/shot/dual/kinetic
	name = "kinetic double barrel shotgun internal magazine"
	desc = "how did you break my gun like this, please report whatever you did then feel bad!!!"
	ammo_type = /obj/item/ammo_casing/shotgun/kinetic
	caliber = MINER_SHOTGUN
	max_ammo = 2

//You cant just pry these shells out with your fingers, youll have to eject them by breaking open the shotgun
/obj/item/ammo_box/magazine/internal/shot/dual/kinetic/give_round(obj/item/ammo_casing/R)
	if(!R || !(caliber ? (caliber == R.caliber) : (ammo_type == R.type)))
		return FALSE

	else if (stored_ammo.len < max_ammo)
		stored_ammo += R
		R.forceMove(src)
		return TRUE
	return FALSE

/obj/item/ammo_casing/shotgun/kinetic //for slaying, works on crowds
	name = "Kinetic Magnum Buckshot Shell"
	desc = "A 12 gauge Shell loaded with kinetic projectiles."
	icon_state = "heshell"
	worn_icon_state = ""
	caliber = MINER_SHOTGUN
	pellets = 5
	variance = 30
	projectile_type = /obj/projectile/plasma/kineticshotgun

/obj/item/ammo_casing/shotgun/kinetic/sniperslug //slugs essentially
	name = "Kinetic .50 BMG"
	desc = "If god did not want us to put 50 BMG in a 12 gauge, he would not have given them similar diameter!"
	icon_state = "stunshell"
	pellets = 1
	variance = 5
	projectile_type = /obj/projectile/plasma/kineticshotgun/sniperslug


/obj/item/ammo_casing/shotgun/kinetic/rockbreaker //for digging!
	name = "Kinetic Rockbreaker Shell"
	desc = "A 12 gauge Shell loaded with dozens of special tiny kinetic rockbreaker pellets, perfect for clearing masses of rocks but no good for killing fauna."
	icon_state = "bountyshell"
	worn_icon_state = ""
	caliber = MINER_SHOTGUN
	pellets = 10
	variance = 120
	projectile_type = /obj/projectile/plasma/kineticshotgun/rockbreaker

/obj/projectile/plasma/kineticshotgun //subtype of plasma instead of kinetic so it can punch through mineable turf. Cant be used off of lavaland or off the wastes of icemoon anyways so...
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
	name = ".50 BMG kinetic"
	speed = 0.4
	damage = 150
	range = 10
	icon_state = "gaussstrong"
	projectile_piercing = NONE

/obj/projectile/plasma/kineticshotgun/rockbreaker // for breaking rocks
	name = "kinetic rockbreaker"
	speed = 1 //slower than average
	damage = 2
	range = 13
	icon_state = "guardian"
	projectile_piercing = NONE

/obj/item/storage/box/kinetic/shotgun //box
	name = "box of kinetic shells"
	desc = ""
	icon_state = "rubbershot_box"
	illustration = "rubbershot_box"

/obj/item/storage/box/kinetic/shotgun/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic,
	))

/obj/item/storage/box/kinetic/shotgun/PopulateContents() //populate
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic(src)

/obj/item/storage/box/kinetic/shotgun/sniperslug //box
	name = "box of .50 BMG Kinetic"
	desc = ""
	icon_state = "rubbershot_box"
	illustration = "rubbershot_box"

/obj/item/storage/box/kinetic/shotgun/sniperslug/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 10
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic/sniperslug,
	))

/obj/item/storage/box/kinetic/shotgun/sniperslug/PopulateContents() //populate
	for(var/i in 1 to 10)
		new /obj/item/ammo_casing/shotgun/kinetic/sniperslug(src)

/obj/item/storage/box/kinetic/shotgun/rockbreaker //box
	name = "box of kinetic rock breaker"
	desc = ""
	icon_state = "rubbershot_box"
	illustration = "rubbershot_box"

/obj/item/storage/box/kinetic/shotgun/rockbreaker/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 20
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun/kinetic/rockbreaker,
	))

/obj/item/storage/box/kinetic/shotgun/rockbreaker/PopulateContents() //populate
	for(var/i in 1 to 20)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
