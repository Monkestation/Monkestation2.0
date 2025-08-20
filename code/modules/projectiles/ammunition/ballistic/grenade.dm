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

#define GRENADE_SMOKE_RANGE 0.75



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

#undef GRENADE_SMOKE_RANGE