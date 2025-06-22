//Wastes firing pin - restricts a weapon to only outside when mining - based on area defines not z-level
/obj/item/firing_pin/wastes
	name = "Wastes firing pin"
	desc = "This safety firing pin allows weapons to be fired only outside on the wastes of lavaland or icemoon."
	fail_message = "Wastes check failed! - Try getting further from the station first."
	pin_hot_swappable = FALSE
	pin_removable = FALSE
	var/list/wastes = list(
		/area/icemoon/surface/outdoors,
		/area/icemoon/underground/unexplored,
		/area/icemoon/underground/explored,

		/area/lavaland/surface/outdoors,

		/area/ocean/generated,
		/area/ocean/generated_above,

		/area/ruin,

		/area/centcom/central_command_areas/evacuation, //END OF ROUND GRIEFING AVAILABLE NOW!!!
		/area/centcom/central_command_areas/firing_range, //can be used in the centcom firing range if you get a waste pin there
	)

/obj/item/firing_pin/wastes/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if (is_type_in_list(get_area(user), wastes)|| SSticker.current_state == GAME_STATE_FINISHED) //now unlocks after game is over. have fun)
		return TRUE
	return FALSE
