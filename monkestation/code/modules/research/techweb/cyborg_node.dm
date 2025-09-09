//monkestation edits: The whole thing.
/datum/techweb_node/augmentation
	id = "augmentation"
	display_name = "Advanced prosthetics"
	description = "Designs for some one of the most enhanced prosthetic set's on the market. They harden in response to physical trauma."
	prereq_ids = list("ipc_parts")
	design_ids = list(
		/*"robocontrol",
		"borgupload",
		"cyborgrecharger",
		"mmi_posi",
		"mmi",
		"mmi_m",*/
		"advanced_l_arm",
		"advanced_r_arm",
		"advanced_l_leg",
		"advanced_r_leg",
		/*"borg_upgrade_rename",
		"borg_upgrade_restart",*/
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
