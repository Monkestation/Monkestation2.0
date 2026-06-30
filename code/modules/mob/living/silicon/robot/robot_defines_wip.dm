/// Applies a skin to the cyborg.
/mob/living/silicon/robot/proc/apply_skin(datum/robot_skin/applied_skin)
	if(current_skin)
		remove_traits(current_skin.traits, REF(current_skin))
	if(ispath(applied_skin))
		applied_skin = new
	current_skin = applied_skin
	icon = current_skin.icon
	icon_state = applied_skin.icon_state
	base_pixel_x = current_skin.base_pixel_x
	base_pixel_y = current_skin.base_pixel_y
	if(hat && isnull(applied_skin.hat_offset))
		if(HAS_TRAIT(hat, TRAIT_NODROP)) // Highlander's hat.
			qdel(hat)
		else
			hat.forceMove(drop_location())
	if(isnull(applied_skin.badge_offset) && worn_badge)
		if(HAS_TRAIT(worn_badge, TRAIT_NODROP))
			qdel(worn_badge)
		else
			worn_badge.forceMove(drop_location())
	add_traits(current_skin.traits, REF(current_skin))
	update_icons()

/mob/living/silicon/robot/regenerate_icons()
	return update_icons()

/mob/living/silicon/robot/update_icons()
	icon_state = current_skin.icon_state
	update_appearance(UPDATE_OVERLAYS)

/mob/living/silicon/robot/update_overlays()
	. = ..()
	if(stat != DEAD && !(HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || IsStun() || IsParalyzed() || low_power_mode)) // Not dead, not stunned.
		if(!eye_lights)
			eye_lights = new()
		if(lamp_enabled || lamp_doom)
			eye_lights.icon_state = "[current_skin.icon_state_light]_l"
			eye_lights.color = lamp_doom ? COLOR_RED : lamp_color
			set_light_range(max(MINIMUM_USEFUL_LIGHT_RANGE, lamp_intensity))
			set_light_color(lamp_doom ? COLOR_RED : lamp_color) //Red for doomsday killborgs, borg's choice otherwise
			SET_PLANE_EXPLICIT(eye_lights, ABOVE_LIGHTING_PLANE, src) //glowy eyes
		else
			eye_lights.icon_state = "[current_skin.icon_state_light]_e"
			eye_lights.color = COLOR_WHITE
			SET_PLANE_EXPLICIT(eye_lights, ABOVE_GAME_PLANE, src)
		eye_lights.icon = icon
		. += eye_lights
	if(opened)
		if(wiresexposed)
			. += "[current_skin.icon_state_cover]-opencover +w"
		else if(cell)
			. += "[current_skin.icon_state_cover]-opencover +c"
		else
			. += "[current_skin.icon_state_cover]-opencover -c"
	if(hat)
		var/mutable_appearance/head_overlay = hat.build_worn_icon(default_layer = 20, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		head_overlay.pixel_z += current_skin.hat_offset
		. += head_overlay
	if(worn_badge)
		var/mutable_appearance/accessory_overlay = mutable_appearance(worn_badge.worn_icon, worn_badge.icon_state)
		accessory_overlay.pixel_z += current_skin.badge_offset
		. += accessory_overlay

/mob/living/silicon/robot/model
	model = /datum/robot_model/default
	current_skin = /datum/robot_skin/standard/default

/mob/living/silicon/robot/model/centcom
	model = /datum/robot_model/centcom
	current_skin = /datum/robot_skin/centcom/default
	icon_state = "centcomborg"

/mob/living/silicon/robot/model/clown
	model = /datum/robot_model/clown
	current_skin = /datum/robot_skin/clown/default
	icon_state = "clown"

/mob/living/silicon/robot/model/engineering
	model = /datum/robot_model/engineering
	current_skin = /datum/robot_skin/engineering/default
	icon_state = "engineering"

/mob/living/silicon/robot/model/highlander
	model = /datum/robot_model/highlander
	current_skin = /datum/robot_skin/highlander/default
	icon_state = "kilt"

/mob/living/silicon/robot/model/janitor
	model = /datum/robot_model/janitor
	current_skin = /datum/robot_skin/janitor/default
	icon_state = "janitor"

/mob/living/silicon/robot/model/medical
	model = /datum/robot_model/medical
	current_skin = /datum/robot_skin/miner/default
	icon_state = "medical"

/mob/living/silicon/robot/model/miner
	model = /datum/robot_model/miner
	current_skin = /datum/robot_skin/miner/default
	icon_state = "miner"

/mob/living/silicon/robot/model/peacekeeper
	model = /datum/robot_model/peacekeeper
	current_skin = /datum/robot_skin/peacekeeper/default
	icon_state = "peace"

/mob/living/silicon/robot/model/science
	model = /datum/robot_model/science
	icon_state = "science"

/mob/living/silicon/robot/model/security
	model = /datum/robot_model/security
	icon_state = "security"

/mob/living/silicon/robot/model/service
	model = /datum/robot_model/service
	icon_state = "service"

/mob/living/silicon/robot/model/standard
	model = /datum/robot_model/standard
	icon_state = "standard"

/mob/living/silicon/robot/model/syndicate
	icon_state = "synd_sec"
	faction = list(ROLE_SYNDICATE)
	bubble_icon = "syndibot"
	req_access = list(ACCESS_SYNDICATE)
	lawupdate = FALSE
	scrambledcodes = TRUE // These are rogue borgs.
	ionpulse = TRUE
	model = /datum/robot_model/syndicate
	cell = /obj/item/stock_parts/power_store/cell/hyper
	radio = /obj/item/radio/borg/syndicate
	var/playstyle_string = "<span class='big bold'>You are a Syndicate assault cyborg!</span><br>\
		<b>You are armed with powerful offensive tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
		Your cyborg LMG will slowly produce ammunition from your power supply, and your operative pinpointer will find and locate fellow nuclear operatives. \
		<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/model/syndicate/Initialize(mapload)
	laws = new /datum/ai_laws/syndicate_override()
	laws.associate(src)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_playstyle)), 0.5 SECONDS)

