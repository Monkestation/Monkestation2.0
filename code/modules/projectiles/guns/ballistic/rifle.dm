/obj/item/gun/ballistic/rifle
	name = "Bolt Rifle"
	desc = "Some kind of bolt action rifle. You get the feeling you shouldn't have this."
	icon_state = "moistnugget"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "moistnugget"
	worn_icon_state = "moistnugget"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction
	bolt_wording = "bolt"
	bolt_type = BOLT_TYPE_LOCKING
	semi_auto = FALSE
	internal_magazine = TRUE
	fire_sound = 'sound/weapons/gun/rifle/shot.ogg'
	fire_sound_volume = 90
	rack_sound = 'sound/weapons/gun/rifle/bolt_out.ogg'
	bolt_drop_sound = 'sound/weapons/gun/rifle/bolt_in.ogg'
	tac_reloads = FALSE
	gun_flags = GUN_SMOKE_PARTICLES
	/// Does the bolt need to be open to interact with the gun (e.g. magazine interactions)?
	var/need_bolt_lock_to_interact = TRUE
	box_reload_delay = CLICK_CD_RANGE ///0.4 SECONDS

/obj/item/gun/ballistic/rifle/rack(mob/user = null)
	if (bolt_locked == FALSE)
		balloon_alert(user, "bolt opened")
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
		process_chamber(user = user, empty_chamber = FALSE, from_firing = FALSE, chamber_next_round = FALSE)
		bolt_locked = TRUE
		update_appearance()
		return
	drop_bolt(user)

/obj/item/gun/ballistic/rifle/can_shoot()
	if (bolt_locked)
		return FALSE
	return ..()

/obj/item/gun/ballistic/rifle/attackby(obj/item/A, mob/user, params)
	if(need_bolt_lock_to_interact && !bolt_locked && !istype(A, /obj/item/stack/sheet/cloth))
		balloon_alert(user, "[bolt_wording] is closed!")
		return
	return ..()

/obj/item/gun/ballistic/rifle/examine(mob/user)
	. = ..()
	. += "The bolt is [bolt_locked ? "open" : "closed"]."

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/ballistic/rifle/boltaction
	name = "\improper Mosin Nagant"
	desc = "A classic Mosin Nagant. They don't make them like they used to. Well, okay, in all honesty, this one is actually \
		a new refurbished version. So it works just fine! Often found in the hands of underpaid Nanotrasen interns, \
		Russian military LARPers, actual Space Russians, revolutionaries and cargo technicians. Still feels slightly moist."
	sawn_desc = "A sawn-off Mosin Nagant, popularly known as an \"Obrez\". \
		There was probably a reason it wasn't manufactured this short to begin with. \
		This one is still in surprisingly good condition. Often found in the hands \
		of underpaid Nanotrasen interns without a care for company property, Russian military LARPers, \
		actual drunk Space Russians, Tiger Co-op assassins and cargo technicians. <I>Still</I> feels slightly moist."
	weapon_weight = WEAPON_HEAVY
	icon_state = "moistnugget"
	inhand_icon_state = "moistnugget"
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13
	can_be_sawn_off = TRUE
	var/jamming_chance = 20
	var/unjam_chance = 10
	var/jamming_increment = 5
	var/jammed = FALSE
	var/can_jam = FALSE

/obj/item/gun/ballistic/rifle/boltaction/sawoff(mob/user)
	. = ..()
	if(.)
		spread = 36
		can_bayonet = FALSE
		update_appearance()

/obj/item/gun/ballistic/rifle/boltaction/attack_self(mob/user)
	if(can_jam)
		if(jammed)
			if(prob(unjam_chance))
				jammed = FALSE
				unjam_chance = 10
			else
				unjam_chance += 10
				balloon_alert(user, "jammed!")
				playsound(user,'sound/weapons/jammed.ogg', 75, TRUE)
				return FALSE
	..()

/obj/item/gun/ballistic/rifle/boltaction/process_fire(mob/user)
	if(can_jam)
		if(chambered.loaded_projectile)
			if(prob(jamming_chance))
				jammed = TRUE
			jamming_chance += jamming_increment
			jamming_chance = clamp (jamming_chance, 0, 100)
	return ..()

