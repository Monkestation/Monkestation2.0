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

/obj/item/gun/ballistic/automatic/sol_grenade_launcher/afterattack_secondary(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(!target || !user)
		return

	var/distance_ranged = get_dist(user, target)
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

