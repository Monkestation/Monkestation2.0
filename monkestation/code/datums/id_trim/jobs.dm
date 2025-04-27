/datum/id_trim/job/barber
	assignment = "Barber"
	trim_state = "trim_barber"
	department_color = COLOR_SERVICE_LIME
	subdepartment_color = COLOR_SERVICE_LIME
	sechud_icon_state = SECHUD_BARBER
	minimal_access = list(
		ACCESS_SERVICE,
		ACCESS_THEATRE,
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/barber

/datum/id_trim/job/blueshield
	assignment = "Blueshield"
	trim_state = "trim_blueshield"
	department_color = COLOR_COMMAND_BLUE
	subdepartment_color = COLOR_SECURITY_RED
	sechud_icon_state = SECHUD_BLUESHIELD
	extra_access = list(
		ACCESS_BRIG,
		ACCESS_CARGO,
		ACCESS_COURT,
		ACCESS_GATEWAY,
	)
	minimal_access = list(
		ACCESS_SECURITY,
		ACCESS_ALL_PERSONAL_LOCKERS,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_BLUESHIELD,
		ACCESS_COMMAND,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_EVA,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SCIENCE,
		ACCESS_TELEPORTER,
		ACCESS_WEAPONS,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS
		)
	job = /datum/job/blueshield

/datum/id_trim/job/brig_physician
	assignment = "Brig Physician"
	trim_state = "trim_brigphysician"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = COLOR_MEDICAL_BLUE
	sechud_icon_state = SECHUD_BRIG_PHYSICIAN
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_BRIG_PHYSICIAN,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		)
	extra_access = list(
		ACCESS_DETECTIVE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_SURGERY,
		ACCESS_MEDICAL,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOS,
		)
	job = /datum/job/brig_physician

/datum/id_trim/job/explorer
	assignment = "Explorer"
	trim_state = "trim_explorer"
	department_color = COLOR_CARGO_BROWN
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_EXPLORER
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CARGO,
		ACCESS_MECH_MINING,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MAINT_TUNNELS,
		ACCESS_EXTERNAL_AIRLOCKS, //how else do they get into space?
		)
	extra_access = list()
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOP,
		)
	job = /datum/job/shaft_miner

/datum/id_trim/job/nanotrasen_representative
	assignment = "Nanotrasen Representative"
	trim_state = "trim_centcom"
	department_color = COLOR_CENTCOM_BLUE
	subdepartment_color = COLOR_CENTCOM_BLUE
	sechud_icon_state = SECHUD_CENTCOM
	minimal_access = list(
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COMMAND,
		ACCESS_MAINT_TUNNELS,
		ACCESS_WEAPONS,
		ACCESS_NT_REPRESENTATVE,
		)
	extra_access = list(
		ACCESS_BAR,
		)
	template_access = list(
		)
	job = /datum/job/nanotrasen_representative

/datum/id_trim/job/signal_technician
	assignment = JOB_SIGNAL_TECHNICIAN
	intern_alt_name = "Junior Signal Technician"
	trim_state = "trim_signaltech"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_SIGNAL_TECHINICAN
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_TCOMMS,
		ACCESS_TCOMMS_ADMIN,
		ACCESS_TECH_STORAGE,
		ACCESS_RC_ANNOUNCE,
	)
	extra_access = list(
		ACCESS_ATMOSPHERICS,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CE,
	)
	job = /datum/job/signal_technician

/datum/id_trim/job/xenobiologist
	assignment = "Xenobiologist"
	trim_state = "trim_xenobiologist"
	department_color = COLOR_SCIENCE_PINK
	subdepartment_color = COLOR_SCIENCE_PINK
	sechud_icon_state = SECHUD_XENOBIOLOGIST
	minimal_access = list(
		ACCESS_MECH_SCIENCE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_RESEARCH,
		ACCESS_SCIENCE,
		ACCESS_XENOBIOLOGY,
		)
	extra_access = list(
		ACCESS_GENETICS,
		ACCESS_ROBOTICS,
		ACCESS_AUX_BASE,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_RD,
		)
	job = /datum/job/xenobiologist
