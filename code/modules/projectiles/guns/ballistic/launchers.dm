//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

/obj/item/gun/ballistic/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
	icon_state = "dshotgun_sawn"
	inhand_icon_state = "gun"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/grenadelauncher
	fire_sound = 'sound/weapons/gun/general/grenade_launch.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	pin = /obj/item/firing_pin/implant/pindicate
	bolt_type = BOLT_TYPE_NO_BOLT
	gun_flags = GUN_SMOKE_PARTICLES

/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/grenadelauncher/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || isammocasing(A))
		chamber_round()

/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg
	desc = "A 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/grenademulti
	pin = /obj/item/firing_pin
	gun_flags = GUN_SMOKE_PARTICLES

/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg/attack_self()
	return

/obj/item/gun/ballistic/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/weapons/gun/general/grenade_launch.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/m75
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	casing_ejector = FALSE
	gun_flags = GUN_SMOKE_PARTICLES

/obj/item/gun/ballistic/rocketlauncher
	name = "\improper PML-9"
	desc = "A reusable rocket propelled grenade launcher. The words \"NT this way\" and an arrow have been written near the barrel. \
	A sticker near the cheek rest reads, \"ENSURE AREA BEHIND IS CLEAR BEFORE FIRING\""
	icon_state = "rocketlauncher"
	inhand_icon_state = "rocketlauncher"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/rocketlauncher
	fire_sound = 'sound/weapons/gun/general/rocket_launch.ogg'
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE
	pin = /obj/item/firing_pin/implant/pindicate
	burst_size = 1
	fire_delay = 0
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	bolt_type = BOLT_TYPE_NO_BOLT
	internal_magazine = TRUE
	cartridge_wording = "rocket"
	empty_indicator = TRUE
	tac_reloads = FALSE
	/// Do we shit flames behind us when we fire?
	var/backblast = TRUE
	gun_flags = GUN_SMOKE_PARTICLES

/obj/item/gun/ballistic/rocketlauncher/Initialize(mapload)
	. = ..()
	if(backblast)
		AddElement(/datum/element/backblast)

/obj/item/gun/ballistic/rocketlauncher/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/rocketlauncher/nobackblast
	name = "flameless PML-11"
	desc = "A reusable rocket propelled grenade launcher. This one has been fitted with a special coolant loop to avoid embarassing teamkill 'accidents' from backblast."
	backblast = FALSE

/obj/item/gun/ballistic/rocketlauncher/afterattack()
	. = ..()
	magazine.get_round(FALSE) //Hack to clear the mag after it's fired

/obj/item/gun/ballistic/rocketlauncher/attack_self_tk(mob/user)
	return //too difficult to remove the rocket with TK

/obj/item/gun/ballistic/rocketlauncher/suicide_act(mob/living/user)
	user.visible_message(span_warning("[user] aims [src] at the ground! It looks like [user.p_theyre()] performing a sick rocket jump!"), \
		span_userdanger("You aim [src] at the ground to perform a bisnasty rocket jump..."))
	if(can_shoot())
		ADD_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))
		playsound(src, 'sound/vehicles/rocketlaunch.ogg', 80, TRUE, 5)
		animate(user, pixel_z = 300, time = 30, flags = ANIMATION_RELATIVE, easing = LINEAR_EASING)
		sleep(7 SECONDS)
		animate(user, pixel_z = -300, time = 5, flags = ANIMATION_RELATIVE, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))
		process_fire(user, user, TRUE)
		if(!QDELETED(user)) //if they weren't gibbed by the explosion, take care of them for good.
			user.gib()
		return MANUAL_SUICIDE
	else
		sleep(0.5 SECONDS)
		shoot_with_empty_chamber(user)
		sleep(2 SECONDS)
		user.visible_message(span_warning("[user] looks about the room realizing [user.p_theyre()] still there. [user.p_they(TRUE)] proceed to shove [src] down their throat and choke [user.p_them()]self with it!"), \
			span_userdanger("You look around after realizing you're still here, then proceed to choke yourself to death with [src]!"))
		sleep(2 SECONDS)
		return OXYLOSS

// 40mm Kinetic Grenade Launcher Hell Yeah

#define CALIBER_40MM_KINETIC "40mm Kinetic Grenade" //the ammo type (so it doesnt fit anywhere else)

