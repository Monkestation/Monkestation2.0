/**
 * This needs some clarification: The uplink_items_by_type list is populated on datum/asset/json/uplink/generate.
 * SStraitor doesn't actually initialize. I'm bamboozled.
 */
/datum/techweb_node/syndicate_basic/proc/register_uplink_items()
	SIGNAL_HANDLER
	UnregisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	boost_item_paths = list()
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/item = SStraitor.uplink_items_by_type[item_path]
		if(!item.item || !item.illegal_tech)
			continue
		boost_item_paths |= item.item //allows deconning to unlock.

	boost_item_paths |= /obj/item/malf_upgrade // MONKESTATION ADDITION -- The malf upgrade disk can now be used to get illegal technology

/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list("adv_engi", "adv_weaponry", "explosive_weapons")
	design_ids = list(
		"advanced_camera",
		"ai_cam_upgrade",
		"borg_syndicate_module",
		"decloner",
		"donksoft_refill",
		"donksofttoyvendor",
		"largecrossbow",
		"rapidsyringe",
		"suppressor",
		"super_pointy_tape",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	hidden = TRUE

/datum/techweb_node/syndicate_basic/New() //Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	if(!SSearly_assets.initialized)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(register_uplink_items))
	else
		register_uplink_items()

/datum/techweb_node/unregulated_bluespace
	id = "unregulated_bluespace"
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	prereq_ids = list("bluespace_travel", "syndicate_basic")
	design_ids = list(
		"desynchronizer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
