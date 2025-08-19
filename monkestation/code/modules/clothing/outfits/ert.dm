/datum/outfit/revenger
	name = "Revenger"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/alt
	back = /obj/item/storage/backpack/ert
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/advanced/centcom/ert
	r_pocket = /obj/item/reagent_containers/hypospray/combat

/datum/outfit/revenger/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	if(name)
		H.fully_replace_character_name(null, name)
	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.assignment = "Revenger"
	W.registered_name = H.real_name
	W.update_label()
	H.apply_status_effect(/datum/status_effect/agent_pinpointer/revenger)
	H.gender = MALE
	ADD_TRAIT(H, TRAIT_TESLA_SHOCKIMMUNE, type)

/datum/outfit/revenger/hulk
	name = "Hulk"
	uniform = /obj/item/clothing/under/shorts/purple

/datum/outfit/revenger/hulk/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	if(H.dna)
		H.dna.add_mutation(/datum/mutation/hulk)
		H.update_body_parts()
	var/datum/martial_art/wrestling/wrestling = new
	wrestling.teach(H)

/datum/outfit/revenger/nano
	name = "Nano Guy"
	suit = /obj/item/clothing/suit/space/hardsuit/nano/nanoguy
	implants = list(/obj/item/implant/explosive)

/datum/outfit/revenger/nano/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/organ/internal/cyberimp/chest/reviver/reviver = new
	reviver.Insert(H)
	var/obj/item/organ/internal/cyberimp/brain/anti_stun/cns = new
	cns.Insert(H)
	var/obj/item/organ/internal/cyberimp/arm/nanoguy/nano_r = new
	nano_r.Insert(H)
	var/obj/item/organ/internal/cyberimp/arm/nanoguy/nano_l = new
	nano_l.zone = BODY_ZONE_L_ARM
	nano_l.SetSlotFromZone()
	nano_l.Insert(H)

/datum/outfit/revenger/captain
	name = "Captain Nanotrasen"
	l_pocket = /obj/item/shield/energy/bananium

/datum/outfit/revenger/captain/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	var/datum/martial_art/cqc/cqc = new
	cqc.teach(H)

/datum/outfit/revenger/thor
	name = "Thor"
	suit = /obj/item/clothing/suit/armor/thor

/datum/outfit/revenger/thor/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	if(prob(50))
		var/obj/item/reagent_containers/cup/glass/bottle/beer/beer = new(get_turf(H))
		H.put_in_hands(beer)
		H.nutrition = NUTRITION_LEVEL_FAT //Lmao
		H.facial_hairstyle = "Broken Man"
	else
		H.facial_hairstyle = "Long"

	var/datum/action/cooldown/spell/conjure_item/summon_mjollnir/summon_mj = new
	summon_mj.spell_requirements = NONE
	summon_mj.Grant(H)

	var/datum/action/cooldown/spell/pointed/projectile/lightningbolt/lightning = new
	lightning.spell_requirements = NONE
	lightning.Grant(H)
