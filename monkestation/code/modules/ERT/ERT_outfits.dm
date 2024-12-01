// this is going to be so much work but let's see how far i can get
//-----------------
// Ordering:
// ROLES
// *Generic
// *Commander
// *Medic
// *Security Officer
// *Engineer
// *Janitor
// *Chaplain
// *Clown
// OTHER

/datum/antagonist/ert/generic
	name = "Emergency Response Officer"
	role = "Emergency Response Officer"
	outfit = /datum/outfit/centcom/ert/generic

/datum/outfit/centcom/ert/generic
	name = "Emergency Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic
	box = /obj/item/storage/box/survival/ert
	uniform = /obj/item/clothing/under/rank/centcom/officer
	ears = /obj/item/radio/headset/headset_cent/alt
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat/ert
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/space/ert
	suit_store = /obj/item/gun/energy/e_gun
	head = /obj/item/clothing/head/helmet/space/ert
	belt = /obj/item/tank/jetpack/oxygen/harness
	back = /obj/item/storage/backpack/ert/generic
	backpack_contents = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/knife/combat = 1,
	)
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/restraints/handcuffs

/datum/outfit/centcom/ert/generic/medical
	name = "Medical Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/medical
	gloves = /obj/item/clothing/gloves/latex/nitrile
	suit = /obj/item/clothing/suit/space/ert/medical
	suit_store = /obj/item/gun/energy/disabler
	head = /obj/item/clothing/head/helmet/space/ert/medical
	back = /obj/item/storage/backpack/ert/medical
	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/belt/medical/paramedic = 1,
		/obj/item/defibrillator/compact/loaded = 1,
		/obj/item/emergency_bed = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
