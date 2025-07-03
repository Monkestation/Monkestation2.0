
/obj/item/gun/ballistic/automatic/proto/pksmg
	name = "proto-kinetic smg"
	desc = "Using partial ballistic technology and kinetic acceleration, the Mining Research department has managed to make the kinetic accelerator full auto. \
	While the technology is promising, it is held back by certain factors, specifically limited ammo and no mod capacity, but that shouldn't be an issue with its performance."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "pksmg"
	burst_size = 2
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/pksmgmag
	pin = /obj/item/firing_pin/wastes
	bolt_type = BOLT_TYPE_LOCKING
	show_bolt_icon = FALSE
	fire_sound = 'sound/weapons/kenetic_accel.ogg'

//FLASHLIGHTTTTTT
/obj/item/gun/ballistic/automatic/proto/pksmg/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 16)

//Magazine for SMG and the box the mags come in
/obj/item/ammo_box/magazine/pksmgmag
	name = "proto-kinetic magazine"
	desc = "A single magazine for the PKSMG."
	icon = 'monkestation/icons/obj/guns/ammo.dmi'
	icon_state = "pksmgmag"
	base_icon_state = "pksmgmag"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	ammo_type = /obj/item/ammo_casing/energy/kinetic/smg
	caliber = ENERGY
	max_ammo = 45

/obj/item/storage/box/kinetic
	name = "box of kinetic projectiles"
	desc = "A box full of kinetic projectile magazines, specifically for the proto-kinetic SMG.\
	It is specially designed to only hold proto-kinetic magazines, and also fit inside of explorer webbing."
	icon_state = "rubbershot_box"
	illustration = "rubbershot_box"

/obj/item/storage/box/kinetic/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 7
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 20
	atom_storage.set_holdable(list(
		/obj/item/ammo_box/magazine/pksmgmag,
	))

/obj/item/storage/box/kinetic/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_box/magazine/pksmgmag(src)

/obj/item/storage/box/kinetic/small
	name = "case of kinetic projectiles"
	desc = "A small case with two kinetic projectile magazines, specifically for the proto-kinetic SMG.\
	Does NOT fit in explorer webbing like the box does."
	icon_state = "secbox"
	illustration = "firecracker"

/obj/item/storage/box/kinetic/small/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 2
	atom_storage.set_holdable(list(
		/obj/item/ammo_box/magazine/pksmgmag,
	))

/obj/item/storage/box/kinetic/small/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/pksmgmag(src)

/obj/item/storage/box/pksmg //A case that the SMG comes in on purchase, containing three magazines
	name = "PKSMG Case"
	desc = "A case containing a PKSMG and three magazines. Designed for full auto but has limited ammo."
	icon_state = "plasticbox"
	illustration = "writing_syndie"

/obj/item/storage/box/pksmg/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 4
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 4

/obj/item/storage/box/pksmg/PopulateContents()
		new /obj/item/gun/ballistic/automatic/proto/pksmg(src)
		new /obj/item/ammo_box/magazine/pksmgmag(src)
		new /obj/item/ammo_box/magazine/pksmgmag(src)
		new /obj/item/ammo_box/magazine/pksmgmag(src)

/obj/item/ammo_casing/energy/kinetic/smg
	projectile_type = /obj/projectile/kinetic/smg
	select_name = "kinetic"
	e_cost = 0
	fire_sound = 'sound/weapons/kenetic_accel.ogg'

/obj/projectile/kinetic/smg
	name = "kinetic projectile"
	damage = 10
	range = 5
	icon_state = "bullet"
	Skillbasedweapon = FALSE



