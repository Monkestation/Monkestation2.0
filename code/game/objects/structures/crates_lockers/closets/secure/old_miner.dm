/obj/structure/closet/secure_closet/miner_medical
	name = "mining medic's locker"
	desc = "You put important stuff here with a lot of trust towards miners."
	icon_state = "med_secure"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/miner_medical/PopulateContents()
	..()
	new /obj/item/storage/bag/garment/miner_medical(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/binoculars(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/sensor_device(src)
	new /obj/item/bodybag/environmental(src)
	new /obj/item/extinguisher/mini(src)
	new /obj/item/reagent_containers/medigel/synthflesh(src)
	var/obj/item/key/atv/K = new(src)
	K.desc += " Don't let those goddamn ashwalkers or plantpeople get it."

/obj/item/storage/bag/garment/miner_medical
	name = "Old garment bag"
	desc = "A bag for storing extra clothes and shoes. This one belongs to... who?"

/obj/item/storage/bag/garment/miner_medical/PopulateContents()
	new /obj/item/clothing/suit/toggle/labcoat/paramedic/explorer(src)
	new /obj/item/clothing/suit/toggle/labcoat/explorer(src)
	new /obj/item/clothing/head/soft/paramedic/mining(src)
	new /obj/item/clothing/head/beret/medical/paramedic/mining(src)
	new /obj/item/clothing/under/rank/cargo/miner_medic(src)
	new /obj/item/storage/belt/medical/mining(src)
	new /obj/item/clothing/glasses/hud/health/meson(src)
	new /obj/item/clothing/gloves/latex/fireproof(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/clothing/mask/gas/explorer(src)

	var/obj/item/radio/headset/headset_med/headset = new(src)
	headset.keyslot2 = new /obj/item/encryptionkey/headset_cargo(headset)
	headset.recalculateChannels()

// Missing adv med hud and madness protection on purpose. It's OLD
/obj/item/clothing/glasses/hud/health/meson
	name = "modified health scanner HUD"
	desc = "An old medical heads-up display thats modified with a weaker optical meson scanner, despite the age miners would still gladly commit manslaughter for this."
	hud_type = DATA_HUD_MEDICAL_BASIC
	vision_flags = SEE_TURFS
	color_cutoffs = list(5, 5, 15)

/obj/item/storage/belt/medical/mining
	name = "medical-adapted explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike. This one has several modifications making it suitable to hold medicine"
	icon_state = "explorer2"
	inhand_icon_state = "explorer2"
	worn_icon_state = "explorer2"

/obj/item/clothing/gloves/latex/fireproof
	name = "fireproof sterile gloves"
	desc = "Durable, thick and heat-resistant sterile gloves, however surgery with them would prove to be difficult. Transfers exhaustive paramedic knowledge into the user via nanochips."
	icon_state = "mining_medic"
	resistance_flags = FIRE_PROOF
	clothing_traits = list(TRAIT_QUICKER_CARRY, TRAIT_RESISTHEATHANDS)

/obj/item/clothing/under/rank/cargo/miner_medic
	name = "strange jumpsuit"
	desc = "A very strange looking blue and white uniform with a blue cross on its back."
	icon_state = "mining_medic"
	armor_type = /datum/armor/cargo_miner
	resistance_flags = NONE
	can_adjust = FALSE
	random_sensor = FALSE
	sensor_mode = 3
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/suit/toggle/labcoat/paramedic/explorer
	name = "modified paramedic's jacket"
	desc = "A dark blue jacket for paramedics with reflective stripes. This one looks to be modified with steel plating."
	armor_type = /datum/armor/miner_medic

/obj/item/clothing/suit/toggle/labcoat/explorer
	name = "modified labcoat"
	desc = "A suit that protects against minor chemical spills. This one looks to have steel plates on the inside and a brown plus symbol on the back and shoulders."
	icon_state = "labcoat_mining"
	armor_type = /datum/armor/miner_medic

/datum/armor/miner_medic
	melee = 25
	bullet = 5
	laser = 5
	energy = 5
	bomb = 50
	bio = 100
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/head/soft/paramedic/mining
	name = "modified paramedic cap"
	desc = "It's a baseball hat with a dark turquoise color with a reflective cross on the top. This one has MM embossed into it and durathread lining the inside."
	armor_type = /datum/armor/miner_medic_head

/obj/item/clothing/head/beret/medical/paramedic/mining
	name = "modified paramedic beret"
	desc = "For finding corpses in style! This one has MM embossed into it and durathread lining the inside."
	armor_type = /datum/armor/miner_medic_head

/datum/armor/miner_medic_head
	melee = 10
	bullet = 10
	bio = 50
	fire = 50
	acid = 50
