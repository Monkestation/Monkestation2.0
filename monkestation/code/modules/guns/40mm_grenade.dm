//-----------------------
// Standard 40mm Grenade
// ----------------------
/obj/item/ammo_casing/a40mm
	name = "40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = CALIBER_40MM
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/a40mm

/obj/item/ammo_casing/a40mm/update_icon_state()
	. = ..()
	if(!loaded_projectile)
		var/random_angle = rand(0,360)
		transform = transform.Turn(random_angle)

/obj/item/ammo_casing/a40mm/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	var/obj/item/gun/ballistic/shotgun/china_lake/firing_launcher = fired_from
	if(istype(firing_launcher))
		loaded_projectile.range = firing_launcher.target_range
	. = ..()

/obj/projectile/bullet/a40mm
	name ="40mm grenade"
	desc = "USE A WEEL GUN"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_projectile"
	damage = 60
	embedding = null
	shrapnel_type = null
	range = 30

/obj/projectile/bullet/a40mm/Range() //because you lob the grenade to achieve the range :)
	if(!has_gravity(get_area(src)))
		range++
	return ..()

/obj/projectile/bullet/a40mm/proc/payload(atom/target)
	explosion(target, devastation_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 2, adminlog = FALSE, explosion_cause = src)

/obj/projectile/bullet/a40mm/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	payload(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/a40mm/on_range()
	payload(get_turf(src))
	return ..()

//--------------------------
// Rubber Slug 40mm Grenade
// -------------------------
/obj/item/ammo_casing/a40mm/rubber
	name = "40mm rubber shell"
	desc = "A cased rubber slug. The big brother of the beanbag slug, this thing will knock someone out in one. Doesn't do so great against anyone in armor."
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmRUBBER"
	projectile_type = /obj/projectile/bullet/shotgun_beanbag/a40mm

/obj/projectile/bullet/shotgun_beanbag/a40mm
	name = "rubber slug"
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmRUBBER_projectile"
	damage = 20
	stamina = 250 //BONK
	paralyze = 10 SECONDS
	wound_bonus = 30
	weak_against_armour = TRUE

//-------------------
// Weak 40mm Grenade
// ------------------
/obj/item/ammo_casing/a40mm/weak
	name = "light 40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher. This one seems rather light."
	icon_state = "40mm"
	projectile_type = /obj/projectile/bullet/a40mm/weak

/obj/projectile/bullet/a40mm/weak
	name ="light 40mm grenade"
	desc = "use a weel gun"
	damage = 30

/obj/projectile/bullet/a40mm/weak/payload(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)

//------------------------
// Incendiary 40mm Grenade
// -----------------------
/obj/item/ammo_casing/a40mm/incendiary
	name = "40mm incendiary shell"
	desc = "A cased incendiary grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmINCEN"
	projectile_type = /obj/projectile/bullet/a40mm/incendiary

/obj/projectile/bullet/a40mm/incendiary
	name ="40mm inendiary grenade"
	desc = "use a weel gun"
	damage = 15

/obj/projectile/bullet/a40mm/incendiary/payload(atom/target)
	if(iscarbon(target))
		var/mob/living/carbon/extra_crispy_carbon = target
		extra_crispy_carbon.adjust_fire_stacks(20)
		extra_crispy_carbon.ignite_mob()
		extra_crispy_carbon.apply_damage(30, BURN)

	var/turf/our_turf = get_turf(src)

	explosion(target, flame_range = 4, flash_range = 3, adminlog = FALSE, explosion_cause = src)

	for(var/turf/nearby_turf as anything in RANGE_TURFS(3, src))
		//if(is_in_sight(our_turf, nearby_turf))
		if(valid_turf(our_turf, nearby_turf))
			new /obj/effect/hotspot(nearby_turf)
			nearby_turf.hotspot_expose(750, 125, 1)
			for(var/mob/living/crispy_living in nearby_turf.contents)
				crispy_living.apply_damage(30, BURN)
				if(iscarbon(crispy_living))
					var/mob/living/carbon/crispy_carbon = crispy_living
					crispy_carbon.adjust_fire_stacks(10)
					crispy_carbon.ignite_mob()

/obj/projectile/bullet/a40mm/incendiary/proc/valid_turf(turf1, turf2)
	for(var/turf/line_turf in get_line(turf1, turf2))
		if(line_turf.is_blocked_turf(TRUE))
			return FALSE
	return TRUE

// GRENADE BOX!
//--------------------
// Read above comment
//--------------------
#define A40MM_GRENADE_INBOX_SPRITE_WIDTH 3

/obj/item/storage/fancy/a40mm_box
	name = "40mm grenade box"
	desc = "A metal box designed to hold 40mm grenades."
	icon =  'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mm_box"
	base_icon_state = "40mm_box"
	spawn_type = /obj/item/ammo_casing/a40mm
	spawn_count = 4
	open_status = FALSE
	appearance_flags = KEEP_TOGETHER|LONG_GLIDE
	contents_tag = "grenade"

	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'

/obj/item/storage/fancy/a40mm_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/ammo_casing/a40mm))

/obj/item/storage/fancy/a40mm_box/PopulateContents()
	. = ..()
	update_appearance()

/obj/item/storage/fancy/a40mm_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][open_status ? "_open" : null]"

/obj/item/storage/fancy/a40mm_box/update_overlays()
	. = ..()
	if(!open_status)
		return

	var/grenades = 0
	for(var/_grenade in contents)
		var/obj/item/ammo_casing/a40mm/grenade = _grenade
		if (!istype(grenade))
			continue
		. += image(icon = initial(icon), icon_state = (initial(grenade.icon_state) + "_inbox"), pixel_x = grenades * A40MM_GRENADE_INBOX_SPRITE_WIDTH)
		grenades += 1


#undef A40MM_GRENADE_INBOX_SPRITE_WIDTH
