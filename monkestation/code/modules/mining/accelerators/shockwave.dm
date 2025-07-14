/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave
	name = "proto-kinetic shockwave"
	desc = "Innovating on the mining blast mod, Mining Research and Development has managed to overclock the performance of the mod to the extreme. \
	The result is a specialized accelerator frame that when equipped with the accompanying modkit grants a fairly punchy, large blast that is excellent \
	for clearing large amounts of rocks and crowded fauna. \
	The only downside is the lowered mod capacity, lack of range, required mod, and longer cooldown... but its pretty good for clearing rocks. \
	A warning label is stuck to the side : Weapon will underperform without accompanying mod (Should be included with purchase)."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "kineticshockwave"
	base_icon_state = "kineticshockwave"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shockwave)
	can_bayonet = FALSE
	max_mod_capacity = 90 //bumped up to 90 to compensate for the 30 you need to spend on the AOE mod that gives it its functionality

/obj/item/ammo_casing/energy/kinetic/shockwave
	projectile_type = /obj/projectile/kinetic/shockwave
	fire_sound = 'sound/weapons/gun/general/cannon.ogg'

/obj/projectile/kinetic/shockwave
	name = "concussive kinetic force"
	damage = 40
	range = 0

/obj/item/borg/upgrade/modkit/aoe/turfs/shockwave
	name = "Shockwave modkit"
	desc = "A special version of the AOE modkit that gives the PK-Shockwave all of its unique properties. \
	It had to be shipped uninstalled from the actual PK-Shockwave due to technical issues, but installation is simple. \
	It does not fit into any other PK weapon."
	maximum_of_type = 1
	modifier = 0.50

/obj/item/storage/box/shockwave
	name = "PK-Shockwave Box"
	desc = "A box containing a PK-Shockwave and the Shockwave modkit. Designed to create large blasts of powerful kinetic energy for clearing large amounts of rock, or fauna"
	icon_state = "cyber_implants"

/obj/item/storage/box/shockwave/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = 2

/obj/item/storage/box/shockwave/PopulateContents()
	new /obj/item/gun/energy/recharge/kinetic_accelerator/shockwave(src)
	new /obj/item/borg/upgrade/modkit/aoe/turfs/shockwave(src)

/obj/item/borg/upgrade/modkit/aoe/turfs/shockwave/projectile_strike(obj/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/explosion/fast(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(2, target_turf) - target_turf)
			if(ismineralturf(T))
				var/turf/closed/mineral/M = T
				M.gets_drilled(K.firer, TRUE)
	if(modifier)
		for(var/mob/living/L in range(2, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.armor_flag, "", "", K.armour_penetration)
			L.apply_damage(K.damage*modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, span_userdanger("You're struck by a [K.name]!"))

/obj/item/borg/upgrade/modkit/aoe/turfs/shockwave/install(obj/item/gun/energy/recharge/kinetic_accelerator/KA, mob/user)
	if(istype(KA, /obj/item/gun/energy/recharge/kinetic_accelerator/shockwave))
		. = ..()
		if(.)
			for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits) //make sure only one of the aoe modules has values if somebody has multiple
				if(AOE.stats_stolen || AOE == src)
					continue
				modifier += AOE.modifier //take its modifiers
				AOE.modifier = 0
				turf_aoe += AOE.turf_aoe
				AOE.turf_aoe = FALSE
				AOE.stats_stolen = TRUE
	else
		to_chat(user, span_warning("[src] does not fit in [KA]. It will only fit in a Shockwave!"))
		return FALSE
