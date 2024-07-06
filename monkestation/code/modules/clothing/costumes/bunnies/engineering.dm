//Engineer

/obj/item/clothing/head/playbunnyears/engineer
	name = "engineering bunny ears"
	desc = "Yellow and orange bunny ears attached to a headband. Likely to get caught in heavy machinery."
	icon_state = "engi"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/engineering/engineer_bunnysuit
	name = "engineering bunny suit"
	desc = "The staple of any bunny themed engineers. Keeps loose clothing to a minimum in a fashionable manner."
	icon_state = "bunnysuit_engi"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/engineering/engineer_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/engineer
	name = "engineering tailcoat"
	desc = "A high visibility tailcoat worn by bunny themed engineers. Great for working in low-light conditions."
	icon_state = "engi"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null
	allowed = list(
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/flashlight,
		/obj/item/radio,
		/obj/item/storage/bag/construction,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/t_scanner,
		/obj/item/gun/ballistic/rifle/boltaction/pipegun/prime,
	)

/obj/item/clothing/neck/tie/bunnytie/engineer
	name = "engineering bowtie"
	desc = "An orange tie that includes a collar. Looking industrious!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_engi_tied"
	tie_type = "bowtie_collar_engi"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/engineer/tied
	is_tied = TRUE

/obj/item/clothing/shoes/workboots/heeled
	name = "heeled work boots"
	desc = "Nanotrasen-issue Engineering lace-up work heels that seem almost especially designed to cause a workplace accident."
	icon_state = "workboots_heeled"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/heeled_shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/heeled_shoes_worn.dmi'
	species_exception = null

//Atmospheric Technician

/obj/item/clothing/head/playbunnyears/atmos_tech
	name = "atmospheric technician's bunny ears"
	desc = "Yellow and blue bunny ears attached to a headband. Gives zero protection against both fires and extreme pressures."
	icon_state = "atmos"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/engineering/atmos_tech_bunnysuit
	name = "atmospheric technician's bunny suit"
	desc = "The staple of any bunny themed atmospheric technicians. Perfect for any blue collar worker wanting to keep up with fashion trends."
	icon_state = "bunnysuit_atmos"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/engineering/atmos_tech_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/utility/fire/atmos_tech_tailcoat
	name = "atmospheric technician's tailcoat"
	desc = "A heavy duty fire-tailcoat worn by bunny themed atmospheric technicians. Reinforced with asbestos weave that makes this both stylish and lung-cancer inducing."
	icon_state = "atmos"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	body_parts_covered = CHEST|GROIN|ARMS
	slowdown = 0
	armor_type = /datum/armor/atmos_tech_tailcoat
	flags_inv = null
	clothing_flags = null
	min_cold_protection_temperature = null
	max_heat_protection_temperature = null
	strip_delay = 30
	equip_delay_other = 30

/datum/armor/atmos_tech_tailcoat
	melee = 10
	bullet = 5
	laser = 10
	energy = 10
	bomb = 20
	bio = 50
	fire = 100
	acid = 50

/obj/item/clothing/neck/tie/bunnytie/atmos_tech
	name = "atmospheric technician's bowtie"
	desc = "A blue tie that includes a collar. Looking inflammable!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_atmos_tied"
	tie_type = "bowtie_collar_atmos"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/atmos_tech/tied
	is_tied = TRUE

//Chief Engineer

/obj/item/clothing/head/playbunnyears/ce
	name = "chief engineer's bunny ears"
	desc = "Green and white bunny ears attached to a headband. Just keep them away from the supermatter."
	icon_state = "ce"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/engineering/chief_engineer/bunnysuit
	name = "chief engineer's bunny suit"
	desc = "The staple of any bunny themed chief engineers. The airy design helps with keeping cool when  engine fires get too hot to handle."
	icon_state = "bunnysuit_ce"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/engineering/chief_engineer/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/utility/fire/ce_tailcoat
	name = "chief engineer's tailcoat"
	desc = "A heavy duty green and white coat worn by bunny themed chief engineers. Made of a three layered composite fabric that is both insulating and fireproof, it also has an open face rendering all this useless."
	icon_state = "ce"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	body_parts_covered = CHEST|GROIN|ARMS
	slowdown = 0
	armor_type = /datum/armor/ce_tailcoat
	flags_inv = null
	clothing_flags = null
	min_cold_protection_temperature = null
	max_heat_protection_temperature = null
	strip_delay = 30
	equip_delay_other = 30

/datum/armor/ce_tailcoat
	melee = 10
	bullet = 5
	laser = 10
	energy = 10
	bomb = 20
	bio = 50
	fire = 100
	acid = 50

/obj/item/clothing/neck/tie/bunnytie/ce
	name = "chief engineer's bowtie"
	desc = "A green tie that includes a collar. Looking managerial!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_ce_tied"
	tie_type = "bowtie_collar_ce"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/ce/tied
	is_tied = TRUE
