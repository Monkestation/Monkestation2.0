#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"

/obj/item/door_remote
	icon_state = "remote_omni_open"
	base_icon_state = "remote"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon = 'icons/obj/devices/remote.dmi' //monkestation edit
	name = "control wand"
	desc = "Remotely controls airlocks."

	w_class = WEIGHT_CLASS_TINY
	var/mode = WAND_OPEN
	var/region_access = REGION_GENERAL
	var/list/access_list
	//monkestation addition: remote type for the purpose of updating the icon
	var/remote_type = "omni"

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	access_list = SSid_access.get_region_access_list(list(region_access))

/obj/item/door_remote/attack_self(mob/user)
	var/static/list/desc = list(WAND_OPEN = "Open Door", WAND_BOLT = "Toggle Bolts", WAND_EMERGENCY = "Toggle Emergency Access")
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	icon_state = "remote_[remote_type]_[mode]" //monkestation addition
	balloon_alert(user, "mode: [desc[mode]]")

/obj/item/door_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/door) && !isturf(interacting_with))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/door_remote/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/obj/machinery/door/door

	if (istype(interacting_with, /obj/machinery/door))
		door = interacting_with
		if (!door.opens_with_door_remote)
			return ITEM_INTERACT_BLOCKING

	else
		for (var/obj/machinery/door/door_on_turf in get_turf(interacting_with))
			if (door_on_turf.opens_with_door_remote)
				door = door_on_turf
				break

		if (isnull(door))
			return ITEM_INTERACT_BLOCKING

	if (!door.check_access_list(access_list) || !door.requiresID())
		interacting_with.balloon_alert(user, "can't access!")
		return ITEM_INTERACT_BLOCKING

	var/obj/machinery/door/airlock/airlock = door

	if (!door.hasPower() || (istype(airlock) && !airlock.canAIControl()))
		interacting_with.balloon_alert(user, mode == WAND_OPEN ? "it won't budge!" : "nothing happens!")
		return ITEM_INTERACT_BLOCKING

	switch (mode)
		if (WAND_OPEN)
			if (door.density)
				door.open()
			else
				door.close()
		if (WAND_BOLT)
			if (!istype(airlock))
				interacting_with.balloon_alert(user, "only airlocks!")
				return ITEM_INTERACT_BLOCKING

			if (airlock.locked)
				airlock.unbolt()
			else
				airlock.bolt()
		if (WAND_EMERGENCY)
			if (!istype(airlock))
				interacting_with.balloon_alert(user, "only airlocks!")
				return ITEM_INTERACT_BLOCKING

			airlock.emergency = !airlock.emergency
			airlock.update_appearance(UPDATE_ICON)

	return ITEM_INTERACT_SUCCESS

/obj/item/door_remote/update_icon_state()
	var/icon_state_mode
	switch(mode)
		if(WAND_OPEN)
			icon_state_mode = "open"
		if(WAND_BOLT)
			icon_state_mode = "bolt"
		if(WAND_EMERGENCY)
			icon_state_mode = "emergency"

	icon_state = "[base_icon_state]_[remote_type]_[icon_state_mode]"
	return ..()

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "Remotely controls airlocks. This remote can access any door on the station." //monkestation edit
	region_access = REGION_ALL_STATION

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "remote_command_open" //monkestation edit
	remote_type = "command" //monkestation edit
	region_access = REGION_COMMAND

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "remote_engi_open" //monkestation edit
	remote_type = "engi" //monkestation edit
	region_access = REGION_ENGINEERING

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "remote_sci_open" //monkestation edit
	remote_type = "sci" //monkestation edit
	region_access = REGION_RESEARCH

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "remote_security_open" //monkestation edit
	remote_type = "security" //monkestation edit
	region_access = REGION_SECURITY

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access."
	icon_state = "remote_cargo_open" //monkestation edit
	remote_type = "cargo" //monkestation edit
	region_access = REGION_SUPPLY

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "remote_med_open" //monkestation edit
	remote_type = "med" //monkestation edit
	region_access = REGION_MEDBAY

/obj/item/door_remote/civilian
	name = "civilian+supply door remote"
	icon_state = "remote_civilian_open" //monkestation edit
	remote_type = "civilian" //monkestation edit
	region_access = (REGION_GENERAL && REGION_SUPPLY) //monkestation addition

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
