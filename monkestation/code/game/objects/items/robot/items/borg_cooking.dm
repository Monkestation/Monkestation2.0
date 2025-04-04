/obj/item/borg/apparatus/cooking
	name = "service storage apparatus"
	desc = "A special apparatus for carrying food, seeds, and biocubes."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "borg_beaker_apparatus"
	storable = list(
		/obj/item/food,
		/obj/item/seeds,
		/obj/item/stack/biocube,
	)

/obj/item/borg/apparatus/cooking/Initialize(mapload)
	RegisterSignal(stored, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_stored_updated_icon))
	update_appearance()
	return ..()

/obj/item/borg/apparatus/cooking/pre_attack(atom/atom, mob/living/user, params)
	if(!stored)
		var/itemcheck = FALSE
		for(var/storable_type in storable)
			if(istype(atom, storable_type))
				itemcheck = TRUE
				break
		if(itemcheck)
			var/obj/item/item = atom
			item.forceMove(src)
			stored = item
			RegisterSignal(stored, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_stored_updated_icon))
			update_appearance()
			return TRUE
		else
			return ..()
	else
		stored.pre_attack(atom, user, params) //this might be a terrible idea
		atom.attackby(stored, user, params)
		return TRUE

/obj/item/borg/apparatus/cooking/examine()
	. = ..()
	if(stored)
		. += "The apparatus currently has [stored] secured."

/obj/item/borg/apparatus/cooking/update_overlays()
	. = ..()
	var/mutable_appearance/arm = mutable_appearance(icon = icon, icon_state = "borg_beaker_apparatus_arm")
	if(stored)
		stored.pixel_x = 0
		stored.pixel_y = 0
		var/mutable_appearance/stored_copy = new /mutable_appearance(stored)
		stored_copy.layer = FLOAT_LAYER
		stored_copy.plane = FLOAT_PLANE
		. += stored_copy
	else
		arm.pixel_y = arm.pixel_y - 5
	. += arm

//indestructible plastic knife for borgs, was originally supposed to break but regen when you recharge, but i genuinely would rather jump out an airlock than try to understand how the fuck modules work.
/obj/item/knife/borg
	name = "plastic knife"
	icon_state = "plastic_knife"
	inhand_icon_state = "knife"
	desc = "A very safe, barely sharp knife made of plastic. Good for cutting food and not much else. It seems far more durable than usual."
	force = 0
	w_class = WEIGHT_CLASS_TINY
	custom_materials = null //do not fucking put your knife in an autolathe dumbass
	attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
	attack_verb_simple = list("prod", "whiff", "scratch", "poke")
	sharpness = SHARP_EDGED

//lets borgs interact with ovens and griddles.
/obj/machinery/griddle/attack_robot(mob/user) //griddles seem like they could be controlled from afar
	. = ..()
	attack_hand(user)
	return TRUE

/obj/machinery/oven/attack_robot(mob/user)
	. = ..()
	if(user.Adjacent(src))
		attack_hand(user)
	return TRUE

/obj/machinery/oven/attack_robot_secondary(mob/user, list/modifiers) //stoves too
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	attack_hand_secondary(user, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/stove/attack_robot(mob/user)
	. = ..()
	attack_hand(user)
	return TRUE

//lets borgs interact with the botany composter
/obj/machinery/composters/attack_robot(mob/user)
	. = ..()
	if(user.Adjacent(src))
		attack_hand(user)
	return TRUE
