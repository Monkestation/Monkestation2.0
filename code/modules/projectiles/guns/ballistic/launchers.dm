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

///Blueshift gun below

/obj/item/gun/ballistic/automatic/sol_grenade_launcher
	name = "\improper Kiboko Grenade Launcher"
	desc = "A unique grenade launcher firing .980 grenades. A laser sight system allows its user to specify a range for the grenades it fires to detonate at."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/guns48x.dmi'
	icon_state = "kiboko"
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_worn.dmi'
	worn_icon_state = "kiboko"
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/company_and_or_faction_based/carwo_defense_systems/guns_righthand.dmi'
	inhand_icon_state = "kiboko"
	SET_BASE_PIXEL(-8, 0)
	special_mags = TRUE
	bolt_type = BOLT_TYPE_LOCKING
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	spawn_magazine_type = /obj/item/ammo_box/magazine/c980_grenade/drum
	accepted_magazine_type = /obj/item/ammo_box/magazine/c980_grenade
	fire_sound = 'monkestation/code/modules/blueshift/sounds/grenade_launcher.ogg'
	can_suppress = FALSE
	can_bayonet = FALSE
	burst_size = 1
	fire_delay = 5
	actions_types = list()
	/// The currently stored range to detonate shells at
	var/target_range = 14
	/// The maximum range we can set grenades to detonate at, just to be safe
	var/maximum_target_range = 14

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_CARWO)

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/examine_more(mob/user)
	. = ..()

	. += "The Kiboko is one of the strangest weapons Carwo offers. A grenade launcher, \
		though not in the standard grenade size. The much lighter .980 Tydhouer grenades \
		developed for the weapon offered many advantages over standard grenade launching \
		ammunition. For a start, it was significantly lighter, and easier to carry large \
		amounts of. What it also offered, however, and the reason SolFed funded the \
		project: Variable time fuze. Using the large and expensive ranging sight on the \
		launcher, its user can set an exact distance for the grenade to self detonate at. \
		The dream of militaries for decades, finally realized. The smaller shells do not, \
		however, make the weapon any more enjoyable to fire. The kick is only barely \
		manageable thanks to the massive muzzle brake at the front."

	return .

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/examine(mob/user)
	. = ..()

	. += span_notice("With <b>Right Click</b> you can set the range that shells will detonate at.")
	. += span_notice("A small indicator in the sight notes the current detonation range is: <b>[target_range]</b>.")

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with || !user)
		return

	var/distance_ranged = get_dist(user, interacting_with)
	if(distance_ranged > maximum_target_range)
		user.balloon_alert(user, "out of range")
		return

	target_range = distance_ranged
	user.balloon_alert(user, "range set: [target_range]")

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/no_mag
	spawnwithmagazine = FALSE

// fun & games but evil this time

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil
	icon_state = "kiboko_evil"
	worn_icon_state = "kiboko_evil"
	inhand_icon_state = "kiboko_evil"
	projectile_wound_bonus = 5
	fire_delay = 0.3 SECONDS
	pin = /obj/item/firing_pin/implant/pindicate

	spawn_magazine_type = /obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_shrapnel

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/evil/unrestricted
	pin = /obj/item/firing_pin


/obj/item/gun/ballistic/shotgun/china_lake
	name = "\improper China Lake 40mm"
	desc = "Oh, they're goin' ta have to glue you back together...IN HELL!"
	desc_controls = "ALT-Click to set range. Can be reloaded by CLICK-DRAGGING grenades onto the launcher."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/china_lake
	var/target_range = 10
	var/minimum_target_range = 5
	var/maximum_target_range = 30
	icon = 'monkestation/icons/obj/guns/china_lake_obj.dmi'
	icon_state = "china_lake"
	lefthand_file = 'monkestation/icons/mob/inhands/china_lake_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/china_lake_righthand.dmi'
	inhand_icon_state = "china_lake"
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	fire_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_fire.ogg'
	fire_sound_volume = 100
	rack_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_rack.ogg'
	rack_delay = 1.5 SECONDS
	drop_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_drop.ogg'
	pickup_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_pickup.ogg'

/obj/item/gun/ballistic/shotgun/china_lake/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 10, force_wielded = 10)

/obj/item/gun/ballistic/shotgun/china_lake/examine(mob/user)
	. = ..()
	. += span_notice("The leaf sight is set for: <b>[target_range] tiles</b>.")

/obj/item/gun/ballistic/shotgun/china_lake/click_alt(mob/living/user)
	var/new_range = tgui_input_number(user, "Please set the range", "Leaf Sight Level", 10, maximum_target_range, minimum_target_range)
	if(!new_range || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return CLICK_ACTION_BLOCKING
	if(new_range != target_range)
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	target_range = new_range
	to_chat(user, "Leaf sight set for [target_range] tiles.")
	return CLICK_ACTION_SUCCESS

/obj/item/gun/ballistic/shotgun/china_lake/mouse_drop_receive(mob/living/dropped, mob/user, params)
	. = ..()
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	if(!istype(dropped, /obj/item/ammo_casing/a40mm))
		return
	if(!(carbon_user.mobility_flags & MOBILITY_USE) || carbon_user.stat != CONSCIOUS || HAS_TRAIT(carbon_user, TRAIT_HANDS_BLOCKED) || !Adjacent(carbon_user, dropped))
		return
	attackby(dropped, carbon_user)

/obj/item/gun/ballistic/shotgun/china_lake/restricted
	pin = /obj/item/firing_pin/implant/pindicate

///Mining grenade launcher

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

/obj/item/gun/ballistic/ignifist
	name = "\improper Ignifist 30"
	desc = "A small one shot use anti tank rocketlauncher, extremely basic in design, it will only tickle soft targets."
	icon_state = "ignifist"
	inhand_icon_state = "ignifist"
	accepted_magazine_type = /obj/item/ammo_box/magazine/ignifist
	fire_sound = 'sound/weapons/gun/general/rocket_launch.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	bolt_type = BOLT_TYPE_NO_BOLT
	internal_magazine = FALSE
	cartridge_wording = "rocket"
	empty_indicator = FALSE
	tac_reloads = FALSE
	gun_flags = GUN_SMOKE_PARTICLES
	mag_display_ammo = TRUE
