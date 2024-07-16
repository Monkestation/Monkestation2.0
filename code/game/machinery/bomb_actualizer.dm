/obj/machinery/bomb_actualizer
	name = "Bomb Actualizer	"
	desc = "An advanced EVIL? machine capable of releasing the normally bluespace-inhibited destructive potential of a bomb assembly"
	circuit = /obj/item/circuitboard/machine/bomb_actualizer
	icon = 'icons/obj/machines/research.dmi'
	base_icon_state = "explosive_compressor"
	icon_state = "explosive_compressor"
	density = TRUE

	/// The TTV inserted in the machine.
	var/obj/item/transfer_valve/inserted_bomb
	//combined gasmix to determine the simulation to reality
	var/datum/gas_mixture/combined_gasmix
/*
	//Stolen from anomaly_refinery
	/obj/machinery/research/anomaly_refinery/attackby(obj/item/tool, mob/living/user, params)
	if(active)
		to_chat(user, span_warning("You can't insert [tool] into [src] while [p_theyre()] currently active."))
		return
	if(istype(tool, /obj/item/transfer_valve))
		if(inserted_bomb)
			to_chat(user, span_warning("There is already a bomb in [src]."))
			return
		var/obj/item/transfer_valve/valve = tool
		if(!valve.ready())
			to_chat(user, span_warning("[valve] is incomplete."))
			return
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand."))
			return
		inserted_bomb = tool
		tank_to_target = inserted_bomb.tank_two
		to_chat(user, span_notice("You insert [tool] into [src]"))
		return
	update_appearance()
	return ..()
