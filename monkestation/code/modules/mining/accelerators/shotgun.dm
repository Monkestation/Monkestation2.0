/// Caliber used by Ballistic Kinetic weapons for miners (More specifically the proto shotgun)
#define MINER_SHOTGUN "kinetic shotgun"

/obj/item/gun/ballistic/shotgun/doublebarrel/kinetic //FIX ALL THE DESCRIPTIONS BEFORE YOU PUT THIS UP AT ALL RAHHHGGGGG
	name = "Kinetic Boomstick"
	desc = "An advanced re-design of the old Proto-Kinetic Shotgun, this model utalizes the same partial ballistic and kinetic acceleration technology in the Proto-Kinetic SMG but to a much more devestating degree. \
	While it still has the same problems as the PKSMG (No mod capacity, limited ammo) the PKShotgun features devestating firepower, and offers no compramise to any fauna that stands in its way. Rumor has it the \
	Mining Research Director designed this to execute a dissident researcher at a pizza party. <b> Does NOT fit standard 12 gauge shells! Shells tend to get jammed when fired, so you must eject both shells before reloading.</b>"
	icon_state = "protokshotgun"
	inhand_icon_state = "protokshotgun"
	worn_icon_state = "protokshotgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	recoil = 3
	force = 20
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	armour_penetration = 0
	pin = /obj/item/firing_pin/wastes //yes this is required, do NOT remove it
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
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
	desc = "A 12 gauge Shell loaded with magnum kinetic projectiles. Penetrates rocky walls and creatures! <b> Does NOT fit in any standard 12 gauge shotgun! </b>"
	icon_state = "shellproto"
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	caliber = MINER_SHOTGUN
	pellets = 5
	variance = 30
	projectile_type = /obj/projectile/plasma/kineticshotgun

/obj/item/ammo_casing/shotgun/kinetic/sniperslug //slugs essentially
	name = "Kinetic .50 BMG"
	desc = "If god did not want us to put 50 BMG in a 12 gauge, he would not have given them similar diameter! A incredibly large 50 BMG round adapted into a kinetic slug. Does not penetrate targets like Magnum Kinetic Buckshot, but still penetrates rock walls. <b> Does NOT fit in any standard 12 gauge shotgun! </b>"
	icon_state = "slugbmg"
	pellets = 1
	variance = 5
	projectile_type = /obj/projectile/plasma/kineticshotgun/sniperslug


/obj/item/ammo_casing/shotgun/kinetic/rockbreaker //for digging!
	name = "Kinetic Rockbreaker Shell"
	desc = "A 12 gauge Shell loaded with dozens of special tiny kinetic rockbreaker pellets, perfect for clearing masses of rocks but no good for killing fauna. <b> Does NOT fit in any standard 12 gauge shotgun! </b>"
	icon_state = "bountyshell"
	caliber = MINER_SHOTGUN
	pellets = 10
	variance = 120
	projectile_type = /obj/projectile/plasma/kineticshotgun/rockbreaker

/obj/projectile/plasma/kineticshotgun //subtype of plasma instead of kinetic so it can punch through mineable turf. Cant be used off of lavaland or off the wastes of icemoon anyways so...
	name = "magnum kinetic projectile"
	icon_state = "cryoshot"
	damage_type = BRUTE
	armor_flag = BOMB
	damage = 35  //totals 175 damage letting them reach the breakpoint for watcher HP so it one shots them
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
	desc = "A box that can hold up to ten shells of Magnum Kinetic Buckshot for the PKShotgun. Fits inside of explorer webbings."
	icon_state = "protoshell_box"
	illustration = "protoshell_box"

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
	desc = "A box designed to hold up to ten shells of 50 BMG Slugs for the PKShotgun. Fits inside of explorer webbings."
	icon_state = "bmgshell_box"
	illustration = "bmgshell_box"

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
	desc = "A box for holding up to twenty shells of Rockbreaker for the PKShotgun. Surprisingly fits inside of explorer webbings."
	icon = 'icons/obj/storage/toolbox.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "ammobox"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

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

/obj/item/storage/box/kinetic/shotgun/bigcase //box
	name = "Kinetic Shotgun Case"
	desc = "A special and totally original gun case that contains a PKShotgun, eight shells of Rockbreaker, and four shells of Magnum Kinetic Buckshot. Beware, they dont fit back inside once taken out for some reason."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "miner_case"
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/shotgun/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 13
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 13
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/shotgun/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/shotgun/doublebarrel/kinetic(src) //the shotgun
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src) //fuck it we do a little bit of bad code :)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src) //8 shells of rockbreaker
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic/rockbreaker(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src) //4 shells of kinetic buckshot
		new /obj/item/ammo_casing/shotgun/kinetic(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src)
		new /obj/item/ammo_casing/shotgun/kinetic(src)
