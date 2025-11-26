
/obj/item/gun/ballistic/rifle/rebarxbow
	name = "heated rebar crossbow"
	desc = "A handcrafted crossbow. \
		   Aside from conventional sharpened iron rods, it can also fire specialty ammo made from the atmos crystalizer - zaukerite, metallic hydrogen, and healium rods all work. \
		   Very slow to reload - you can craft the crossbow with a crowbar to loosen the crossbar, but risk a misfire, or worse..."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "rebarxbow"
	base_icon_state = "rebarxbow"
	inhand_icon_state = "rebarxbow"
	worn_icon_state = "rebarxbow"
	rack_sound = 'sound/weapons/gun/sniper/rack.ogg'
	mag_display = FALSE
	empty_indicator = TRUE
	bolt_type = BOLT_TYPE_OPEN
	semi_auto = FALSE
	internal_magazine = TRUE
	can_modify_ammo = FALSE
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_SUITSTORE
	bolt_wording = "bowstring"
	magazine_wording = "rod"
	cartridge_wording = "rod"
	weapon_weight = WEAPON_HEAVY
	initial_caliber = CALIBER_REBAR
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/normal
	fire_sound = 'sound/items/xbow_lock.ogg'
	can_be_sawn_off = FALSE
	tac_reloads = FALSE
	var/draw_time = 3 SECONDS
	SET_BASE_PIXEL(0, 0)
	need_bolt_lock_to_interact = FALSE

/obj/item/gun/ballistic/rifle/rebarxbow/rack(mob/user = null)
	if (bolt_locked)
		drop_bolt(user)
		return
	balloon_alert(user, "bowstring loosened")
	playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	handle_chamber(empty_chamber =  FALSE, from_firing = FALSE, chamber_next_round = FALSE)
	bolt_locked = TRUE
	update_appearance()

/obj/item/gun/ballistic/rifle/rebarxbow/drop_bolt(mob/user = null)
	if(!do_after(user, draw_time, target = src))
		return
	playsound(src, bolt_drop_sound, bolt_drop_sound_volume, FALSE)
	balloon_alert(user, "bowstring drawn")
	chamber_round()
	bolt_locked = FALSE
	update_appearance()

/obj/item/gun/ballistic/rifle/rebarxbow/shoot_live_shot(mob/living/user)
	..()
	rack()

/obj/item/gun/ballistic/rifle/rebarxbow/can_shoot()
	if (bolt_locked)
		return FALSE
	return ..()

/obj/item/gun/ballistic/rifle/rebarxbow/shoot_with_empty_chamber(mob/living/user)
	if(chambered || !magazine || !length(magazine.contents))
		return ..()
	drop_bolt(user)

/obj/item/gun/ballistic/rifle/rebarxbow/examine(mob/user)
	. = ..()
	. += "The crossbow is [bolt_locked ? "not ready" : "ready"] to fire."

/obj/item/gun/ballistic/rifle/rebarxbow/update_overlays()
	. = ..()
	if(!magazine)
		. += "[base_icon_state]" + "_empty"
	if(!bolt_locked)
		. += "[base_icon_state]" + "_bolt_locked"

/obj/item/gun/ballistic/rifle/rebarxbow/forced
	name = "stressed rebar crossbow"
	desc = "Some idiot decided that they would risk shooting themselves in the face if it meant they could have a draw this crossbow a bit faster. Hopefully, it was worth it."
	// Feel free to add a recipe to allow you to change it back if you would like, I just wasn't sure if you could have two recipes for the same thing.
	can_misfire = TRUE
	draw_time = 1.5
	misfire_probability = 25
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/force

/obj/item/gun/ballistic/rifle/rebarxbow/syndie
	name = "syndicate rebar crossbow"
	desc = "The syndicate liked the bootleg rebar crossbow NT engineers made, so they showed what it could be if properly developed. \
			Holds three shots without a chance of exploding, and features a built in scope. Compatible with all known crossbow ammunition."
	base_icon_state = "rebarxbowsyndie"
	icon_state = "rebarxbowsyndie"
	inhand_icon_state = "rebarxbowsyndie"
	worn_icon_state = "rebarxbowsyndie"
	w_class = WEIGHT_CLASS_NORMAL
	initial_caliber = CALIBER_REBAR
	draw_time = 1
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/syndie

/obj/item/gun/ballistic/rifle/rebarxbow/syndie/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 2) //enough range to at least be useful for stealth


/obj/item/gun/ballistic/rifle/boltaction/harpoon
	name = "ballistic harpoon gun"
	desc = "A weapon favored by carp hunters, but just as infamously employed by agents of the Animal Rights Consortium against human aggressors. Because it's ironic."
	icon_state = "speargun"
	inhand_icon_state = "speargun"
	worn_icon_state = "speargun"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/boltaction/harpoon
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	can_be_sawn_off = FALSE

/obj/item/gun/ballistic/rifle/boltaction/harpoon/give_manufacturer_examine()
	return
