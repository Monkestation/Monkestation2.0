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
	name = "Nanotrasen Officer"
	role = "Nanotrasen Officer"
	outfit = /datum/outfit/centcom/ert/generic

/datum/outfit/centcom/ert/generic
	name = "Nanotrasen Officer"

	box = /obj/item/storage/box/survival/centcom
	uniform = /obj/item/clothing/under/rank/centcom/officer
	ears = /obj/item/radio/headset/headset_cent/alt
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat/ert
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/space/ert
	suit_store = /obj/item/gun/energy/e_gun
	head = /obj/item/clothing/head/helmet/space/ert
	belt = /obj/item/storage/belt/security/full/advanced
	back = /obj/item/storage/backpack/ert/generic
	backpack_contents = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/tank/jetpack/oxygen/harness = 1,
	)
	glasses = /obj/item/clothing/glasses/sunglasses/big
