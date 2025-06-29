
//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/ghost_role/human/oldsec
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	prompt_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_species = /datum/species/human
	you_are_text = "You are a security officer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_text = "Work as a team with your fellow survivors and do not abandon them."
	outfit = /datum/outfit/oldsec
	spawner_job_path = /datum/job/ancient_crew

/obj/effect/mob_spawn/ghost_role/human/oldsec/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/datum/outfit/oldsec
	name = "Ancient Security"
	id = /obj/item/card/id/away/old/sec
	uniform = /obj/item/clothing/under/rank/security/officer
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/assembly/flash/handheld
	r_pocket = /obj/item/restraints/handcuffs

/obj/effect/mob_spawn/ghost_role/human/oldeng
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	prompt_name = "an engineer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_species = /datum/species/human
	you_are_text = "You are an engineer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. The last thing \
	you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_text = "Work as a team with your fellow survivors and do not abandon them."
	outfit = /datum/outfit/oldeng
	spawner_job_path = /datum/job/ancient_crew

/obj/effect/mob_spawn/ghost_role/human/oldeng/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/datum/outfit/oldeng
	name = "Ancient Engineer"
	id = /obj/item/card/id/away/old/eng
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	shoes = /obj/item/clothing/shoes/workboots
	l_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/outfit/oldeng/mod
	name = "Ancient Engineer (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/prototype
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE

/obj/effect/mob_spawn/ghost_role/human/oldsci
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	prompt_name = "a scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_species = /datum/species/human
	you_are_text = "You are a scientist working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_text = "Work as a team with your fellow survivors and do not abandon them."
	outfit = /datum/outfit/oldsci
	spawner_job_path = /datum/job/ancient_crew

/obj/effect/mob_spawn/ghost_role/human/oldsci/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/datum/outfit/oldsci
	name = "Ancient Scientist"
	id = /obj/item/card/id/away/old/sci
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/stack/medical/bruise_pack

///battlecruiser stuff

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser
	name = "Syndicate Battlecruiser Ship Operative"
	you_are_text = "You are a crewmember aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to follow your captain's orders, maintain the ship, and keep the power flowing."
	important_text = "The armory is not a candy store, and your role is not to assault the station directly, leave that work to the assault operatives."
	prompt_name = "a battlecruiser crewmember"
	outfit = /datum/outfit/syndicate_empty/battlecruiser
	spawner_job_path = /datum/job/battlecruiser_crew
	uses = 4
	dont_be_a_shit = FALSE //explicitly an antag

	/// The antag team to apply the player to
	var/datum/team/antag_team
	/// The antag datum to give to the player spawned
	var/antag_datum_to_give = /datum/antagonist/battlecruiser

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/allow_spawn(mob/user, silent = FALSE)
	if(!(user.ckey in antag_team.players_spawned))
		return TRUE
	if(!silent)
		to_chat(user, span_boldwarning("You have already used up your chance to roll as Battlecruiser."))
	return FALSE

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/special(mob/living/spawned_mob, mob/possesser)
	. = ..()
	if(!spawned_mob.mind)
		spawned_mob.mind_initialize()
	var/datum/mind/mob_mind = spawned_mob.mind
	mob_mind.add_antag_datum(antag_datum_to_give, antag_team)
	antag_team.players_spawned += (spawned_mob.ckey)

/datum/outfit/syndicate_empty/battlecruiser
	name = "Syndicate Battlecruiser Ship Operative"
	belt = /obj/item/storage/belt/military/assault
	l_pocket = /obj/item/gun/ballistic/automatic/pistol/clandestine
	r_pocket = /obj/item/knife/combat/survival

	box = /obj/item/storage/box/survival/syndie

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/assault
	name = "Syndicate Battlecruiser Assault Operative"
	you_are_text = "You are an assault operative aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to follow your captain's orders, keep intruders out of the ship, and assault Space Station 13. There is an armory, multiple assault ships, and beam cannons to attack the station with."
	important_text = "Work as a team with your fellow operatives and work out a plan of attack. If you are overwhelmed, escape back to your ship!"
	prompt_name = "a battlecruiser operative"
	outfit = /datum/outfit/syndicate_empty/battlecruiser/assault
	uses = 8

/datum/outfit/syndicate_empty/battlecruiser/assault
	name = "Syndicate Battlecruiser Assault Operative"
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/automatic/pistol/clandestine
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/military
	mask = /obj/item/clothing/mask/gas/syndicate
	l_pocket = /obj/item/uplink/nuclear
	r_pocket = /obj/item/modular_computer/pda/nukeops

