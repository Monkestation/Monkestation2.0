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
	projectiles_cache = 0
	projectiles_cache_max = 24
	projectiles_per_shot = 1
	projectile_delay = 0.5 SECONDS
	harmful = TRUE
	ammo_type = MECHA_AMMO_PIPEGUN
	mech_flags = EXOSUIT_MODULE_TRASHTANK

/obj/projectile/bullet/pellet/shotgun_improvised/tank
	tile_dropoff = 0 //its a peashooter that fires with bullets the size of pellets, but don't do this now...

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/peashooter
	name = "peashooter breech"
	desc = "Something that can be charitably called a \" Peashooter \" that is fitted to be mounted to a tank turret, it seems haphazardly built from scrap"
	icon_state = "mecha_peashooter"
	equip_cooldown = 10
	projectile = /obj/projectile/bullet/pellet/shotgun_improvised
	projectiles = 30
	projectiles_cache = 0
	projectiles_cache_max = 120
	projectiles_per_shot = 6
	projectile_delay = 0.2 SECONDS
	equip_cooldown = 1 SECONDS
	harmful = TRUE
	ammo_type = MECHA_AMMO_PEASHOOTER
	mech_flags = EXOSUIT_MODULE_TRASHTANK

/obj/item/mecha_parts/mecha_equipment/tankupgrade
	name = "trash tank armor plating"
	desc = "A jumble of whatever scrap that someone can scrounge up that is able to beef up a trash tank somewhat."
	icon_state = "tank_armor"
	mech_flags = EXOSUIT_MODULE_TRASHTANK

/obj/item/mecha_parts/mecha_equipment/tankupgrade/can_attach(obj/vehicle/sealed/mecha/trash_tank/tank, attach_right = FALSE, mob/user)
	if(tank.type != /obj/vehicle/sealed/mecha/trash_tank)
		to_chat(user, span_warning("This armor plating can only be installed to a trash tank"))
		return FALSE
	if(!(tank.mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)) //non-removable upgrade, so lets make sure the pilot or owner has their say.
		to_chat(user, span_warning("[tank] must have maintenance protocols active in order to allow this conversion kit."))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/tankupgrade/attach(obj/vehicle/sealed/mecha/trash_tank/tank, attach_right = FALSE)
	tank.upgrade()
	playsound(get_turf(tank),'sound/items/ratchet.ogg',50,TRUE)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/infantry_support_gun
	name = "infantry support gun breech"
	desc = "an improvised mantlet fitted to launch IED's torwards enemies."
	icon_state = "mecha_supportgun"
	harmful = TRUE
	ammo_type = MECHA_AMMO_ISG
	mech_flags = EXOSUIT_MODULE_TRASHTANK
	var/det_time = 3 SECONDS
	equip_cooldown = 60
	projectile = /obj/item/grenade/iedcasing/spawned
	missile_speed = 1.5
	projectiles = 1
	projectiles_cache = 0
	projectiles_cache_max = 6

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/infantry_support_gun/proj_init(obj/item/grenade/flashbang/F, mob/user)
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(user)] fired a [F] in [ADMIN_VERBOSEJMP(T)]")
	user.log_message("fired a [F] in [AREACOORD(T)].", LOG_GAME)
	user.log_message("fired a [F] in [AREACOORD(T)].", LOG_ATTACK)
	addtimer(CALLBACK(F, TYPE_PROC_REF(/obj/item/grenade/iedcasing/spawned, detonate)), det_time)
