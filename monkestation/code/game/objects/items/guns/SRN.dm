GLOBAL_VAR_INIT(_TEST_HOMING_SPEED, 5)

/obj/item/gun/ballistic/srn_rocketlauncher
	desc = "A rocket designed with the power of bluespace to send a singularity or tesla back to the shadow realm"
	name = "Spatial Rift Nullifier"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "srnlauncher"
	inhand_icon_state = "srnlauncher"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/srn_rocket
	fire_sound = 'sound/weapons/gun/general/rocket_launch.ogg'
	bolt_type = BOLT_TYPE_NO_BOLT
	fire_sound_volume = 80
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE
	pin = /obj/item/firing_pin
	fire_delay = 1.5
	recoil = 1
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	bolt_type = BOLT_TYPE_LOCKING
	internal_magazine = TRUE
	cartridge_wording = "rocket"
	empty_indicator = TRUE
	empty_alarm = TRUE
	tac_reloads = FALSE

/obj/item/gun/ballistic/srn_rocketlauncher/attack_self(mob/user)
	return //too difficult to remove the rocket with TK

/obj/item/gun/ballistic/srn_rocketlauncher/chamber_round(keep_bullet = FALSE, spin_cylinder, replace_new_round)
	chambered = magazine.get_round(FALSE)


///SRN Internal Magazine
/obj/item/ammo_box/magazine/internal/srn_rocket
	name = "SRN Rocket"
	ammo_type = /obj/item/ammo_casing/caseless/srn_rocket
	caliber = "84mm"
	max_ammo = 3

/// SRN caseless ammo casing
/obj/item/ammo_casing/caseless/srn_rocket
	name = "\improper Spatial Rift Nullifier Rocket"
	desc = "A prototype Spatial Rift Nullifier (SRN) Rocket. Fire at a rogue singularity or Tesla and pray it hits"
	caliber = "84mm"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "srn_rocket"
	projectile_type = /obj/projectile/bullet/srn_rocket

/obj/item/ammo_casing/caseless/srn_rocket/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	. = ..()
	if(!loaded_projectile)
		return
	if(is_srn_target(target))
		loaded_projectile.set_homing_target(target)
	else
		var/obj/new_target = find_nearest_srn_target(fired_from)
		if(!QDELETED(new_target))
			loaded_projectile.original = new_target
			loaded_projectile.set_homing_target(new_target)

/// SRN Rocket Projectile
/obj/projectile/bullet/srn_rocket
	name = "SRN rocket"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "srn_rocket"
	hitsound = 'sound/effects/meteorimpact.ogg'
	damage = 10
	ricochets_max = 0 //it's a MISSILE
	projectile_phasing = PASSTABLE | PASSGRILLE
	var/pierces_remaining = 3
	var/static/list/pierce_costs

/obj/projectile/bullet/srn_rocket/Initialize(mapload)
	. = ..()
	homing_turn_speed = GLOB._TEST_HOMING_SPEED
	if(isnull(pierce_costs))
		pierce_costs = zebra_typecacheof(list(
			/turf/closed/wall = 1,
			/turf/closed/mineral = 1.5,
			/obj/structure/falsewall = 1,
			/obj/structure/window = 0.5,
			/obj/structure/window_sill = 0,
			/obj/structure/closet = 0,
		))

/obj/projectile/bullet/srn_rocket/prehit_pierce(atom/target)
	var/cost = pierce_costs[target.type]
	if(!isnull(cost))
		if(cost <= 0)
			return PROJECTILE_PIERCE_PHASE
		else if(pierces_remaining >= cost)
			pierces_remaining -= cost
			return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/projectile/bullet/srn_rocket/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	if(isliving(target))
		var/mob/living/living_target = target
		playsound(living_target, 'sound/weapons/pierce.ogg', vol = 100, vary = TRUE)
		living_target.adjustOxyLoss(5)
		to_chat(living_target, span_warning("You are struck by a spatial nullifier! Thankfully it didn't affect you... much."))
		living_target.emote("scream")
	else
		playsound(target, SFX_SPARKS, vol = 100, vary = TRUE)
	return BULLET_ACT_HIT

/obj/projectile/bullet/srn_rocket/Impact(atom/hit)
	. = ..()
	if(is_srn_target(hit))
		var/mob/living/user = firer
		if(!QDELETED(user))
			user.client?.give_award(/datum/award/achievement/misc/singularity_buster, user)
			user.emote("scream")

		for(var/mob/player as anything in GLOB.player_list)
			if(isnewplayer(player) || QDELETED(player))
				continue
			player.playsound_local(player, 'sound/magic/charge.ogg', vol = 75, pressure_affected = FALSE, mixer_channel = CHANNEL_SOUND_EFFECTS)
			to_chat(player, span_boldannounce("You feel reality distort for a moment..."))
			shake_camera(player, duration = 1.5 SECONDS, strength = 3)

		new /obj/spatial_rift(get_turf(hit))
		qdel(hit)

