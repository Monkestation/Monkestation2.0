/obj/item/kinetic_crusher/pilebunker
	icon_state = "pb_spike"
	inhand_icon_state = "pb_spike"
	icon = 'icons/obj/mining 64x.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	name = "proto-kinetic pile bunker"
	desc = "An absolute beast of a crusher, designed to inflict as much damage as possible in a single strike, \
	with little regard for the user's own safety or physical ability to handle the weapon. Takes a short \
	moment to wind up a blow, and the spike has to be retracted after each use."
	force = 0 //You can't hit stuff unless wielded
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = NONE
	base_pixel_x = -5
	pixel_x = -5
	throwforce = 0
	throw_speed = 0
	armour_penetration = 100 //yknow what fuck you, its a pile bunker
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_verb_continuous = list("impales", "stabs", "destroys", "strikes")
	attack_verb_simple = list("impale", "stab", "destroy", "strike")
	sharpness = SHARP_POINTY
	charge_time = 75 //be patient, its alot of damage :)
	detonation_damage = 295 //add the five for a perfect 300 damage, enough to kill all basic enemies
	backstab_bonus = 200 //if you land a backstab it does 500 instead
	overrides_main = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 5 //hit the crusher mark or suffer no damage
	var/armed = FALSE //is the weapon armed?
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/pilebunker/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)