/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/captain
	name = "Syndicate Battlecruiser Captain"
	you_are_text = "You are the captain aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to oversee your crew, defend the ship, and destroy Space Station 13. The ship has an armory, multiple ships, beam cannons, and multiple crewmembers to accomplish this goal."
	important_text = "As the captain, this whole operation falls on your shoulders. Help your assault operatives detonate a nuke on the station."
	prompt_name = "a battlecruiser captain"
	outfit = /datum/outfit/syndicate_empty/battlecruiser/assault/captain
	spawner_job_path = /datum/job/battlecruiser_captain
	antag_datum_to_give = /datum/antagonist/battlecruiser/captain
	uses = 1

/datum/outfit/syndicate_empty/battlecruiser/assault/captain
	name = "Syndicate Battlecruiser Captain"
	id = /obj/item/card/id/advanced/black/syndicate_command/captain_id
	id_trim = /datum/id_trim/battlecruiser/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	suit_store = /obj/item/gun/ballistic/revolver/mateba
	back = /obj/item/storage/backpack/satchel/leather
	ears = /obj/item/radio/headset/syndicate/alt/leader
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	head = /obj/item/clothing/head/hats/hos/cap/syndicate
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	l_pocket = /obj/item/melee/energy/sword/saber/red
	r_pocket = /obj/item/melee/baton/telescopic


/// Deep Storage Syndicate base

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/deepstorage/comms
	name = "Syndicate Comms Agent"
	prompt_name = "a syndicate comms agent"
	you_are_text = "You are a syndicate comms agent, employed in a remote research bunker."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has a station in this sector. Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!"
	important_text = "DO NOT abandon the base. However, you may freely explore your surrounding within your current space quadrant (Z-Level). Do not directly interfere with the Nanotrasen station without the express permission of Syndicate Command."
	outfit = /datum/outfit/lavaland_syndicate/comms

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/deepstorage
	name = "Syndicate Bioweapon Scientist"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	prompt_name = "a syndicate science technician"
	you_are_text = "You are a syndicate science technician, employed in a remote research bunker developing biological weapons."
	flavour_text = "Unfortunately, your hated enemy, Nanotrasen, has a station in this sector. Continue your research as best you can, and try to keep a low profile."
	important_text = "DO NOT abandon the base or let it fall into enemy hands! However, you may freely explore your surrounding within your current space quadrant (Z-Level). Do not directly interfere with the Nanotrasen station without the express permission of Syndicate Command. Do not test bioweapons on the Nanotrasen station without Syndicate Command's approval either."
	outfit = /datum/outfit/deepstorage_syndicate

/datum/outfit/deepstorage_syndicate
	name = "Deep Storage Syndicate Agent"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/toggle/labcoat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol

/datum/outfit/deepstorage_syndicate/post_equip(mob/living/carbon/human/syndicate, visualsOnly = FALSE)
	syndicate.faction |= ROLE_SYNDICATE

/// Free Miner Ghostrole - Ported from Yogstation
/obj/effect/mob_spawn/ghost_role/human/free_miner
	name = "Free Miner"
	you_are_text = "You are an independent miner, making a living off salvage and selling materials mined out of the asteroids left behind when Nanotrasen moved their mining operations planetside."
	flavour_text = "You recently came out of bluespace jump into a relatively mineral-rich system, with a large Nanotrasen station nearby - Space Station 13."
	important_text = "Listen to your captain, and try not to get into trouble with corporate forces."
	outfit = /datum/outfit/freeminer
	prompt_name = "a free miner"
	spawner_job_path = /datum/job/free_miner

/datum/job/free_miner
	title = ROLE_FREE_MINER //so you can track hours


/datum/outfit/freeminer
	name = "Free Miner"
	uniform = /obj/item/clothing/under/rank/cargo/miner
	shoes = /obj/item/clothing/shoes/workboots/mining
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack/industrial
	l_pocket = /obj/item/mining_voucher
	r_pocket = /obj/item/storage/bag/ore
	belt = /obj/item/pickaxe
	id = /obj/item/card/id/advanced/old
	id_trim = /datum/id_trim/job/away/old/freeminer
	box = /obj/item/storage/box/survival/engineer


/datum/id_trim/job/away/old/freeminer
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_AWAY_GENERIC1,
		ACCESS_MINERAL_STOREROOM
	)
	assignment = "Independent Miner"
	sechud_icon_state = SECHUD_EXPLORER_AWAY