/obj/item/gun/ballistic/rifle/boltaction/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(!can_jam)
		balloon_alert(user, "can't jam!")
		return

	if(!bolt_locked)
		balloon_alert(user, "bolt closed!")
		return

	if(istype(item, /obj/item/gun_maintenance_supplies) && do_after(user, 10 SECONDS, target = src))
		user.visible_message(span_notice("[user] finishes maintenance of [src]."))
		jamming_chance = initial(jamming_chance)
		qdel(item)

/obj/item/gun/ballistic/rifle/boltaction/blow_up(mob/user)
	. = FALSE
	if(chambered?.loaded_projectile)
		process_fire(user, user, FALSE)
		. = TRUE

/obj/item/gun/ballistic/rifle/boltaction/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SAKHNO)

/obj/item/gun/ballistic/rifle/boltaction/surplus
	desc = "A classic Mosin Nagant, ruined by centuries of moisture. Some Space Russians claim that the moisture \
		is a sign of good luck. A sober user will know that this thing is going to fucking jam. Repeatedly. \
		Often found in the hands of cargo technicians, Russian military LARPers, Tiger Co-Op terrorist cells, \
		cryo-frozen Space Russians, and security personnel with a bone to pick. EXTREMELY moist."
	sawn_desc = "A sawn-off Mosin Nagant, popularly known as an \"Obrez\". \
		There was probably a reason it wasn't manufactured this short to begin with. \
		This one has been ruined by centuries of moisture and WILL jam. Often found in the hands of \
		cargo technicians with a death wish, Russian military LARPers, actual drunk Space Russians, \
		Tiger Co-op assassins, cryo-frozen Space Russians, and security personnel with \
		little care for professional conduct while making 'arrests' point blank in the back of the head \
		until the gun clicks. EXTREMELY moist."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/surplus
	can_jam = TRUE

/obj/item/gun/ballistic/rifle/boltaction/prime
	name = "\improper Regal Nagant"
	desc = "A prized hunting Mosin Nagant. Used for the most dangerous game."
	icon_state = "moistprime"
	inhand_icon_state = "moistprime"
	worn_icon_state = "moistprime"
	can_be_sawn_off = TRUE
	sawn_desc = "A sawn-off Regal Nagant... Doing this was a sin, I hope you're happy. \
		You are now probably one of the few people in the universe to ever hold a \"Regal Obrez\". \
		Even thinking about that name combination makes you ill."

/obj/item/gun/ballistic/rifle/boltaction/prime/sawoff(mob/user)
	. = ..()
	if(.)
		name = "\improper Regal Obrez" // wear it loud and proud

/obj/item/gun/ballistic/rifle/boltaction/prime/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_XHIHAO)

/obj/item/gun/ballistic/rifle/boltaction/pipegun
	name = "pipegun"
	desc = "An excellent weapon for flushing out tunnel rats and enemy assistants, but its rifling leaves much to be desired."
	icon_state = "musket"
	inhand_icon_state = "musket"
	worn_icon_state = "musket"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/pipegun
	initial_caliber = CALIBER_SHOTGUN
	alternative_caliber = CALIBER_A762
	initial_fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	alternative_fire_sound = 'sound/weapons/gun/shotgun/shot.ogg'
	can_modify_ammo = TRUE
	can_misfire = FALSE
	can_bayonet = TRUE
	knife_y_offset = 11
	can_be_sawn_off = FALSE
	projectile_damage_multiplier = 0.75

/obj/item/gun/ballistic/rifle/boltaction/pipegun/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	. = ..()
	do_sparks(1, TRUE, src)

/obj/item/gun/ballistic/rifle/boltaction/pipegun/give_manufacturer_examine()
	return

/obj/item/gun/ballistic/rifle/boltaction/pipegun/prime
	name = "regal pipegun"
	desc = "Older, territorial assistants typically possess more valuable loot."
	icon_state = "musket_prime"
	inhand_icon_state = "musket_prime"
	worn_icon_state = "musket_prime"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/pipegun/prime
	projectile_damage_multiplier = 1

/// MAGICAL BOLT ACTIONS + ARCANE BARRAGE? ///

/obj/item/gun/ballistic/rifle/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/enchanted
	can_be_sawn_off = FALSE

