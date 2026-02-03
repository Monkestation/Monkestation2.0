/datum/job/detective
	title = JOB_DETECTIVE
	description = "Investigate crimes, gather evidence, perform interrogations, \
		look badass, smoke cigarettes."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 2 /// Monkestation edit : Adding some substance to the detective role
	spawn_positions = 2 /// Monkestation edit : Adding some substance to the detective role
	supervisors = SUPERVISOR_HOS
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "DETECTIVE"

	outfit = /datum/outfit/job/detective
	plasmaman_outfit = /datum/outfit/plasmaman/detective
	departments_list = list(
		/datum/job_department/security,
		)

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DETECTIVE

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 25,
		/obj/item/ammo_box/c38 = 25,
		/obj/item/ammo_box/magazine/m45 = 15, /// Monkestation edit : Adding some substance to the detective role
		/obj/item/ammo_box/c38/dumdum = 5,
		/obj/item/ammo_box/c38/hotshot = 5,
		/obj/item/ammo_box/c38/iceblox = 5,
		/obj/item/ammo_box/c38/match = 5,
		/obj/item/ammo_box/c38/trac = 5,
		/obj/item/storage/belt/holster/detective/full = 1
	)

	family_heirlooms = list(/obj/item/reagent_containers/cup/glass/bottle/whiskey)
	rpg_title = "Thiefcatcher" //I guess they caught them all rip thief...
	job_flags = STATION_JOB_FLAGS

	job_tone = "objection"
	antag_capacity_points = 3


/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	id_trim = /datum/id_trim/job/detective
	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/jacket/det_suit
	backpack_contents = list(
		/obj/item/detective_scanner = 1,
		/obj/item/melee/baton = 1,
		/obj/item/storage/box/evidence = 1,
		)
	belt = /obj/item/modular_computer/pda/detective
	ears = /obj/item/radio/headset/headset_sec/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/fedora/det_hat
	mask = /obj/item/clothing/mask/cigarette
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/sneakers/brown
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/lighter

	chameleon_extras = list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/gun/ballistic/revolver/c38/detective,
		)
	implants = list(/obj/item/implant/mindshield)
	accessory = /obj/item/clothing/accessory/badge/detective // Monkestation edit : Adding some substance to the detective role

#define DETECTIVE_PROMOTION_OFFICER 600 //(10 hours, you're now a patrol officer)
#define DETECTIVE_PROMOTION_SEARGEANT 1200 //(20 hours, you're now a seargent detective)
#define DETECTIVE_PROMOTION_LIEUTENANT 2400 //(40 hours, you're now a lieutenant, the last job that still does field work)

/datum/outfit/job/detective/pre_equip(mob/living/carbon/human/human, visualsOnly = FALSE)
	. = ..()
	if (human.age < AGE_MINOR)
		mask = /obj/item/clothing/mask/cigarette/candy
		head = /obj/item/clothing/head/fedora/det_hat/minor

	if(visualsOnly || !CONFIG_GET(flag/use_exp_tracking))
		return

	var/client/equipped_client = GLOB.directory[ckey(human.mind?.key)]
	if(isnull(equipped_client))
		return
	var/player_playtime = text2num(equipped_client.prefs.exp[JOB_DETECTIVE])
	switch(player_playtime)
		if(DETECTIVE_PROMOTION_SEARGEANT to INFINITY)
			accessory = /obj/item/clothing/accessory/badge/detective/gold

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/equipped, visualsOnly = FALSE)
	..()
	var/obj/item/clothing/mask/cigarette/cig = equipped.wear_mask
	if(istype(cig)) //Some species specfic changes can mess this up (plasmamen)
		cig.light("")

	if(visualsOnly || !CONFIG_GET(flag/use_exp_tracking))
		return

	var/obj/item/clothing/accessory/badge/equipped_badge = locate() in equipped.w_uniform.attached_accessories
	var/client/equipped_client = GLOB.directory[ckey(equipped.mind?.key)]
	if(isnull(equipped_client))
		return
	var/player_playtime = text2num(equipped_client.prefs.exp[JOB_DETECTIVE])
	switch(player_playtime)
		if(-1 to DETECTIVE_PROMOTION_OFFICER)
			equipped_badge.badge_string = "Junior"
		if(DETECTIVE_PROMOTION_OFFICER to DETECTIVE_PROMOTION_SEARGEANT)
			equipped_badge.badge_string = "Patrol"
		if(DETECTIVE_PROMOTION_SEARGEANT to DETECTIVE_PROMOTION_LIEUTENANT)
			equipped_badge.badge_string = "Seargent"
		if(DETECTIVE_PROMOTION_LIEUTENANT to INFINITY)
			//remove all EXP to get to this point, now we're going yefreitor
			player_playtime -= DETECTIVE_PROMOTION_LIEUTENANT
			//for every new "Officer" level (10 hours), you get a yefreitor.
			var/number_yefreitor
			while(player_playtime >= DETECTIVE_PROMOTION_OFFICER)
				player_playtime -= DETECTIVE_PROMOTION_OFFICER
				number_yefreitor++
			if(number_yefreitor)
				equipped_badge.badge_string = "Lieutenant \Roman[number_yefreitor]-yefreitor"
			else
				equipped_badge.badge_string = "Lieutenant"

#undef DETECTIVE_PROMOTION_OFFICER
#undef DETECTIVE_PROMOTION_SEARGEANT
#undef DETECTIVE_PROMOTION_LIEUTENANT
