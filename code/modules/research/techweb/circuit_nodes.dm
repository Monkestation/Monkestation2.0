/datum/techweb_node/basic_circuitry
	id = "basic_circuitry"
	starting_node = TRUE
	display_name = "Basic Integrated Circuits"
	description = "Research on how to fully exploit the power of integrated circuits"
	design_ids = list(
		"circuit_multitool",
		"comp_access_checker",
		"comp_arithmetic",
		"comp_assoc_list_pick",
		"comp_binary_convert",
		"comp_clock",
		"comp_comparison",
		"comp_concat",
		"comp_concat_list",
		"comp_decimal_convert",
		"comp_delay",
		"comp_direction",
		"comp_element_find",
		"comp_filter_list",
		"comp_foreach",
		"comp_format",
		"comp_format_assoc",
		"comp_get_column",
		"comp_gps",
		"comp_health",
		"comp_hear",
		"comp_id_access_reader",
		"comp_id_getter",
		"comp_id_info_reader",
		"comp_index",
		"comp_index_assoc",
		"comp_index_table",
		"comp_laserpointer",
		"comp_length",
		"comp_light",
		"comp_list_add",
		"comp_list_assoc_literal",
		"comp_list_clear",
		"comp_list_literal",
		"comp_list_pick",
		"comp_list_remove",
		"comp_logic",
		"comp_matscanner",
		"comp_mmi",
		"comp_module",
		"comp_multiplexer",
		"comp_not",
		"comp_ntnet_receive",
		"comp_ntnet_send",
		"comp_pinpointer",
		"comp_pressuresensor",
		"comp_radio",
		"comp_random",
		"comp_reagents",
		"comp_router",
		"comp_select_query",
		"comp_self",
		"comp_set_variable_trigger",
		"comp_soundemitter",
		"comp_species",
		"comp_speech",
		"comp_speech",
		"comp_split",
		"comp_string_contains",
		"comp_tempsensor",
		"comp_textcase",
		"comp_timepiece",
		"comp_tonumber",
		"comp_tostring",
		"comp_trigonometry",
		"comp_typecast",
		"comp_typecheck",
		"comp_view_sensor",
		"compact_remote_shell",
		"component_printer",
		"integrated_circuit",
		"module_duplicator",
		"usb_cable",
		"chemical_synthesizer",
		"weighted_splitter",
		"chemical_splitter",
		"chemical_mixer",
		"chemical_filter",
		"chemical_injector_bci",
		"internal_chemical_tank",
	)

/datum/techweb_node/adv_shells
	id = "adv_shells"
	display_name = "Advanced Shell Research"
	description = "Grants access to more complicated shell designs."
	prereq_ids = list("basic_circuitry", "engineering")
	design_ids = list(
		"assembly_shell",
		"bot_shell",
		"comp_mod_action",
		"controller_shell",
		"dispenser_shell",
		"door_shell",
		"gun_shell",
		"keyboard_shell",
		"module_shell",
		"money_bot_shell",
		"scanner_gate_shell",
		"scanner_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/bci_shells
	id = "bci_shells"
	display_name = "Brain-Computer Interfaces"
	description = "Grants access to biocompatable shell designs and components."
	prereq_ids = list("adv_shells")
	design_ids = list(
		"bci_implanter",
		"bci_shell",
		"comp_bar_overlay",
		"comp_bci_action",
		"comp_counter_overlay",
		"comp_install_detector",
		"comp_object_overlay",
		"comp_reagent_injector",
		"comp_target_intercept",
		"comp_thought_listener",
		"comp_vox",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 4)

/datum/techweb_node/movable_shells_tech
	id = "movable_shells"
	display_name = "Movable Shell Research"
	description = "Grants access to movable shells."
	prereq_ids = list("adv_shells", "robotics")
	design_ids = list(
		"comp_pathfind",
		"comp_pull",
		"drone_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/server_shell_tech
	id = "server_shell"
	display_name = "Server Technology Research"
	description = "Grants access to a server shell that has a very high capacity for components."
	prereq_ids = list("adv_shells", "computer_data_disks")
	design_ids = list(
		"server_shell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
