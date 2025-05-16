/obj/item/magic_broom
	name = "Magic Broomstick"
	desc = "A magic broomstick perfect for aspiring witches or wizards."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "magic_broom"
	inhand_icon_state = "magic_broom"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	force = 12

/obj/item/magic_broom/examine_more(mob/user)
	. = ..()
	. += span_notice("It has the name \"Shion\" carved into the handle.")

/obj/item/magic_broom/attack_self(mob/user)
	var/obj/vehicle/ridden/magic_broom/magic_broom_undeployed = new(user.loc, src)
	magic_broom_undeployed.add_fingerprint(user)

/datum/armor/magic_broom
	melee = 40
	bullet = 40
	laser = 40
	bomb = 20
	fire = 100
	acid = 100

/obj/vehicle/ridden/magic_broom
	name = "Magic Broom"
	desc = "Wow! it really is magic!"
	icon_state = "broom"
	max_integrity = 150
	armor_type = /datum/armor/magic_broom
	var/obj/item/folded_item
	var/delay_multiplier = 1.5
	var/overlay_icon = "broom_overlay"
	var/image/broom_overlay

/obj/vehicle/ridden/magic_broom/Initialize(mapload, obj/item/folded_item)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/magic_broom)
	broom_overlay = image(icon, overlay_icon, ABOVE_MOB_LAYER)
	ADD_TRAIT(src, TRAIT_NO_IMMOBILIZE, INNATE_TRAIT)
	AddComponent(/datum/component/simple_rotation) //rotation for roleplay
	if(!QDELETED(folded_item))
		src.folded_item = folded_item
		folded_item.forceMove(src)

/obj/vehicle/ridden/magic_broom/Destroy(force)
	QDEL_NULL(broom_overlay)
	folded_item = null
	return ..()

/obj/vehicle/ridden/magic_broom/atom_destruction(damage_flag)
	new /obj/item/stack/sheet/mineral/wood(drop_location(), 3)
	QDEL_NULL(folded_item)
	return ..()

/obj/vehicle/ridden/magic_broom/Move(newloc, move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/magicbroom_trail(loc,move_dir)
	return ..()

/obj/vehicle/ridden/magic_broom/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!forced && !check_move_loop_flags(MOVEMENT_LOOP_DRAGGING))
		playsound(src, 'sound/effects/space_wind.ogg', 50, TRUE)

/obj/vehicle/ridden/magic_broom/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		. += broom_overlay

/obj/vehicle/ridden/magic_broom/post_buckle_mob(mob/living/user)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/vehicle/ridden/magic_broom/post_unbuckle_mob()
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/vehicle/ridden/magic_broom/MouseDrop(over_object, src_location, over_location)  //for picking up your floating broom i guess
	. = ..()
	if(over_object != usr || !Adjacent(usr) || QDELETED(folded_item))
		return FALSE
	if(!ishuman(usr) || !usr.can_perform_action(src))
		return FALSE
	if(has_buckled_mobs())
		return FALSE
	usr.visible_message(span_notice("[usr] picks up [src]."), span_notice("You pick up [src]."))
	folded_item.forceMove(drop_location())
	usr.put_in_hands(folded_item)
	folded_item = null
	qdel(src)
