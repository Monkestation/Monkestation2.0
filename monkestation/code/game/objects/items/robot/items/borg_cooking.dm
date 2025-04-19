/obj/item/borg/apparatus/cooking
	name = "service storage apparatus"
	desc = "A special apparatus for carrying food, bowls, plates, oven trays, soup pots and paper."
	icon = 'monkestation/icons/mob/silicon/robot_items.dmi'
	icon_state = "borg_service_apparatus"
	storable = list(
		/obj/item/food,
		/obj/item/paper,
		/obj/item/plate,
		/obj/item/reagent_containers/cup/bowl,
		/obj/item/reagent_containers/cup/soup_pot,
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
	. += span_notice("<i>Alt-click</i> will drop the currently secured item.")

/obj/item/borg/apparatus/cooking/update_overlays()
	. = ..()
	var/mutable_appearance/arm = mutable_appearance(icon, "borg_hardware_apparatus_arm1")
	if(stored)
		stored.pixel_x = -3
		stored.pixel_y = 0
		if((!istype(stored, /obj/item/plate/oven_tray)) || (!istype(stored, /obj/item/food)))
			arm.icon_state = "borg_hardware_apparatus_arm2"
		var/mutable_appearance/stored_copy = new /mutable_appearance(stored)
		stored_copy.layer = FLOAT_LAYER
		stored_copy.plane = FLOAT_PLANE
		. += stored_copy
	. += arm

//ported from https://github.com/tgstation/tgstation/pull/74938
/obj/item/knife/kitchen/silicon
	name = "Kitchen Toolset"
	icon = 'monkestation/icons/obj/kitchen.dmi'
	icon_state = "sili_knife"
	desc = "A breakthrough in synthetic engineering, this tool is a knife programmed to dull when not used for cooking purposes, and can exchange the blade for a rolling pin"
	force = 0
	throwforce = 0
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
	attack_verb_simple = list("prod", "whiff", "scratch", "poke")
	tool_behaviour = TOOL_KNIFE

/obj/item/knife/kitchen/silicon/examine()
	. = ..()
	. += " It's fitted with a [tool_behaviour] head."

/obj/item/knife/kitchen/silicon/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	if(tool_behaviour != TOOL_ROLLINGPIN)
		tool_behaviour = TOOL_ROLLINGPIN
		to_chat(user, span_notice("You attach the rolling pin bit to the [src]."))
		icon_state = "sili_rolling_pin"
		force = 8
		sharpness = NONE
		hitsound = SFX_SWING_HIT
		attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
		attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	else
		tool_behaviour = TOOL_KNIFE
		to_chat(user, span_notice("You attach the knife bit to the [src]."))
		icon_state = "sili_knife"
		force = 0
		sharpness = SHARP_EDGED
		hitsound = 'sound/weapons/bladeslice.ogg'
		attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
		attack_verb_simple = list("prod", "whiff", "scratch", "poke")

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
