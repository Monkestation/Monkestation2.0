/obj/item/gun/ballistic/bow/shadow_caster
	name = "shadow caster"
	desc = "A bow made of solid darkness. The arrows it shoots seem to suck light out of the surroundings."
	icon = 'icons/obj/darkspawn_items.dmi'
	icon_state = "shadow_caster"
	worn_icon_state = "shadow_caster"
	lefthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/darkspawn/darkspawn_righthand.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/bow/shadow
	pin = /obj/item/firing_pin/magic
	var/recharge_time = 2 SECONDS
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/ballistic/bow/shadow_caster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/gun/ballistic/bow/shadow_caster/afterattack(atom/target, mob/living/user, flag, params, passthrough)
	if(!drawn || !chambered)
		to_chat(user, span_notice("[src] must be drawn to fire a shot!"))
		return
	return ..()

/obj/item/gun/ballistic/bow/shadow_caster/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(recharge_bolt)), recharge_time)
	recharge_time = initial(recharge_time)

/// Recharges a bolt, done after the delay in shoot_live_shot
/obj/item/gun/ballistic/bow/shadow_caster/proc/recharge_bolt()
	var/obj/item/ammo_casing/caseless/arrow/shadow/bolt = new
	magazine.give_round(bolt)
	chambered = bolt
	update_icon()

// the thing that holds the ammo inside the bow
/obj/item/ammo_box/magazine/internal/bow/shadow
	ammo_type = /obj/item/ammo_casing/caseless/arrow/shadow

//the object that appears when the arrow finishes flying
/obj/item/ammo_casing/caseless/arrow/shadow
	name = "shadow arrow"
	desc = "it seem to suck light out of the surroundings."
	icon = 'icons/obj/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	inhand_icon_state = "caster_arrow"
	embedding = list("embed_chance" = 20, "embedded_fall_chance" = 0) //always embeds if it hits someone
	projectile_type = /obj/projectile/energy/shadow_arrow

//the projectile being shot from the bow
/obj/projectile/energy/shadow_arrow
	name = "shadow arrow"
	icon = 'icons/obj/darkspawn_projectiles.dmi'
	icon_state = "caster_arrow"
	damage = 20 //reduced damage per arrow compared to regular ones

/obj/projectile/bullet/reusable/arrow/shadow/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/projectile/bullet/reusable/arrow/shadow/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src)
