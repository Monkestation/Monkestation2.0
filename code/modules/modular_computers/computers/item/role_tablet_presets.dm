/**
 * Command
 */

/obj/item/modular_computer/pda/heads
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/heads")
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#67A364#a92323"
	max_capacity = parent_type::max_capacity * 2
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
	)

/obj/item/modular_computer/pda/heads/captain
	name = "captain PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/heads/captain")
	greyscale_config = /datum/greyscale_config/tablet/captain
	greyscale_colors = "#2C7CB2#FF0000#FFFFFF#FFD55B"
	inserted_item = /obj/item/pen/fountain/captain

/obj/item/modular_computer/pda/heads/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(tab_no_detonate))
	for(var/datum/computer_file/program/messenger/messenger_app in stored_files)
		messenger_app.spam_mode = TRUE

/obj/item/modular_computer/pda/heads/captain/proc/tab_no_detonate()
	SIGNAL_HANDLER
	return COMPONENT_TABLET_NO_DETONATE

/obj/item/modular_computer/pda/heads/hop
	name = "head of personnel PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/heads/hop")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#374f7e#a52f29#a52f29"
	inserted_item = /obj/item/pen/fountain
	stored_paper = 20
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/job_management,
	)

/obj/item/modular_computer/pda/heads/hos
	name = "head of security PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/heads/hos")
	greyscale_config = /datum/greyscale_config/tablet/head
	greyscale_colors = "#EA3232#0000CC"
	inserted_item = /obj/item/pen/red/security
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/records/security,
	)

/obj/item/modular_computer/pda/heads/ce
	name = "chief engineer PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/heads/ce")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#D99A2E#69DBF3#FAFAFA"
	inserted_item = /obj/item/pen/fountain
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/alarm_monitor,
		/datum/computer_file/program/supermatter_monitor,
	)

/obj/item/modular_computer/pda/heads/cmo
	name = "chief medical officer PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/heads/cmo")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#3F96CC"
	inserted_item = /obj/item/pen/fountain
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/maintenance/phys_scanner,
		/datum/computer_file/program/records/medical,
	)

/obj/item/modular_computer/pda/heads/rd
	name = "research director PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/heads/rd")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick/head
	greyscale_colors = "#FAFAFA#000099#B347BC"
	inserted_item = /obj/item/pen/fountain
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/signal_commander,
		/datum/computer_file/program/scipaper_program,
	)

/obj/item/modular_computer/pda/heads/ntrep
	name = "Nanotrasen Representative's PDA"
	inserted_item = /obj/item/pen/fountain
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
		/datum/computer_file/program/nt_rep_comments,
		/datum/computer_file/program/science,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
	)
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1

/obj/item/modular_computer/pda/blueshield //for now functionally the same as sec but with lifeline. But having it here means if we want to give a fancy pda or a CC command PDA we most certainly.
	name = "blueshield PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/blueshield")
	greyscale_colors = "#EA3232#0000cc"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/lifeline,
	)

/obj/item/modular_computer/pda/bridge_assistant
	name = "bridge assistant PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/bridge_assistant")
	greyscale_colors = "#374f7e#a92323"
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/status,
	)

/**
 * Security
 */

/obj/item/modular_computer/pda/security
	name = "security PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/security")
	greyscale_colors = "#EA3232#0000cc"
	inserted_item = /obj/item/pen/red/security
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/detective
	name = "detective PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/detective")
	greyscale_colors = "#805A2F#990202"
	inserted_item = /obj/item/pen/red/security
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/lifeline,
	)

/obj/item/modular_computer/pda/warden
	name = "warden PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/warden")
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#EA3232#0000CC#363636"
	inserted_item = /obj/item/pen/red/security
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/security/brig_physician
	name = "brig physician PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/security/brig_physician")
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#A52F29#0000CC#918F8C"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/lifeline, // For finding security officers
	)

/**
 * Engineering
 */

/obj/item/modular_computer/pda/engineering
	name = "engineering PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/engineering")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#69DBF3#E3DF3D"
	starting_programs = list(
		/datum/computer_file/program/supermatter_monitor,
		/datum/computer_file/program/alarm_monitor,
	)

