/datum/outfit/myststranger
	name = "A Mysterious Stranger"

	id = /obj/item/card/id/advanced/debug
	uniform = /obj/item/clothing/under/misc/patriotsuit
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/myststranger
	backpack_contents = list(
		/obj/item/melee/energy/axe = 1,
		/obj/item/debug/omnitool = 1,
		/obj/item/storage/medkit/combat_surgeon/stocked = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/bodybag/bluespace = 1,
		/obj/item/gun/ballistic/revolver/lone_wanderer = 1
	)
	belt = /obj/item/storage/belt/utility/chief/full
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/debug
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/magboots/advance
	mask = /obj/item/clothing/mask/chameleon

	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/myststranger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = "Mysterious Stranger"
	W.assignment = "???"
	W.update_label()
	W.update_icon()