/obj/item/kinetic_crusher/pilebunker/attack(mob/living/target, mob/living/carbon/user)
	if(!armed)
		to_chat(user, span_warning("The pilebunker is not armed, re-arm it! (Right click while unarmed!)"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		to_chat(user, span_warning("[src] is too heavy to use with one hand! You fumble and drop everything."))
		user.drop_all_held_items()
		return COMPONENT_CANCEL_ATTACK_CHAIN
	user.visible_message(
		span_boldwarning("[user] plants their feet firmly to the ground and  winds up an attack!"),
		span_boldwarning("You plant your feet firmly to the ground and wind up an attack!"),
	)
	if(do_after(user, 1 SECOND, src) && (get_dist(user, target) <= 1))
		armed = FALSE
		update_appearance()
		var/datum/status_effect/crusher_damage/C = target.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = target.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = target.health
		..()
		for(var/t in trophies)
			if(!QDELETED(target))
				var/obj/item/crusher_trophy/T = t
				T.on_melee_hit(target, user)
		if(!QDELETED(C) && !QDELETED(target))
			C.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did
	else
		user.visible_message(
			span_boldwarning("[user] stumbles as their stance is broken!"),
			span_boldwarning("You stumble as your stance is broken!"),
		)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/kinetic_crusher/pilebunker/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(/datum/status_effect/crusher_mark)
		if(!CM || !L.remove_status_effect(/datum/status_effect/crusher_mark))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health
				playsound(user, 'sound/weapons/blastcannon.ogg', 100, TRUE)
				shake_camera(user, 10, 3)
				var/atom/throw_target = get_edge_target_turf(user, get_dir(target, user))
				user.throw_at(throw_target, 3, 5, gentle = FALSE)
			new /obj/effect/temp_visual/explosion/fast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
			if(!QDELETED(C))
				C.total_damage += combined_damage
			SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/kinetic_crusher/pilebunker/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!armed)
		playsound(user, 'sound/mecha/hydraulic.ogg', 100, TRUE)
		if(do_after(user, 3 SECONDS, src, IGNORE_USER_LOC_CHANGE | IGNORE_SLOWDOWNS))
			armed = TRUE
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		balloon_alert(user, "wield it first!")
		return ITEM_INTERACT_BLOCKING
	if(interacting_with == user)
		balloon_alert(user, "can't aim at yourself!")
		return ITEM_INTERACT_BLOCKING
	fire_kinetic_blast(interacting_with, user, modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	return ITEM_INTERACT_SUCCESS

/obj/item/kinetic_crusher/pilebunker/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/kinetic_crusher/pilebunker/update_icon_state()
	if(!armed)
		icon_state = "pb_spike"
		inhand_icon_state = "pb_spike"
	else
		icon_state = "pb"
		inhand_icon_state = "pb"
	return ..()

//ADMIN ONLY PILE BUNKER THAT DOES WHAT YOU WOULD EXPECT OTHER THAN SHIT CODE

/obj/item/kinetic_crusher/adminpilebunker
	icon_state = "THEpilebunker_spike"
	inhand_icon_state = "THEpilebunker_spike"
	icon = 'icons/obj/mining 256x32.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/256x32_melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/256x32_melee_righthand.dmi'
	name = "Somewhat Long Pilebunker"
	desc = "Mining RND broke the fabric of reality, and uh... made... this slightly more penetrative pilebunker... that works on people... \
	Please return this to your nearest CC officer. how do they even manage this..."
	force = 100
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = ""
	slot_flags = NONE
	base_pixel_x = -126
	pixel_x = -126
	inhand_x_dimension = -194
	armour_penetration = 1000
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_verb_continuous = list("absolutely obliterates")
	attack_verb_simple = list("absolutely obliterates")
	sharpness = SHARP_EDGED
	charge_time = 0.01
	detonation_damage = 10000
	backstab_bonus = 10000
	reach = 10
	overrides_main = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 100
	var/armed = FALSE
	crusher_destabilizer = /obj/projectile/destabilizer/admin

/obj/item/kinetic_crusher/adminpilebunker/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)

/obj/item/kinetic_crusher/adminpilebunker/attack(mob/living/target, mob/living/carbon/user)
	if(!armed)
		to_chat(user, span_warning("The pilebunker is not armed, re-arm it! (Right click while unarmed!)"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		to_chat(user, span_warning("[src] is too heavy to use with one hand! You fumble and drop everything."))
		user.drop_all_held_items()
		return COMPONENT_CANCEL_ATTACK_CHAIN
	user.visible_message(
		span_boldwarning("[user] plants their feet firmly to the ground and  winds up an attack!"),
		span_boldwarning("You plant your feet firmly to the ground and wind up an attack!"),
	)
	armed = FALSE
	update_appearance()
	var/datum/status_effect/crusher_damage/C = target.has_status_effect(/datum/status_effect/crusher_damage)
	if(!C)
		C = target.apply_status_effect(/datum/status_effect/crusher_damage)
	var/target_health = target.health
	..()
	for(var/t in trophies)
		if(!QDELETED(target))
			var/obj/item/crusher_trophy/T = t
			T.on_melee_hit(target, user)
	if(!QDELETED(C) && !QDELETED(target))
		C.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did

/obj/item/kinetic_crusher/adminpilebunker/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/admin/CM = L.has_status_effect(/datum/status_effect/crusher_mark/admin)
		if(!CM || L.remove_status_effect(/datum/status_effect/crusher_mark/admin))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health
				playsound(user, 'sound/weapons/blastcannon.ogg', 100, TRUE)
				var/atom/throw_target = get_edge_target_turf(user, get_dir(target, user))
				user.throw_at(throw_target, 100, 1000, gentle = FALSE)
			new /obj/effect/temp_visual/explosion/fast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
			if(!QDELETED(C))
				C.total_damage += combined_damage
			SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/kinetic_crusher/adminpilebunker/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!armed)
		playsound(user, 'sound/mecha/hydraulic.ogg', 100, TRUE)
		if(do_after(user, 0.1 SECONDS, src, IGNORE_USER_LOC_CHANGE | IGNORE_SLOWDOWNS))
			armed = TRUE
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		balloon_alert(user, "wield it first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(interacting_with == user)
		balloon_alert(user, "can't aim at yourself!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	fire_kinetic_blast(interacting_with, user, modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/kinetic_crusher/adminpilebunker/update_icon_state()
	if(!armed)
		icon_state = "THEpilebunker_spike"
		inhand_icon_state = "THEpilebunker_spike"
	else
		icon_state = "THEpilebunker"
		inhand_icon_state = "THEpilebunker"
	return ..()

//destablizing force that can mark people
/obj/projectile/destabilizer/admin
	name = "death force"
	icon_state = "pulse1"
	range = 50

/obj/projectile/destabilizer/admin/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/crusher_mark/admin, boosted)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		new /obj/effect/temp_visual/kinetic_blast(M)
		M.gets_drilled(firer)
	..()
