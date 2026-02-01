/datum/job/nanotrasen_representative
	title = JOB_NANOTRASEN_REPRESENTATIVE
	description = "Ensure company interests and report whether Standard Operating Procedure is upheld onboard the station, and get out as soon as you can when it inevitably falls apart. You do not have the authority to give orders, except to the blueshield."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("CentCom")
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command"
	req_admin_notify = 1
	minimal_player_age = 30
	exp_requirements = 3000
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_CENTRAL_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "NANOTRASEN_REPRESENTATIVE"

	allow_bureaucratic_error = FALSE
	allow_overflow = FALSE

	outfit = /datum/outfit/job/nanotrasen_representative
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_official

	paycheck = PAYCHECK_NANOTRASEN
	paycheck_department = ACCOUNT_CC

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_NANOTRASEN_REPRESENTATIVE
	bounty_types = CIV_JOB_BASIC
	departments_list = list(
		/datum/job_department/central_command,
		/datum/job_department/command,
		)
	department_for_prefs = /datum/job_department/central_command

	family_heirlooms = list(/obj/item/pen/fountain, /obj/item/lighter, /obj/item/reagent_containers/cup/glass/flask)

	mail_goodies = list(
		/obj/item/pen/fountain = 30,
		/obj/item/food/moonfish_caviar = 25,
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 15,
		/obj/item/reagent_containers/cup/glass/bottle/champagne/cursed = 5,
	)
	exclusive_mail_goodies = TRUE
	rpg_title = "Diplomat"
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT | JOB_CANNOT_OPEN_SLOTS

	voice_of_god_power = 1.4 //Command staff has authority

	alt_titles = list(
		"Nanotrasen Representative",
		"Corporate Liaison",
		"Nanotrasen Fax Operater",
		"Nanotrasen Informant",
		"Retired Captain",
	)
	job_tone = "incoming message"

/datum/job/nanotrasen_representative/after_spawn(mob/living/spawned, client/player_client)
	. = ..()

	//we set ourselves as "dead" to CC, then alive as long as 1 of us survives.
	SSticker.nanotrasen_rep_status = NT_REP_STATUS_DIED
	var/datum/callback/roundend_callback = CALLBACK(src, PROC_REF(check_living), spawned.mind)
	SSticker.OnRoundend(roundend_callback)

/datum/job/nanotrasen_representative/employment_contract_contents(employee_name)
	return "<center>Conditions of Employment</center>\
	<BR><BR><BR><BR>\
	This Agreement is made and entered into as of the date of last signature below, by and between [employee_name] (hereafter referred to as REPRESENTATIVE), \
	and Central Command (hereafter referred to as REPRESENTED).\
	<BR>WITNESSETH:<BR>WHEREAS, REPRESENTATIVE is a natural born human or humanoid, possessing skills upon which he can aid REPRESENTED, \
	who seeks employment in REPRESENTED.<BR>WHEREAS, REPRESENTED agrees to sporadically provide payment to REPRESENTATIVE, \
	in exchange for their expertise and labor.<BR>NOW THEREFORE in consideration of the mutual covenants herein contained, and other good and valuable consideration, the parties hereto mutually agree as follows:\
	<BR>In exchange for payments, REPRESENTATIVE agrees to work for REPRESENTED, \
	for the remainder of his or her current and future lives.<BR>Further, REPRESENTATIVE agrees to transfer ownership of his or her soul to the loyalty department of REPRESENTED.\
	<BR>Should transfership of a soul not be possible, a lien shall be placed instead.\
	<BR>Signed,<BR><i>[employee_name]</i>"

///Checks if our mind survived somehow, since we can change bodies we should not keep track of that instead.
///If so, (yes only 1 NT rep exists currently but this is for future proofing), set it as an NT rep surviving,
///which won't cause score to tank.
/datum/job/nanotrasen_representative/proc/check_living(datum/mind/rep_mind)
	if(rep_mind?.current?.stat < DEAD)
		SSticker.nanotrasen_rep_status = NT_REP_STATUS_SURVIVED

/datum/outfit/job/nanotrasen_representative
	name = "Nanotrasen Representative"
	jobtype = /datum/job/nanotrasen_representative
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/job/nanotrasen_representative
	uniform = /obj/item/clothing/under/rank/centcom/nanotrasen_representative
	suit = /obj/item/clothing/suit/armor/vest/nanotrasen_representative
	head = /obj/item/clothing/head/hats/nanotrasen_representative
	backpack_contents = list(
		/obj/item/stamp/centcom = 1,
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/clipboard = 1,
	)
	belt = /obj/item/gun/energy/laser/plasmacore
	r_pocket = /obj/item/modular_computer/pda/heads/ntrep
	l_hand = /obj/item/storage/briefcase/secure/cash
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/headset_cent/representative
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup

	chameleon_extras = list(
		/obj/item/gun/energy/laser/plasmacore,
		/obj/item/stamp/centcom,
		)

	implants = list(/obj/item/implant/mindshield)
	pda_slot = ITEM_SLOT_RPOCKET
	skillchips = list(
		/obj/item/skillchip/disk_verifier,
	)