/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	fire_sound = 'sound/weapons/emitter.ogg'
	pin = /obj/item/firing_pin/magic
	icon_state = "arcane_barrage"
	inhand_icon_state = "arcane_barrage"
	slot_flags = null
	can_bayonet = FALSE
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NOBLUDGEON
	flags_1 = NONE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	show_bolt_icon = FALSE //It's a magic hand, not a rifle

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/arcane_barrage

/obj/item/gun/ballistic/rifle/enchanted/dropped()
	. = ..()
	guns_left = 0
	magazine = null
	chambered = null

/obj/item/gun/ballistic/rifle/enchanted/proc/discard_gun(mob/living/user)
	user.throw_item(pick(oview(7,get_turf(user))))

/obj/item/gun/ballistic/rifle/enchanted/arcane_barrage/discard_gun(mob/living/user)
	qdel(src)

/obj/item/gun/ballistic/rifle/enchanted/attack_self()
	return

/obj/item/gun/ballistic/rifle/enchanted/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	if(guns_left)
		var/obj/item/gun/ballistic/rifle/enchanted/gun = new type
		gun.guns_left = guns_left - 1
		discard_gun(user)
		user.swap_hand()
		user.put_in_hands(gun)
	else
		user.dropItemToGround(src, TRUE)

// SNIPER //

/obj/item/gun/ballistic/rifle/sniper_rifle
	name = "anti-materiel sniper rifle"
	desc = "A boltaction anti-materiel rifle, utilizing .50 BMG cartridges. While technically outdated in modern arms markets, it still works exceptionally well as \
		an anti-personnel rifle. In particular, the employment of modern armored MODsuits utilizing advanced armor plating has given this weapon a new home on the battlefield. \
		It is also able to be suppressed....somehow."
	icon_state = "sniper"
	weapon_weight = WEAPON_HEAVY
	inhand_icon_state = "sniper"
	worn_icon_state = null
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	fire_sound_volume = 90
	load_sound = 'sound/weapons/gun/sniper/mag_insert.ogg'
	rack_sound = 'sound/weapons/gun/sniper/rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	recoil = 2
	accepted_magazine_type = /obj/item/ammo_box/magazine/sniper_rounds
	internal_magazine = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK
	mag_display = TRUE
	tac_reloads = TRUE
	rack_delay = 1 SECONDS
	can_suppress = TRUE
	can_unsuppress = TRUE
	suppressor_x_offset = 3
	suppressor_y_offset = 3

/obj/item/gun/ballistic/rifle/sniper_rifle/examine(mob/user)
	. = ..()
	. += span_warning("<b>It seems to have a warning label:</b> Do NOT, under any circumstances, attempt to 'quickscope' with this rifle.")

/obj/item/gun/ballistic/rifle/sniper_rifle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 7) //enough range to at least make extremely good use of the penetrator rounds

/obj/item/gun/ballistic/rifle/sniper_rifle/reset_semicd()
	. = ..()
	if(suppressed)
		playsound(src, 'sound/machines/eject.ogg', 25, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	else
		playsound(src, 'sound/machines/eject.ogg', 50, TRUE)

/obj/item/gun/ballistic/rifle/sniper_rifle/syndicate
	desc = "A boltaction anti-materiel rifle, utilizing .50 BMG cartridges. While technically outdated in modern arms markets, it still works exceptionally well as \
		an anti-personnel rifle. In particular, the employment of modern armored MODsuits utilizing advanced armor plating has given this weapon a new home on the battlefield. \
		It is also able to be suppressed....somehow. This one seems to have a little picture of someone in a blood-red MODsuit stenciled on it, pointing at a green floppy disk. \
		Who knows what that might mean."
	pin = /obj/item/firing_pin/implant/pindicate


/// Blueshift guns
///	Currently nonexistent in code, some day I hope to convert this to 6.5 anti-xeno and get a slick mining rifle


/obj/item/gun/ballistic/rifle/boltaction/sporterized
	name = "\improper Rengo Precision Rifle"
	desc = "A heavily modified Sakhno rifle, parts made by Xhihao light arms based around Jupiter herself. \
		Has a higher capacity than standard Sakhno rifles, fitting ten .310 cartridges."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/guns40x.dmi'
	icon_state = "rengo"
	inhand_icon_state = "moistnugget"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/bubba
	can_be_sawn_off = FALSE
	knife_x_offset = 35

/obj/item/gun/ballistic/rifle/boltaction/sporterized/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/scope, range_modifier = 1.5)

