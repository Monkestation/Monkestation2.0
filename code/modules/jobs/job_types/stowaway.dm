/**
 * Copy of Unassigned Crewmember, so Stowaways appear properly in ghost orbit and playtime.
 **/

/datum/job/stowaway
	title = "Stowaway"
	rpg_title = "Wanderer"
	paycheck = PAYCHECK_ZERO
	outfit = /datum/outfit/job/stowaway
	allow_bureaucratic_error = FALSE
	family_heirlooms = list(
		/obj/item/toy/katana,
		/obj/item/crowbar/large/emergency, //RIP your belt slot
		/obj/item/knife/shiv,
		/obj/item/book/greytider_ninja,
		/obj/item/toy/talking/owl,
		/obj/item/toy/talking/griffin,
		/obj/item/pen,
		/obj/item/modular_computer/pda, //JACKPOT!!
	)

/datum/outfit/job/stowaway
	name = "Stowaway"
	jobtype = /datum/job/stowaway
	uniform = /obj/item/clothing/under/color/grey
	belt = /obj/item/storage/bag/trash/stowaway
	l_pocket = /obj/item/radio

	shoes = null
	ears = null

	backpack = null
	satchel = null
	duffelbag = null