/mob/living/silicon/robot/model/syndicate/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/pda/silicon/cyborg/syndicate(src)
		modularInterface.imprint_id(job_name = "Cyborg")
	return ..()

/mob/living/silicon/robot/model/syndicate/proc/show_playstyle()
	if(!playstyle_string)
		return
	to_chat(src, playstyle_string)

/mob/living/silicon/robot/model/syndicate/ResetModel()
	return

/mob/living/silicon/robot/model/syndicate/medical
	model = /datum/robot_model/syndicate_medical
	icon_state = "synd_medical"
	playstyle_string = "<span class='big bold'>You are a Syndicate medical cyborg!</span><br>\
		<b>You are armed with powerful medical tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
		Your hypospray will produce Restorative Nanites, a wonder-drug that will heal most types of bodily damages, including clone and brain damage. It also produces morphine for offense. \
		Your defibrillator paddles can revive operatives through their suits, or can be used on harm intent to shock enemies! \
		Your energy saw functions as a circular saw, but can be activated to deal more damage, and your operative pinpointer will find and locate fellow nuclear operatives. \
		<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/model/syndicate/saboteur
	model = /datum/robot_model/syndicate_saboteur
	icon_state = "synd_engi"
	playstyle_string = "<span class='big bold'>You are a Syndicate saboteur cyborg!</span><br>\
		<b>You are armed with robust engineering tools to aid you in your mission: help the operatives secure the nuclear authentication disk. \
		Your destination tagger will allow you to stealthily traverse the disposal network across the station \
		Your welder will allow you to repair the operatives' exosuits, but also yourself and your fellow cyborgs \
		Your cyborg chameleon projector allows you to assume the appearance and registered name of a Nanotrasen engineering borg, and undertake covert actions on the station \
		Be aware that almost any physical contact or incidental damage will break your camouflage \
		<i>Help the operatives secure the disk at all costs!</i></b>"

/mob/living/silicon/robot/model/syndicate/saboteur/operative
	playstyle_string = "<span class='big bold'>You are a Syndicate saboteur cyborg!</span><br>\
		<b>You are armed with robust engineering tools to aid you in your mission: help the operatives secure the golden eye authentication disks. \
		Your destination tagger will allow you to stealthily traverse the disposal network across the station \
		Your welder will allow you to repair yourself and your fellow cyborgs.  \
		Your cyborg chameleon projector allows you to assume the appearance and registered name of a Nanotrasen engineering borg, and undertake covert actions on the station \
		Be aware that almost any physical contact or incidental damage will break your camouflage \
		<i>Help the operatives secure the disks at all costs!</i></b>"
