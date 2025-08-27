#define AMMO_MATS_GRENADE list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, \
)

#define AMMO_MATS_GRENADE_SHRAPNEL list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
	/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 2, \
)

#define AMMO_MATS_GRENADE_INCENDIARY list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
	/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 2, \
)


// .980 grenades
// Grenades that can be given a range to detonate at by their firing gun

/obj/item/ammo_casing/c980grenade
	name = ".980 Tydhouer practice grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Practice shells disintegrate into harmless sparks."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "980_solid"
	caliber = CALIBER_980TYDHOUER
	projectile_type = /obj/projectile/bullet/c980grenade
	custom_materials = AMMO_MATS_GRENADE
	harmful = FALSE //Erm, technically

/obj/item/ammo_casing/c980grenade/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	var/obj/item/gun/ballistic/automatic/sol_grenade_launcher/firing_launcher = fired_from
	if(istype(firing_launcher))
		loaded_projectile.range = firing_launcher.target_range

	. = ..()


// .980 smoke grenade
/obj/item/ammo_casing/c980grenade/smoke
	name = ".980 Tydhouer smoke grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Bursts into a laser-weakening smoke cloud."
	icon_state = "980_smoke"
	projectile_type = /obj/projectile/bullet/c980grenade/smoke


// .980 shrapnel grenade
/obj/item/ammo_casing/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Explodes into shrapnel on detonation."
	icon_state = "980_explosive"
	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel
	custom_materials = AMMO_MATS_GRENADE_SHRAPNEL
	advanced_print_req = TRUE
	harmful = TRUE


// .980 phosphor grenade
/obj/item/ammo_casing/c980grenade/shrapnel/phosphor
	name = ".980 Tydhouer phosphor grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Explodes into smoke and flames on detonation."
	icon_state = "980_gas_alternate"
	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel/phosphor
	custom_materials = AMMO_MATS_GRENADE_INCENDIARY


// .980 tear gas grenade
/obj/item/ammo_casing/c980grenade/riot
	name = ".980 Tydhouer tear gas grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Bursts into a tear gas cloud."
	icon_state = "980_gas"
	projectile_type = /obj/projectile/bullet/c980grenade/riot


#undef AMMO_MATS_GRENADE
#undef AMMO_MATS_GRENADE_SHRAPNEL
#undef AMMO_MATS_GRENADE_INCENDIARY




// Standard 40mm Grenade
/obj/item/ammo_casing/a40mm
	name = "40mm HE grenade"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher."
	caliber = CALIBER_40MM
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmHE"
	projectile_type = /obj/projectile/bullet/a40mm
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)

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

// 40mm Rubber Slug Grenade
/obj/item/ammo_casing/a40mm/rubber
	name = "40mm rubber slug shell"
	desc = "A cased rubber slug. The big brother of the beanbag slug, this thing will knock someone out in one. Doesn't do so great against anyone in armor."
	icon = 'monkestation/icons/obj/guns/40mm_grenade.dmi'
	icon_state = "40mmRUBBER"
	projectile_type = /obj/projectile/bullet/shotgun_beanbag/a40mm

// Weak 40mm Grenade
/obj/item/ammo_casing/a40mm/weak
	name = "light 40mm HE grenade"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher. It seems rather light."
	icon_state = "40mm"
	projectile_type = /obj/projectile/bullet/a40mm/weak

// 40mm Incendiary Grenade
/obj/item/ammo_casing/a40mm/incendiary
	name = "40mm incendiary grenade"
	desc = "A cased incendiary grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmINCEN"
	projectile_type = /obj/projectile/bullet/a40mm/incendiary

// 40mm Smoke Grenade
/obj/item/ammo_casing/a40mm/smoke
	name = "40mm smoke grenade"
	desc = "A cased smoke grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmSMOKE"
	projectile_type = /obj/projectile/bullet/a40mm/smoke

// 40mm Stun Grenade
/obj/item/ammo_casing/a40mm/stun
	name = "40mm stun grenade"
	desc = "A cased stun grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmSTUN"
	projectile_type = /obj/projectile/bullet/a40mm/stun

// 40mm HEDP Grenade
/obj/item/ammo_casing/a40mm/hedp
	name = "40mm HEDP grenade"
	desc = "A cased HEDP grenade that can only be activated once fired out of a grenade launcher. The destroyer of mechs and silicons alike."
	icon_state = "40mmHEDP"
	projectile_type = /obj/projectile/bullet/a40mm/hedp

// 40mm Frag Grenade
/obj/item/ammo_casing/a40mm/frag
	name = "40mm fragmentation grenade"
	desc = "A cased stun grenade that can only be activated once fired out of a grenade launcher."
	icon_state = "40mmFRAG"
	projectile_type = /obj/projectile/bullet/a40mm/frag

// Mining grenade
/obj/item/ammo_casing/a40mm/kinetic
	name = "40mm Kinetic Grenade"
	desc = "A 40mm explosive grenade modified with Proto Kinetic technology."
	caliber = CALIBER_40MM_KINETIC
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "40mmkinetic"
	projectile_type = /obj/projectile/bullet/a40mm/kinetic