/obj/item/gun/ballistic/rifle/boltaction/sporterized/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_XHIHAO)

/obj/item/gun/ballistic/rifle/boltaction/sporterized/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>examine closer</b> to learn a little more about this weapon.")

/obj/item/gun/ballistic/rifle/boltaction/sporterized/examine_more(mob/user)
	. = ..()

	. += "The Xhihao 'Rengo' conversion rifle. Came as parts sold in a single kit by Xhihao Light Arms, \
		which can be swapped out with many of the outdated or simply old parts on a typical Sakhno rifle. \
		While not necessarily increasing performance in any way, the magazine is slightly longer. The weapon \
		is also overall a bit shorter, making it easier to handle for some people. Cannot be sawn off, cutting \
		really any part of this weapon off would make it non-functional."

	return .

/obj/item/gun/ballistic/rifle/boltaction/sporterized/empty
	bolt_locked = TRUE // so the bolt starts visibly open
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/bubba/empty

/obj/item/ammo_box/magazine/internal/boltaction/bubba
	name = "Sakhno extended internal magazine"
	desc = "How did you get it out?"
	ammo_type = /obj/item/ammo_casing/strilka310
	caliber = CALIBER_STRILKA310
	max_ammo = 10

/obj/item/ammo_box/magazine/internal/boltaction/bubba/empty
	start_empty = TRUE

/*
*	Box that contains Sakhno rifles, but less soviet union since we don't have one of those
*/

/obj/item/storage/toolbox/guncase/soviet/sakhno
	desc = "A weapon's case. This one is green and looks pretty old, but is otherwise in decent condition."
	icon = 'icons/obj/storage/case.dmi'
	material_flags = NONE // ????? Why do these have materials enabled??


//.45 Long Lever-Rifle, cargo cowboy gun, used to be a shotgun, this makes more sense.
/obj/item/gun/ballistic/rifle/leveraction
	name = "brush gun"
	desc = "While lever-actions have been horribly out of date for hundreds of years now, \
	putting a nicely sized hole in a man-sized target with a .45 Long round has stayed relatively timeless."
	icon_state = "brushgun"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	bolt_wording = "Lever"
	bolt_type = BOLT_TYPE_STANDARD
	cartridge_wording = "bullet"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/levergun
	projectile_wound_bonus = 10
	projectile_damage_multiplier = 1.4
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 = CONDUCT_1
	semi_auto = FALSE
	internal_magazine = TRUE
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	pb_knockback = 0
	need_bolt_lock_to_interact = FALSE
	box_reload_delay = CLICK_CD_MELEE



//Stupid OP mining rifle, WARNING, FIRES PLASMA NOT BULLETS     probably the singlehandedly most expensive weapon a miner can buy, and for good reason
/obj/item/gun/ballistic/rifle/minerjdj
	name = ".950 JDJ 'Thor' Kinetic Rifle"
	desc = "Completely absurd, in both size and firepower. The people down in Mining Research were either overcompensating, \
	or just having a damn good time, but we found this laying on a table surrounded by about six researchers, \
	and the Mining Research Director, all passed out on the floor with beers and sodas. Fires an absolutely massive round that \
	is sure to stop pretty much anything in its tracks that would even warrent it."
	icon_state = "fatmac"
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	inhand_icon_state = "fatmac"
	worn_icon = 'icons/mob/clothing/back.dmi'
	worn_icon_state = "fatmac"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/minerjdj
	bolt_wording = "bolt"
	bolt_type = BOLT_TYPE_LOCKING
	semi_auto = FALSE
	recoil = 8 //ow my back
	fire_sound = 'monkestation/sound/weapons/gun/shotgun/quadfire.ogg'
	fire_sound_volume = 200 // L O U D
	rack_sound = 'monkestation/sound/weapons/gun/shotgun/quadrack.ogg'
	bolt_drop_sound = 'monkestation/sound/weapons/gun/shotgun/quadinsert.ogg'
	need_bolt_lock_to_interact = TRUE
	pin = /obj/item/firing_pin/wastes //hey so yeah did you see how much damage the bullet this thing fires does ok cool so you know why this is NEVER EVER coming off

