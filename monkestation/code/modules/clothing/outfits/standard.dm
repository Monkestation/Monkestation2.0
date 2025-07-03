/datum/outfit/centcom/admiral
	name = "CentCom Admiral"

	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/admiral
	uniform = /obj/item/clothing/under/rank/centcom/admiral
	suit = /obj/item/clothing/suit/armor/centcom_admiral
	back = /obj/item/storage/backpack/satchel/leather
	belt = /obj/item/gun/ballistic/revolver/mateba
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated/admiral
	head = /obj/item/clothing/head/hats/warden/drill/centcom_admiral
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	shoes = /obj/item/clothing/shoes/combat/swat/admiral
	l_pocket = /obj/item/ammo_box/a357
	r_pocket = /obj/item/lighter

/datum/outfit/centcom/admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.registered_name = H.real_name
	W.update_label()
	W.update_icon()
	..()

/datum/outfit/centcom/admiral/mod
	name = "CentCom Admiral (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	suit = null
	head = null
	mask = /obj/item/clothing/mask/gas/sechailer
	back = /obj/item/mod/control/pre_equipped/corporate
	internals_slot = ITEM_SLOT_SUITSTORE