/obj/item/modular_computer/pda/atmos
	name = "atmospherics PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/atmos")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#EEDC43#00E5DA#727272"
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/alarm_monitor,
	)

/obj/item/modular_computer/pda/signal
	name = "signal PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/signal")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#0EC220#727272"
	starting_programs = list(
		/datum/computer_file/program/ntnetmonitor,
	)

/**
 * Science
 */

/obj/item/modular_computer/pda/science
	name = "scientist PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/science")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#B347BC"
	starting_programs = list(
		/datum/computer_file/program/atmosscan,
		/datum/computer_file/program/signal_commander,
		/datum/computer_file/program/science,
		/datum/computer_file/program/scipaper_program,
	)

/obj/item/modular_computer/pda/roboticist
	name = "roboticist PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/roboticist")
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#484848#0099CC#D94927"
	starting_programs = list(
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/borg_monitor,
	)

/obj/item/modular_computer/pda/geneticist
	name = "geneticist PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/geneticist")
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#000099#0097CA"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
	)

/obj/item/modular_computer/pda/xenobiologist
	name = "xenobiologist PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/xenobiologist")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#FF66CC"

/**
 * Medical
 */

/obj/item/modular_computer/pda/medical
	name = "medical PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/medical")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#3F96CC"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/medical/paramedic
	name = "paramedic PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/medical/paramedic")
	greyscale_colors = "#28334D#000099#3F96CC"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/lifeline, // monkestation edit `/datum/computer_file/program/radar/lifeline` -> `/datum/computer_file/program/lifeline`
	)

/obj/item/modular_computer/pda/viro
	name = "virology PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/viro")
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#355FAC#57C451"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/chemist
	name = "chemist PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/chemist")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#355FAC#EA6400"

/obj/item/modular_computer/pda/psychologist
	name = "Psychologist PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/psychologist")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#242424#333333"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/psychologist/Initialize(mapload)
	. = ..()
	for(var/datum/computer_file/program/messenger/messenger_app in stored_files)
		messenger_app.spam_mode = TRUE

/**
 * Supply
 */

//Monkestation Edits Start - QM is not a head, knocking QM's PDA down, removed status display and science programs. The redefinition of the QM's PDA will be reflected in the job.

/obj/item/modular_computer/pda/quartermaster
	name = "quartermaster PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/quartermaster")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D6B328#6506CA#927444"
	inserted_item = /obj/item/pen/survival
	stored_paper = 20
	starting_programs = list(
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/robocontrol,
	)

//Monkestation Edits End

/obj/item/modular_computer/pda/cargo
	name = "cargo technician PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/cargo")
	greyscale_colors = "#D6B328#6506CA"
	stored_paper = 20
	starting_programs = list(
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/shaftminer
	name = "shaft miner PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/shaftminer")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"
	starting_programs = list(
		/datum/computer_file/program/skill_tracker,
	)

/obj/item/modular_computer/pda/bitrunner
	name = "bit runner PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/bitrunner")
	greyscale_colors = "#D6B328#6BC906"
	starting_programs = list(
		/datum/computer_file/program/arcade,
		/datum/computer_file/program/skill_tracker,
	)

/**
 * Service
 */

/obj/item/modular_computer/pda/janitor
	name = "janitor PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/janitor")
	greyscale_colors = "#933ea8#235AB2"
	starting_programs = list(
		/datum/computer_file/program/skill_tracker,
		/datum/computer_file/program/radar/custodial_locator,
	)

/obj/item/modular_computer/pda/chaplain
	name = "chaplain PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/chaplain")
	greyscale_config = /datum/greyscale_config/tablet/chaplain
	greyscale_colors = "#333333#D11818"

/obj/item/modular_computer/pda/lawyer
	name = "lawyer PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/lawyer")
	greyscale_colors = "#4C76C8#FFE243"
	inserted_item = /obj/item/pen/fountain
	starting_programs = list(
		/datum/computer_file/program/records/security,
	)

