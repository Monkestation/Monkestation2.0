
//generally nanotrasen themed corpses

/obj/effect/mob_spawn/corpse/human/bridgeofficer
	name = "Bridge Officer"
	outfit = /datum/outfit/nanotrasenbridgeofficer

/datum/outfit/nanotrasenbridgeofficer
	name = "Bridge Officer"
	ears = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/centcom/officer
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/bridge_officer

/obj/effect/mob_spawn/corpse/human/commander
	name = "Commander"
	outfit = /datum/outfit/nanotrasencommander

//MONKESTATION EDIT START
/datum/outfit/nanotrasencommander
	name = "Nanotrasen Private Security Commander Corpse"
	uniform = /obj/item/clothing/under/rank/centcom/private_sec/lieutenant
	suit = /obj/item/clothing/suit/armor/vest
	ears = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/gas/sechailer/swat/private_sec
	head = /obj/item/clothing/head/beret/private_sec/lieutenant
	back = /obj/item/storage/backpack/satchel/leather
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/combat/swat
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/clothing/mask/cigarette/cigar/cohiba
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/commander
//MONKESTATION EDIT STOP

/obj/effect/mob_spawn/corpse/human/nanotrasensoldier
	name = "\improper Nanotrasen Private Security Officer"
	outfit = /datum/outfit/nanotrasensoldier

//MONKESTATION EDIT START
/datum/outfit/nanotrasensoldier
	name = "Nanotrasen Private Security Officer Corpse" //monkestation edit
	uniform = /obj/item/clothing/under/rank/centcom/private_sec
	suit = /obj/item/clothing/suit/armor/vest
	ears = /obj/item/radio/headset/headset_sec/alt
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	mask = null
	head = /obj/item/clothing/head/helmet/swat/private_sec
	back = /obj/item/storage/backpack/private_sec
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/centcom/corpse/private_security

/datum/outfit/nanotrasensoldier/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	mask = pick(/obj/item/clothing/mask/gas/sechailer/swat/private_sec, /obj/item/clothing/mask/gas/sechailer/swat/private_sec/alt)
//MONKESTATION EDIT STOP

/obj/effect/mob_spawn/corpse/human/intern //this is specifically the comms intern from the event
	name = "CentCom Intern"
	outfit = /datum/outfit/centcom/centcom_intern/unarmed
	mob_name = "Nameless Intern"

/obj/effect/mob_spawn/corpse/human/intern/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.gender = MALE //we're making it canon babies
	spawned_human.update_body()
