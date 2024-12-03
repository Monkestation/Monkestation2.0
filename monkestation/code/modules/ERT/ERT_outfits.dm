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

//------------
// Code Green
//------------

/datum/antagonist/ert/generic
	name = "Code Green Emergency Response Officer"
	role = "Officer"
	outfit = /datum/outfit/centcom/ert/generic
	ert_job_path = /datum/job/ert/generic

/datum/outfit/centcom/ert/generic
	name = "Code Green Emergency Response Officer"

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

/datum/antagonist/ert/generic/commander
	name = "Code Green Emergency Response Team Commander"
	role = "Commander"
	outfit = /datum/outfit/centcom/ert/generic/commander
	plasmaman_outfit = /datum/outfit/plasmaman/centcom_commander
	ert_job_path = /datum/job/ert/commander

/datum/outfit/centcom/ert/generic/commander
	name = "Code Green Emergency Response Team Commander"

	id = /obj/item/card/id/advanced/centcom/ert/generic/commander
	suit = /obj/item/clothing/suit/space/ert/commander
	head = /obj/item/clothing/head/helmet/space/ert/commander
	back = /obj/item/storage/backpack/ert/commander
	backpack_contents = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/knife/combat = 1,
		/obj/item/pinpointer/nuke = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	additional_radio = /obj/item/encryptionkey/heads/captain
	skillchips = list(/obj/item/skillchip/disk_verifier, /obj/item/skillchip/job/research_director)

/datum/antagonist/ert/generic/medical
	name = "Code Green Medical Response Officer"
	role = "Medical Officer"
	outfit = /datum/outfit/centcom/ert/generic/medical
	ert_job_path = /datum/job/ert/medical

