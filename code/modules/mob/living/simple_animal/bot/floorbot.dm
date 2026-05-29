#define HULL_BREACH 1
#define LINE_SPACE_MODE 2
#define FIX_TILE 3
#define AUTO_TILE 4
#define PLACE_TILE 5
#define REPLACE_TILE 6
#define TILE_EMAG 7

//Floorbot
/mob/living/simple_animal/bot/floorbot
	name = "\improper Floorbot"
	desc = "A little floor repairing robot, he looks so excited!"
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "floorbot0"
	density = FALSE
	health = 25
	maxHealth = 25

	req_one_access = list(ACCESS_ROBOTICS, ACCESS_CONSTRUCTION)
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FLOOR_BOT
	hackables = "floor construction protocols"
	path_image_color = "#FFA500"
	possessed_message = "You are a floorbot! Repair the hull to the best of your ability!"

	var/process_type //Determines what to do when process_scan() receives a target. See process_scan() for details.
	var/targetdirection
	var/replacetiles = FALSE
	var/placetiles = FALSE
	var/maxtiles = 100
	var/obj/item/stack/tile/tilestack
	var/fixfloors = TRUE
	var/autotile = FALSE
	var/turf/target
	var/toolbox = /obj/item/storage/toolbox/mechanical
	var/toolbox_color = ""

/mob/living/simple_animal/bot/floorbot/Initialize(mapload, new_toolbox_color)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	toolbox_color = new_toolbox_color
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/engi_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/station_engineer]
	access_card.add_access(engi_trim.access + engi_trim.wildcard_access)
	prev_access = access_card.access.Copy()

	if(toolbox_color == "s")
		health = 100
		maxHealth = 100

/mob/living/simple_animal/bot/floorbot/Exited(atom/movable/gone, direction)
	if(tilestack == gone)
		if(tilestack && tilestack.max_amount < tilestack.amount) //split the stack if it exceeds its normal max_amount
			var/iterations = round(tilestack.amount/tilestack.max_amount) //round() without second arg floors the value
			for(var/a in 1 to iterations)
				if(a == iterations)
					tilestack.split_stack(null, tilestack.amount - tilestack.max_amount)
				else
					tilestack.split_stack(null, tilestack.max_amount)
		tilestack = null

/mob/living/simple_animal/bot/floorbot/turn_on()
	. = ..()
	update_appearance()

/mob/living/simple_animal/bot/floorbot/turn_off()
	..()
	update_appearance()

/mob/living/simple_animal/bot/floorbot/bot_reset()
	..()
	target = null
	toggle_magnet(FALSE)

/mob/living/simple_animal/bot/floorbot/attackby(obj/item/W , mob/user, params)
	if(istype(W, /obj/item/stack/tile/iron))
		to_chat(user, span_notice("The floorbot can produce normal tiles itself."))
		return
	if(istype(W, /obj/item/stack/tile))
		var/old_amount = tilestack ? tilestack.amount : 0
		var/obj/item/stack/tile/tiles = W
		if(tilestack)
			if(!tiles.can_merge(tilestack))
				to_chat(user, span_warning("Different custom tiles are already inside the floorbot."))
				return
			if(tilestack.amount >= maxtiles)
				to_chat(user, span_warning("The floorbot can't hold any more custom tiles."))
				return
			tiles.merge(tilestack, maxtiles)
		else
			if(tiles.amount > maxtiles)
				tilestack = tilestack.split_stack(null, maxtiles)
			else
				tilestack = W
			tilestack.forceMove(src)
		to_chat(user, span_notice("You load [tilestack.amount - old_amount] tiles into the floorbot. It now contains [tilestack.amount] tiles."))
		return
	else
		..()

/mob/living/simple_animal/bot/floorbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	balloon_alert(user, "safeties disabled")
	audible_message(span_danger("[src] buzzes oddly!"))
	return TRUE

///mobs should use move_resist instead of anchored.
/mob/living/simple_animal/bot/floorbot/proc/toggle_magnet(engage = TRUE, change_icon = TRUE)
	if(engage)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT)
		move_resist = INFINITY
		if(change_icon)
			icon_state = "[toolbox_color]floorbot-c"
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT)
		move_resist = initial(move_resist)
		if(change_icon)
			update_icon()

// Variables sent to TGUI
/mob/living/simple_animal/bot/floorbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["custom_controls"]["tile_hull"] = autotile
		data["custom_controls"]["place_tiles"] =  placetiles
		data["custom_controls"]["place_custom"] = replacetiles
		data["custom_controls"]["repair_damage"] = fixfloors
		data["custom_controls"]["traction_magnets"] = !!HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT)
		data["custom_controls"]["tile_stack"] = 0
		data["custom_controls"]["line_mode"] = FALSE
		if(tilestack)
			data["custom_controls"]["tile_stack"] = tilestack.amount
		if(targetdirection)
			data["custom_controls"]["line_mode"] = dir2text(targetdirection)
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/floorbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !HAS_SILICON_ACCESS(user)))
		return

	switch(action)
		if("place_custom")
			replacetiles = !replacetiles
		if("place_tiles")
			placetiles = !placetiles
		if("repair_damage")
			fixfloors = !fixfloors
		if("tile_hull")
			autotile = !autotile
		if("traction_magnets")
			toggle_magnet(!HAS_TRAIT_FROM(src, TRAIT_IMMOBILIZED, BUSY_FLOORBOT_TRAIT), FALSE)
		if("eject_tiles")
			if(tilestack)
				tilestack.forceMove(drop_location())
		if("line_mode")
			var/setdir = tgui_input_list(user, "Select construction direction", "Direction", list("north", "east", "south", "west", "disable"))
			if(isnull(setdir) || QDELETED(ui) || ui.status != UI_INTERACTIVE)
				return
			switch(setdir)
				if("north")
					targetdirection = 1
				if("south")
					targetdirection = 2
				if("east")
					targetdirection = 4
				if("west")
					targetdirection = 8
				if("disable")
					targetdirection = null

/mob/living/simple_animal/bot/floorbot/handle_automated_action()
	return

/**
 * Checks a given turf to see if another floorbot is there, working as well.
 */
/mob/living/simple_animal/bot/floorbot/proc/check_bot_working(turf/active_turf)
	if(isturf(active_turf))
		for(var/mob/living/simple_animal/bot/floorbot/robot in active_turf)
			if(robot.mode == BOT_REPAIRING)
				return TRUE
	return FALSE

#undef HULL_BREACH
#undef LINE_SPACE_MODE
#undef FIX_TILE
#undef AUTO_TILE
#undef PLACE_TILE
#undef REPLACE_TILE
#undef TILE_EMAG