/obj/item/modular_computer/pda/lawyer/Initialize(mapload)
	. = ..()
	for(var/datum/computer_file/program/messenger/messenger_app in stored_files)
		messenger_app.spam_mode = TRUE

/obj/item/modular_computer/pda/botanist
	name = "botanist PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/botanist")
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/pda/cook
	name = "cook PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/cook")
	greyscale_colors = "#FAFAFA#A92323"

/obj/item/modular_computer/pda/bar
	name = "bartender PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/bar")
	greyscale_colors = "#333333#C7C7C7"
	inserted_item = /obj/item/pen/fountain

/obj/item/modular_computer/pda/clown
	name = "clown PDA"
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda-clown"
	inserted_disk = /obj/item/computer_disk/virus/clown
	greyscale_config = null
	greyscale_colors = null
	inserted_item = /obj/item/toy/crayon/rainbow

/obj/item/modular_computer/pda/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery/clowning, 120, NO_SLIP_WHEN_WALKING, CALLBACK(src, PROC_REF(AfterSlip)), slot_whitelist = list(ITEM_SLOT_ID, ITEM_SLOT_BELT))
	AddComponent(/datum/component/wearertargeting/sitcomlaughter, CALLBACK(src, PROC_REF(after_sitcom_laugh)))

/obj/item/modular_computer/pda/clown/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "pda_stripe_clown") // clowns have eyes that go over their screen, so it needs to be compiled last

/obj/item/modular_computer/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != saved_identification))
		var/obj/item/computer_disk/virus/clown/cart = inserted_disk
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/modular_computer/pda/clown/proc/after_sitcom_laugh(mob/victim)
	victim.visible_message("[src] lets out a burst of laughter!")

/obj/item/modular_computer/pda/mime
	name = "mime PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/mime")
	greyscale_config = /datum/greyscale_config/tablet/mime
	greyscale_colors = "#FAFAFA#EA3232"
	inserted_disk = /obj/item/computer_disk/virus/mime
	inserted_item = /obj/item/toy/crayon/mime
	starting_programs = list(
		/datum/computer_file/program/emojipedia,
	)

/obj/item/modular_computer/pda/mime/Initialize(mapload)
	. = ..()
	for(var/datum/computer_file/program/messenger/msg in stored_files)
		msg.mime_mode = TRUE
		msg.alert_silenced = TRUE

/obj/item/modular_computer/pda/curator
	name = "curator PDA"
	desc = "A small experimental microcomputer."
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda-library"
	greyscale_config = null
	greyscale_colors = null
	inserted_item = /obj/item/pen/fountain
	long_ranged = TRUE
	starting_programs = list(
		/datum/computer_file/program/emojipedia,
		/datum/computer_file/program/newscaster,
		/datum/computer_file/program/portrait_printer,
	)

/**
 * No Department
 */

/obj/item/modular_computer/pda/assistant
	name = "assistant PDA"
	flags_1 = parent_type::flags_1 | NO_NEW_GAGS_PREVIEW_1
	starting_programs = list(
		/datum/computer_file/program/bounty_board,
	)

/**
 * Non-roles
 */

/obj/item/modular_computer/pda/syndicate
	name = "military PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/syndicate")
	greyscale_colors = "#891417#80FF80"
	saved_identification = "John Doe"
	saved_job = "Citizen"
	device_theme = PDA_THEME_SYNDICATE

/obj/item/modular_computer/pda/syndicate/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/messenger/msg = locate() in stored_files
	if(msg)
		msg.invisible = TRUE

/obj/item/modular_computer/pda/clear
	name = "clear PDA"
	icon = 'icons/obj/modular_pda.dmi'
	icon_state = "pda-clear"
	greyscale_config = null
	greyscale_colors = null
	long_ranged = TRUE

/obj/item/modular_computer/pda/barber
	name = "barber PDA"
	SETUP_MAP_ICONS("pda", "/obj/item/modular_computer/pda/barber")
	greyscale_colors = "#933ea8#235AB2"
	starting_programs = list()