/datum/outfit/centcom/ert/generic/medical
	name = "Code Green Medical Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/medical
	gloves = /obj/item/clothing/gloves/latex/nitrile
	suit = /obj/item/clothing/suit/space/ert/medical
	suit_store = /obj/item/gun/energy/e_gun/mini
	head = /obj/item/clothing/head/helmet/space/ert/medical
	back = /obj/item/storage/backpack/ert/medical
	backpack_contents = list(
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/belt/medical/paramedic = 1,
		/obj/item/defibrillator/compact/loaded = 1,
		/obj/item/emergency_bed = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	additional_radio = /obj/item/encryptionkey/headset_med
	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/antagonist/ert/generic/security
	name = "Code Green Security Response Officer"
	role = "Security Officer"
	outfit = /datum/outfit/centcom/ert/generic/security
	ert_job_path = /datum/job/ert/security

/datum/outfit/centcom/ert/generic/security
	name = "Code Green Security Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/security
	suit = /obj/item/clothing/suit/space/ert/security
	head = /obj/item/clothing/head/helmet/space/ert/security
	back = /obj/item/storage/backpack/ert/security
	backpack_contents = list(
		/obj/item/knife/combat = 1,
		/obj/item/grenade/flashbang = 2,
		/obj/item/storage/belt/security/full/bola = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/holosign_creator/security
	additional_radio = /obj/item/encryptionkey/headset_sec

/datum/antagonist/ert/generic/engineer
	name = "Code Green Engineering Response Officer"
	role = "Engineering Officer"
	outfit = /datum/outfit/centcom/ert/generic/engineer
	ert_job_path = /datum/job/ert/engineer

/datum/outfit/centcom/ert/generic/engineer
	name = "Code Green Engineering Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/engineer
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/ert/engineer
	suit_store = /obj/item/gun/energy/e_gun/mini
	head = /obj/item/clothing/head/helmet/space/ert/engineer
	back = /obj/item/storage/backpack/ert/engineer
	backpack_contents = list(
		/obj/item/storage/belt/utility/full/powertools = 1,
		/obj/item/storage/box/rcd_upgrades = 1,
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/rcd_ammo/large = 1,
		/obj/item/analyzer = 1,
		/obj/item/extinguisher/advanced = 1,
		/obj/item/pipe_dispenser = 1,
	)
	glasses = /obj/item/clothing/glasses/meson/engine
	additional_radio = /obj/item/encryptionkey/headset_eng
	skillchips = list(/obj/item/skillchip/job/engineer, /obj/item/skillchip/job/roboticist)

/datum/antagonist/ert/generic/janitor
	name = "Code Green Janitorial Response Officer"
	role = "Janitorial Officer"
	outfit = /datum/outfit/centcom/ert/generic/janitor
	ert_job_path = /datum/job/ert/janitor

/datum/outfit/centcom/ert/generic/janitor
	name = "Code Green Janitorial Response Officer"
	id = /obj/item/card/id/advanced/centcom/ert/generic/janitor
	shoes = /obj/item/clothing/shoes/magboots
	suit = /obj/item/clothing/suit/space/ert/janitor
	suit_store = /obj/item/gun/energy/e_gun/mini
	head = /obj/item/clothing/head/helmet/space/ert/janitor
	back = /obj/item/storage/backpack/ert/janitor
	backpack_contents = list(
		/obj/item/storage/belt/janitor/full = 1,
		/obj/item/storage/box/lights/mixed = 1,
		/obj/item/mop/advanced = 1,
		/obj/item/reagent_containers/spray/drying = 1,
		/obj/item/grenade/chem_grenade/cleaner = 2,
		/obj/item/pushbroom = 1,
	)
	l_hand = /obj/item/storage/bag/trash
	additional_radio = /obj/item/encryptionkey/headset_service
	skillchips = list(/obj/item/skillchip/job/janitor)

/datum/antagonist/ert/generic/chaplain
	name = "Code Green Religious Response Officer"
	role = "Religious Officer"
	outfit = /datum/outfit/centcom/ert/generic/chaplain
	ert_job_path = /datum/job/ert/chaplain

/datum/antagonist/ert/generic/chaplain/on_gain()
	. = ..()
	owner.holy_role = HOLY_ROLE_PRIEST

/datum/outfit/centcom/ert/generic/chaplain
	name = "Code Green Religious Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/chaplain
	suit = /obj/item/clothing/suit/space/ert/chaplain
	suit_store = /obj/item/gun/energy/disabler
	head = /obj/item/clothing/head/helmet/space/ert/chaplain
	back = /obj/item/storage/backpack/ert
	backpack_contents = list(
		/obj/item/storage/belt/security/full/bola = 1,
		/obj/item/nullrod = 1,
		/obj/item/book/bible = 1,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1,
	)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	r_pocket = /obj/item/holosign_creator/security
	additional_radio = /obj/item/encryptionkey/headset_sec
	skillchips = list(/obj/item/skillchip/entrails_reader)

/datum/antagonist/ert/generic/clown
	name = "Code Honk Entertainment Response Officer"
	role = "Entertainment Officer"
	outfit = /datum/outfit/centcom/ert/generic/clown
	plasmaman_outfit = /datum/outfit/plasmaman/party_comedian
	ert_job_path = /datum/job/ert/clown

/datum/antagonist/ert/generic/clown/New()
	. = ..()
	name_source = GLOB.clown_names //they are a clown after all

/datum/outfit/centcom/ert/generic/clown
	name = "Code Honk Entertainment Response Officer"

	id = /obj/item/card/id/advanced/centcom/ert/generic/clown
	box = /obj/item/storage/box/survival/ert
	uniform = /obj/item/clothing/under/rank/civilian/clown
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/clown_hat
	shoes = /obj/item/clothing/shoes/clown_shoes
	suit = /obj/item/clothing/suit/space/ert/clown
	suit_store = null
	head = /obj/item/clothing/head/helmet/space/ert/clown
	belt = /obj/item/tank/jetpack/oxygen/harness
	back = /obj/item/storage/backpack/ert/clown
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower/lube = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/food/pie/cream = 3,
	)
	glasses = /obj/item/clothing/glasses/sunglasses
	l_pocket = /obj/item/bikehorn
	r_pocket = /obj/item/restraints/handcuffs/cable/zipties/fake
	implants = list(/obj/item/implant/sad_trombone)

/datum/outfit/centcom/ert/generic/clown/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	suit_store = pick(
			/obj/item/tank/internals/emergency_oxygen/engi/clown/n2o,
			/obj/item/tank/internals/emergency_oxygen/engi/clown/bz,
			/obj/item/tank/internals/emergency_oxygen/engi/clown/helium,
			)

/datum/outfit/centcom/ert/generic/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	H.dna.add_mutation(/datum/mutation/human/clumsy)
	for(var/datum/mutation/human/clumsy/M in H.dna.mutations)
		M.mutadone_proof = TRUE
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	ADD_TRAIT(H, TRAIT_NAIVE, INNATE_TRAIT)
	fan.show_to(H)
	H.faction |= FACTION_CLOWN
	if(!ishuman(H))
		return
	var/obj/item/organ/internal/butt/butt = H.get_organ_slot(ORGAN_SLOT_BUTT)
	if(butt)
		butt.Remove(H, 1)
		QDEL_NULL(butt)
		butt = new/obj/item/organ/internal/butt/clown
		butt.Insert(H)

	var/obj/item/organ/internal/bladder/bladder = H.get_organ_slot(ORGAN_SLOT_BLADDER)
	if(bladder)
		bladder.Remove(H, 1)
		QDEL_NULL(bladder)
		bladder = new/obj/item/organ/internal/bladder/clown
		bladder.Insert(H)
