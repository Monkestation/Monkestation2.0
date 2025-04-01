//locker mech
/obj/item/mecha_parts/mecha_equipment/drill/makeshift
	name = "Makeshift exosuit drill"
	desc = "Cobbled together from likely stolen parts, this drill is nowhere near as effective as the real deal."
	equip_cooldown = 60 //Its slow as shit
	force = 10 //Its not very strong
	mech_flags = EXOSUIT_MODULE_MAKESHIFT
	drill_delay = 15

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	name = "makeshift clamp"
	desc = "Loose arrangement of cobbled together bits resembling a clamp."
	equip_cooldown = 25
	force = 10
	mech_flags = EXOSUIT_MODULE_MAKESHIFT

//ambulance
/obj/item/mecha_parts/mecha_equipment/medical/sleeper/makeshift
	name = "mounted stretcher"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_mounted_stretcher"
	desc = "A mangled bunched of medical equipment connecting to a strecher, It can transport and stabilize patients fine. just don't expect anything more"
	inject_amount = 0
	mech_flags = EXOSUIT_MODULE_AMBULANCE

/obj/item/mecha_parts/mecha_equipment/weapon/honker/makeshift
	name = "harm alarm horn"
	icon_state = "mecha_harm_alarm"
	desc = "A crude honking horn that alarms nearby bystanders that an ambulance is going through"
	mech_flags = EXOSUIT_MODULE_AMBULANCE
	honk_range = 1 //only directly besides, are affected
	tactile_message = "HARM ALARM"

//trashtank
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/pipegun
	name = "pipegun breech"
	desc = "A pipegun that is fitted to be mounted to a tank turret, the actual gun seems haphazardly tacked on with scrap"
	icon_state = "mecha_pipegun"
	equip_cooldown = 10
	projectile = /obj/projectile/bullet/a762/surplus
	projectiles = 8
	projectiles_cache = 8
	projectiles_cache_max = 24
	projectiles_per_shot = 1
	projectile_delay = 0.5 SECONDS
	harmful = TRUE
	ammo_type = MECHA_AMMO_PIPEGUN
	mech_flags = EXOSUIT_MODULE_TRASHTANK

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/peashooter
	name = "peashooter breech"
	desc = "Something that can be charitably called a \" Peashooter \" that is fitted to be mounted to a tank turret, it seems haphazardly built from scrap"
	icon_state = "mecha_peashooter"
	equip_cooldown = 10
	projectile = /obj/projectile/bullet/pellet/shotgun_improvised
	projectiles = 30
	projectiles_cache = 30
	projectiles_cache_max = 60
	projectiles_per_shot = 3
	variance = 6
	randomspread = 1
	projectile_delay = 0.2 SECONDS
	equip_cooldown = 1 SECONDS
	harmful = TRUE
	ammo_type = MECHA_AMMO_PEASHOOTER
	mech_flags = EXOSUIT_MODULE_TRASHTANK