/obj/item/gun/ballistic/revolver/grenadelauncher/kinetic
	desc = "Frankly we have no idea how the boys in Mining Research put this one together, \
	but we can only assume it was more illegal gun parts. Using the usual Proto Kinetic Acceleration \
	technology, the 'Slab' is a six round rotary grenade launcher, featuring extra heavy explosive 40mm \
	payloads. It does heavy damage on a direct hit to the natural landscape and natural fauna, however due to \
	hardiness of most fauna, the blast leaves something to be desired."
	name = "Proto-Kinetic 'Slab' Grenade Launcher"
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	load_sound = 'sound/weapons/gun/sniper/mag_insert.ogg'
	eject_sound = 'sound/weapons/gun/l6/l6_door.ogg'
	worn_icon_state = "protoklauncher"
	base_pixel_x = -5
	pixel_x = -5
	slot_flags = ITEM_SLOT_BACK
	icon_state = "protoklauncher"
	inhand_icon_state = "protoklauncher"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/grenadelauncher/kinetic
	fire_sound = 'sound/weapons/gun/general/grenade_launch.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	pin = /obj/item/firing_pin/wastes

/obj/item/ammo_box/magazine/internal/grenadelauncher/kinetic
	name = "kinetic rotary grenade launcher"
	ammo_type = /obj/item/ammo_casing/a40mm/kinetic
	caliber = CALIBER_40MM_KINETIC
	max_ammo = 6

/obj/item/ammo_casing/a40mm/kinetic
	name = "40mm Kinetic Grenade"
	desc = "A 40mm explosive grenade modified with Proto Kinetic technology."
	caliber = CALIBER_40MM_KINETIC
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "40mmkinetic"
	projectile_type = /obj/projectile/bullet/a40mm/kinetic

/obj/projectile/bullet/a40mm/kinetic
	name ="40mm kinetic grenade"
	desc = "OH SHIT!!!"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bolter"
	damage = 100
	range = 25

/obj/projectile/bullet/a40mm/kinetic/payload(atom/target)
	var/obj/item/grenade/shrapnel_maker = new /obj/item/grenade/kineticshrapnel(drop_location())
	shrapnel_maker.detonate()
	qdel(shrapnel_maker)
	explosion(target, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 4, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)

/obj/item/storage/box/kinetic/grenadelauncher/bigcase //box containing the  launcher and a spare box of grenades
	name = "'Slab' grenade launcher case"
	desc = "A mining gun case containing a six round rotary 'Slab' grenade launcher, and a box of spare grenades."
	icon = 'icons/obj/storage/case.dmi'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	icon_state = "miner_case"
	w_class = WEIGHT_CLASS_BULKY
	illustration = ""
	foldable_result = /obj/item/stack/sheet/iron

/obj/item/storage/box/kinetic/grenadelauncher/bigcase/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 2
	atom_storage.set_holdable(list())

/obj/item/storage/box/kinetic/grenadelauncher/bigcase/PopulateContents() //populate

		new /obj/item/gun/ballistic/revolver/grenadelauncher/kinetic (src)
		new /obj/item/storage/box/kinetic/grenadelauncher (src)

/obj/item/storage/box/kinetic/grenadelauncher //box containing 12 spare 40mm kinetic shells for the 'Slab' grenade launcher
	name = "40mm Kinetic Grenade Box"
	desc = "A small box containing 12 spare 40mm Kinetic Grenades for the 'Slab' Grenade Launcher. Despite everything, it fits in explorer webbing."
	icon_state = "40mmk_box"
	illustration = ""

/obj/item/storage/box/kinetic/grenadelauncher/Initialize(mapload) //initialize
	. = ..()
	atom_storage.max_slots = 12
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 12
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/a40mm/kinetic
	))

/obj/item/storage/box/kinetic/grenadelauncher/PopulateContents() //populate
	for(var/i in 1 to 12)
		new /obj/item/ammo_casing/a40mm/kinetic (src)


/obj/item/grenade/kineticshrapnel
	name = "Kinetic fragmentation payload"
	desc = "holy fucking shit you should NOT be seeing this please report it and then CRY ABOUT IT"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	shrapnel_type = /obj/projectile/bullet/shrapnel/kinetic
	shrapnel_radius = 2
	det_time = 0
	display_timer = FALSE
	ex_light = 0

/obj/projectile/bullet/shrapnel/kinetic
	name = "Kinetic Shrapnel Hunk"
	range = 5
	damage = 75
	weak_against_armour = TRUE
	dismemberment = 0
	ricochets_max = 0
	ricochet_chance = 0
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0

/obj/projectile/bullet/shrapnel/kinetic/on_hit(atom/target, Firer, blocked = 0, pierce_hit) //its not meant to tear through walls like a plasma cutter, but will still at least bust down a wall if it hits one.
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer, FALSE)
	. = ..()

/obj/item/grenade/kineticshrapnel/detonate(mob/living/lanced_by)

	if(shrapnel_type && shrapnel_radius && !shrapnel_initialized)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)

	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, lanced_by)
