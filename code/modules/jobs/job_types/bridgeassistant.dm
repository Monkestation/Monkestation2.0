/*
Bridge Assistant
*/
/datum/job/bridge_assistant
	title = JOB_BRIDGE_ASSISTANT
	description = "Watch over the Bridge, command its consoles, and spend your days brewing coffee for higher-ups."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD //talks with command, stop being an admin
	department_head = list(JOB_CAPTAIN)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the command staff, pursuant to conventional chain of command"
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BRIDGE_ASSISTANT"

	outfit = /datum/outfit/job/bridge_assistant
	plasmaman_outfit = /datum/outfit/plasmaman/bridge_assistant

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_CIV

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BRIDGE_ASSISTANT
	departments_list = list(/datum/job_department/command)
	department_for_prefs = /datum/job_department/captain //hes the only person who is exclusively subordinate to the captain and not running another dept

	family_heirlooms = list(/obj/item/banner/command/mundane, /obj/item/pen/fountain, /obj/item/stamp/granted, /obj/item/reagent_containers/cup/glass/mug/nanotrasen, /obj/item/reagent_containers/cup/coffeepot/bluespace/synthesiser)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 1,
		/obj/item/pen/fountain = 1,
		/obj/item/reagent_containers/cup/coffeepot/bluespace/synthesiser = 1, //HOLY SHIT
	)
	rpg_title = "Supreme Lout"
	alt_titles = list(
		"Bridge Assistant",
		"Bridge Staff",
		"Coffee Logistics Officer",
		"Bridge Watchman",
		"Helmsman",
		"Command Intern",
	)
	job_flags = STATION_JOB_FLAGS

	voice_of_god_power = 1.1 //SIR CAN YOU PLEASE GET AWAY FROM THE FIREAXE

/datum/job/bridge_assistant/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/mob/living/carbon/bridgie = spawned
	if(istype(bridgie))
		bridgie.gain_trauma(/datum/brain_trauma/special/axedoration)

/obj/item/modular_computer/pda/bridge_assistant
	name = "bridge assistant PDA"
	greyscale_colors = "#374f7e#a92323"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
	)

/datum/outfit/job/bridge_assistant
	name = "Bridge Assistant"
	jobtype = /datum/job/bridge_assistant

	id_trim = /datum/id_trim/job/bridge_assistant
	backpack_contents = list(
		/obj/item/inducer = 1,
	)

	uniform = /obj/item/clothing/under/trek/command/next
	neck = /obj/item/clothing/neck/large_scarf/blue
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_com
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/fingerless
	head = /obj/item/clothing/head/soft/black
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/modular_computer/pda/bridge_assistant
	r_pocket = /obj/item/assembly/flash/handheld
	implants = list(/obj/item/implant/mindshield)
	pda_slot = ITEM_SLOT_LPOCKET
