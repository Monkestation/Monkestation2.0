/datum/ai_module/power_apc
	name = "Remote Power"
	description = "remotely powers an APC from a distance"
	one_purchase = TRUE
	power_type = /datum/action/innate/ai/ranged/power_apc
	unlock_text = span_notice("Remote APC power systems online.")

/datum/action/innate/ai/ranged/power_apc
	name = "Remotely Power APC"
	desc = "Use to remotely power an APC."
	button_icon = 'monkestation/code/modules/aesthetics/icons/apc.dmi'
	button_icon_state = "apcewires"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	enable_text = span_notice("You prepare to power any APC you see.")
	disable_text = span_notice("You stop focusing on powering APCs.")

/datum/action/innate/ai/ranged/power_apc/do_ability(mob/living/clicker, atom/clicked_on)

	if (!isAI(clicker))
		return FALSE
	var/mob/living/silicon/ai/ai_clicker = clicker

	if(clicker.incapacitated())
		unset_ranged_ability(clicker)
		return FALSE

	if(!isapc(clicked_on))
		clicked_on.balloon_alert(ai_clicker, "not an APC!")
		return FALSE

	if(ai_clicker.battery - 50 <= 0)
		to_chat(ai_clicker, span_warning("You do not have the battery to charge an APC!"))
		return FALSE

	var/obj/machinery/power/apc/apc = clicked_on
	var/obj/item/stock_parts/cell/cell = apc.get_cell()
	cell.give(1000)
	ai_clicker.battery -= 50