/obj/projectile/bullet/srn_rocket/select_target(turf/our_turf, atom/target, atom/bumped)
	if(is_srn_target(bumped) && can_hit_target(bumped, original == bumped, FALSE, TRUE))
		return bumped
	for(var/thingy in our_turf)
		if(is_srn_target(thingy) && can_hit_target(thingy, thingy == original, TRUE, thingy == bumped))
			return thingy
	return ..()

/obj/projectile/bullet/srn_rocket/process()
	if(QDELETED(src))
		return
	// try to lock on to the nearest tesla or singularity if we aren't already locked onto one
	if(!is_srn_target(original))
		var/obj/new_target = find_nearest_srn_target(src)
		if(!QDELETED(new_target))
			original = new_target
			set_homing_target(new_target)
	if(check_singularity_hit(original))
		return
	return ..()

/obj/projectile/bullet/srn_rocket/proc/check_singularity_hit(obj/singularity/singuloth)
	if(QDELETED(src) || !istype(singuloth) || QDELING(singuloth))
		return FALSE
	var/collision_dist = singuloth.current_size - 1
	if(collision_dist < 1)
		return FALSE
	if(get_dist(src, singuloth) <= collision_dist)
		Impact(singuloth)
		return TRUE
	return FALSE

/obj/projectile/bullet/srn_rocket/singularity_act(singularity_size, obj/parent)
	if(!QDELETED(src) && is_srn_target(parent))
		Impact(parent)

/obj/projectile/bullet/srn_rocket/singularity_pull(obj/singularity/singularity, current_size)
	. = ..()
	check_singularity_hit(singularity)

/datum/award/achievement/misc/singularity_buster
	name = "Scrungularity"
	desc = "Wow you saved the station, well at least what is left. Someone is getting a holiday bonus."
	database_id = MEDAL_SINGULARITY_BUSTER


/// Spatial Rift
/// Basically a BoH Tear, but weaker because it spawns after nullifying a tesloose or singlo and those have done enough damage
/obj/spatial_rift
	name = "a small tear in the fabric of reality, a good place to stuff problems"
	desc = "Your own comprehension of reality starts bending as you stare at this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	pixel_x = -32
	pixel_y = -32
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

/obj/spatial_rift/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 5 SECONDS) // vanishes after 5 seconds
	AddComponent(
		/datum/component/singularity, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = 1, \
		grav_pull = 8, \
		roaming = FALSE, \
		singularity_size = STAGE_FIVE, \
	)

/obj/spatial_rift/process()
	consume()

/obj/spatial_rift/proc/consume(atom/movable/thing)
	if(!ismovable(thing))
		if(isturf(thing))
			thing.singularity_act()
		return
	var/turf/our_turf = get_turf(src)
	if(isliving(thing))
		var/mob/living/living_thing = thing
		investigate_log("([key_name(living_thing)]) has been consumed by the Spatial rift at [AREACOORD(our_turf)].", INVESTIGATE_ENGINE)
		living_thing.ghostize(can_reenter_corpse = FALSE)
	else if(is_srn_target(thing))
		investigate_log("([key_name(thing)]) has been consumed by the Spatial rift at [AREACOORD(our_turf)].", INVESTIGATE_ENGINE)
		return
	thing.forceMove(src)

/obj/spatial_rift/proc/admin_investigate_setup()
	var/turf/our_turf = get_turf(src)
	message_admins("A Spatial rift has been created at [ADMIN_VERBOSEJMP(our_turf)].]")
	investigate_log("was created at [AREACOORD(our_turf)].", INVESTIGATE_ENGINE)

/obj/spatial_rift/attack_tk(mob/living/user)
	if(!isliving(user))
		return
	to_chat(user, span_userdanger("You don't feel like you are real anymore."))
	user.dust_animation()
	user.spawn_dust()
	addtimer(CALLBACK(src, PROC_REF(consume), user), 0.5 SECONDS)

/proc/is_srn_target(obj/target)
	. = FALSE
	if(!isobj(target) || QDELING(target))
		return FALSE
	if(istype(target, /obj/singularity))
		return TRUE
	if(istype(target, /obj/energy_ball))
		var/obj/energy_ball/lady_tesla = target
		return !lady_tesla.orbiting // don't target miniballs

/proc/find_nearest_srn_target(turf/center)
	center = get_turf(center)
	if(!center)
		return
	var/obj/closest_target
	var/closest_distance
	for(var/obj/thing in range(world.view, center))
		if(!is_srn_target(thing))
			continue
		var/distance = get_dist(center, thing)
		if(!closest_target || (closest_distance > distance))
			closest_distance = distance
			closest_target = thing
	if(!QDELETED(closest_target))
		return closest_target
