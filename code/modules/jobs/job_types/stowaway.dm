/**
 * Copy of Unassigned Crewmember, so Stowaways appear properly in ghost orbit and playtime.
 **/

/datum/job/stowaway
	title = JOB_STOWAWAY
	rpg_title = "Wanderer"
	paycheck = PAYCHECK_ZERO
	outfit = /datum/outfit/job/stowaway
	allow_bureaucratic_error = FALSE
	family_heirlooms = list( //vaguely ordered from least to most useful
		/obj/item/book/greytider_ninja,
		/obj/item/trash/candle,
		/obj/item/dice/d1,
		/obj/item/paper/crumpled,
		/obj/item/toy/talking/owl,
		/obj/item/toy/talking/griffin,
		/obj/item/soap/homemade/stowaway, //through the power of not cleaning themselves, the stowaways have passed this bar down for generations
		/obj/item/toy/katana,
		/obj/item/pillow,
		/obj/item/bong,
		/obj/item/knife/shiv,
		/obj/item/pen,
		/obj/item/modular_computer/pda, //JACKPOT!!
	)

/datum/outfit/job/stowaway
	name = JOB_STOWAWAY
	jobtype = /datum/job/stowaway
	uniform = /obj/item/clothing/under/color/grey
	l_pocket = /obj/item/radio

	backpack = /obj/item/storage/bag/trash/stowaway
	satchel = /obj/item/storage/bag/trash/stowaway
	duffelbag = /obj/item/storage/bag/trash/stowaway

	shoes = null
	ears = null
	belt = null
