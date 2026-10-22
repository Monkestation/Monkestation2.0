/obj/structure/brine_chamber
	name = "brine chamber"
	desc = "A large structure for a pool of water. Its large open surface area allows water to evaporate leaving behind, salts creating a very salty brine solution."
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "brine_chamber"

/obj/structure/brine_chamber/controller
	name = "brine chamber controller"
	desc = "The controller for the brine chamber. Accepts water to be pumped into the pool and output brine to be pumped out."
	icon_state = "brine_chamber_controller"

	/// Pack to return when deconstructed with crowbar.
	var/obj/item/flatpacked_machine/ore_processing/machine = /obj/item/flatpacked_machine/ore_processing/brine_chamber
	var/obj/item/marker_tool

/obj/structure/brine_chamber/controller/Destroy()
	machine = null
	clear_marking()
	return ..()

/obj/structure/brine_chamber/controller/proc/mark_border()
	SIGNAL_HANDLER
	if(!istype(marker_tool))
		return

/obj/structure/brine_chamber/controller/proc/clear_marking()
	SIGNAL_HANDLER
	UnregisterSignal(marker_tool, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_MULTITOOL)))
	marker_tool = null

/obj/structure/brine_chamber/controller/deconstruct(disassembled)
	if(disassembled && !isnull(machine))
		new machine(src.loc)

	return ..()

/obj/structure/brine_chamber/controller/multitool_act(mob/living/user, obj/item/tool)
	if(QDELETED(tool))
		return
	if(!marker_tool)
		marker_tool = tool
		RegisterSignals(tool, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING), PROC_REF(clear_marking))
		RegisterSignals(tool, list(COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_MULTITOOL)), PROC_REF(mark_border))
		balloon_alert_to_viewers("Mark the corners with the multitool.")
		return ITEM_INTERACT_SUCCESS

/obj/structure/brine_chamber/controller/crowbar_act(mob/living/user, obj/item/tool)
	if(isitem(tool))
		if(!(flags_1 & NODECONSTRUCT_1))
			tool.play_tool_sound(src, 50)
			deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS
	return

// Marker for the boundary corners.
//obj/effect/brine_marker
//	icon_state = "scanline"