/obj/effect/mob_spawn/ghost_role/human/free_miner/engineer
	name = "Free Miner Engineer"
	you_are_text = "You are an engineer, working with some independent miners who are making a living off salvage and selling materials mined out of the asteroids left behind when Nanotrasen moved their mining operations planetside."
	important_text = "Listen to your captain, and try not to get into trouble with corporate forces."
	outfit = /datum/outfit/freeminer/engineer
	prompt_name = "a free miner engineer"

/datum/outfit/freeminer/engineer
	name = "Free Miner Engineer"
	uniform = /obj/item/clothing/under/rank/engineering/engineer/hazard
	shoes = /obj/item/clothing/shoes/workboots/independent
	gloves = /obj/item/clothing/gloves/color/yellow
	back = /obj/item/storage/backpack/industrial
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/flashlight
	belt = /obj/item/storage/belt/utility/full/engi
	backpack_contents = list(
		/obj/item/grenade/chem_grenade/smart_metal_foam = 3,
		/obj/item/inducer = 1,
	)
	id_trim = /datum/id_trim/job/away/old/freeminer/engineer

/datum/id_trim/job/away/old/freeminer/engineer
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_AWAY_MAINTENANCE,
		ACCESS_AWAY_GENERIC1,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_ENGINE_EQUIP,
		ACCESS_RESEARCH //meant to stay shipside and do engi and research
	)
	assignment = "Independent Engineer"
	sechud_icon_state = SECHUD_STATION_ENGINEER_AWAY

/obj/effect/mob_spawn/ghost_role/human/free_miner/captain
	name = "Free Miner Captain"
	you_are_text = "You are the Captain of a small ship operating independently from the major powers in the region - that being Nanotrasen and the Syndicate - trying to make ends meet by pulling out the minerals located in the asteroids Nanotrasen left behind."
	flavour_text = "You recently charted a bluespace jump into a mineral-rich system. Though Nanotrasen has major influence here, beyond their station there are very few who will take notice."
	important_text = "Avoid getting in trouble with the corporate powers and the local government. Mine ore and keep the ship afloat."
	outfit = /datum/outfit/freeminer/captain
	prompt_name = "a free miner captain"

/datum/outfit/freeminer/captain
	name = "Free Miner Captain"
	uniform = /obj/item/clothing/under/rank/captain/nova/utility
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/satchel/leather
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/melee/baton/telescopic
	belt = null
	id_trim = /datum/id_trim/job/away/old/freeminer/captain
	r_hand = /obj/item/megaphone/command

/datum/id_trim/job/away/old/freeminer/captain
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_AWAY_COMMAND, //LOOK AT ME
		ACCESS_AWAY_MAINTENANCE,
		ACCESS_AWAY_GENERIC1,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_ENGINE_EQUIP,
		ACCESS_RESEARCH
	)
	assignment = "Skipper" //SKIPPER INNIT (old name for captain)
	sechud_icon_state = SECHUD_CAPTAIN //todo: make it have a grey background like the others. should be fine with just regular cappie though for now, the mindshield can distinguish it lmao

/obj/machinery/computer/shuttle/freeminer
	name = "free miner shuttle console"
	shuttleId = "freeminer"
	desc = "The helm console of the Free Miner shuttle."
	circuit = /obj/item/circuitboard/computer/freeminer_helm
	possible_destinations = "whiteship_away;whiteship_home;whiteship_z4;whiteship_waystation;whiteship_lavaland;freeminer_custom;freeminer_asteroid;freeminer_away"

/obj/item/circuitboard/computer/freeminer_helm
	name = "free miner helm (Computer Board)"
	build_path = /obj/machinery/computer/shuttle/freeminer

/obj/machinery/computer/camera_advanced/shuttle_docker/freeminer
	name = "free miner navigation console"
	desc = "A console used to navigate the Free Miner shuttle."
	circuit = /obj/item/circuitboard/computer/freeminer_nav
	shuttleId = "freeminer"
	lock_override = NONE
	shuttlePortId = "freeminer_custom"
	jump_to_ports = list("whiteship_away" = 1, "whiteship_home" = 1, "whiteship_z4" = 1, "whiteship_waystation" = 1, "freeminer_asteroid" = 1, "freeminer_away" = 1)
	view_range = 10
	x_offset = -6
	y_offset = -10

/obj/item/circuitboard/computer/freeminer_nav
	name = "free miner navigation (Computer Board)"
	build_path = /obj/machinery/computer/camera_advanced/shuttle_docker/freeminer
