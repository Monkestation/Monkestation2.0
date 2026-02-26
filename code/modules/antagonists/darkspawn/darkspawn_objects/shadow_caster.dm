/obj/item/gun/ballistic/bow/shadow_caster
	name = "shadow caster"
	desc = "A bow made of solid darkness. The arrows it shoots seem to suck light out of the surroundings."
	icon = 'icons/obj/darkspawn_items.dmi'
	icon_state = "shadow_caster_unchambered_undrawn"
	inhand_icon_state = "shadow_caster"
	base_icon_state = "shadow_caster"
	lefthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_righthand.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/bow/shadow
	pin = /obj/item/firing_pin/magic
	var/recharge_time = 2 SECONDS
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	nodrop = TRUE

/obj/item/gun/ballistic/bow/shadow_caster/Initialize(mapload)
	. = ..()
	update_icon_state()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/light_eater)


/obj/item/gun/ballistic/bow/shadow_caster/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(recharge_bolt)), recharge_time)
	recharge_time = initial(recharge_time)

/obj/item/gun/ballistic/bow/shadow_caster/attack_self(mob/living/user)
	if(drawn || !chambered)
		return

	to_chat(user, span_notice("You draw back the bowstring."))
	drawn = TRUE
	playsound(src, 'sound/weapons/draw_bow.ogg', 75, 0) //gets way too high pitched if the freq varies
	update_icon()



/obj/item/gun/ballistic/bow/shadow_caster/attackby(obj/item/I, mob/user, params)
	return

/// Recharges a bolt, done after the delay in shoot_live_shot
/obj/item/gun/ballistic/bow/shadow_caster/proc/recharge_bolt()
	var/obj/item/ammo_casing/caseless/arrow/shadow/bolt = new
	magazine.give_round(bolt)
	chambered = bolt
	update_icon()

/obj/item/gun/ballistic/bow/shadow_caster/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[chambered ? "chambered" : "unchambered"]_[drawn ? "drawn" : "undrawn"]"

// the thing that holds the ammo inside the bow
/obj/item/ammo_box/magazine/internal/bow/shadow
	ammo_type = /obj/item/ammo_casing/caseless/arrow/shadow
	start_empty = FALSE

//the object that appears when the arrow finishes flying
/obj/item/ammo_casing/caseless/arrow/shadow
	name = "shadow arrow"
	desc = "it seems to suck light out of the surroundings."
	icon = 'icons/obj/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	inhand_icon_state = null
	embedding = list("embed_chance" = 20, "embedded_fall_chance" = 0)
	projectile_type = /obj/projectile/bullet/shadow_arrow

//the projectile being shot from the bow
/obj/projectile/bullet/shadow_arrow
	name = "shadow arrow"
	icon = 'icons/obj/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	damage = 25 //reduced damage per arrow compared to regular ones
	damage_type = BURN
	wound_bonus = -100
	embedding = list("embed_chance" = 20, "embedded_fall_chance" = 0)

/obj/projectile/bullet/shadow_arrow/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/projectile/bullet/shadow_arrow/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)
