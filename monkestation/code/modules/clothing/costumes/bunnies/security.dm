//Security Officer

/obj/item/clothing/head/playbunnyears/security
	name = "security bunny ears"
	desc = "Red and black bunny ears attached to a headband. The band is made out of hardened steel."
	icon_state = "sec"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	clothing_flags = SNUG_FIT
	armor_type = /datum/armor/playbunnyears_security
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/playbunnyears_security
	melee = 30
	bullet = 30
	laser = 20
	energy = 30
	fire = 30
	bomb = 20
	acid = 30
	wound = 10

/obj/item/clothing/under/rank/security/security_bunnysuit
	desc = "The staple of any bunny themed security officers. The red coloring helps to hide any blood that may stain this."
	name = "security bunnysuit"
	icon_state = "bunnysuit_sec"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/security_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/armor/security_tailcoat
	name = "security tailcoat"
	desc = "A reinforced tailcoat worn by bunny themed security officers. Uses the same lightweight armor as the MK 1 vest, though obviously has lighter protection in the chest area."
	icon_state = "sec"
	inhand_icon_state = "armor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	dog_fashion = null
	armor_type = /datum/armor/security_tailcoat

/datum/armor/security_tailcoat
	melee = 30
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 70
	acid = 90
	wound = 10

/obj/item/clothing/neck/tie/bunnytie/security
	name = "security bowtie"
	desc = "A red tie that includes a collar. Looking tough!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_sec_tied"
	tie_type = "bowtie_collar_sec"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/security/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/security
	greyscale_colors = "#a52f29"
	flags_1 = null

//Warden

/obj/item/clothing/head/playbunnyears/warden
	name = "warden's bunny ears"
	desc = "Red and white bunny ears attached to a headband. Keeps the hair out of the face when checking on cameras."
	icon_state = "warden"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	clothing_flags = SNUG_FIT
	armor_type = /datum/armor/playbunnyears_warden
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/playbunnyears_warden
	melee = 30
	bullet = 30
	laser = 20
	energy = 30
	fire = 30
	bomb = 20
	acid = 30
	wound = 10

/obj/item/clothing/under/rank/security/warden_bunnysuit
	desc = "The staple of any bunny themed wardens. The more formal security bunny suit for a less combat focused job."
	name = "warden's bunnysuit"
	icon_state = "bunnysuit_warden"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/warden_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/armor/warden_tailcoat
	name = "warden's tailcoat"
	desc = "A reinforced tailcoat worn by bunny themed wardens. Stylishly holds hidden flak plates."
	icon_state = "warden"
	inhand_icon_state = "armor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	dog_fashion = null
	armor_type = /datum/armor/warden_tailcoat

/datum/armor/warden_tailcoat
	melee = 30
	bullet = 35
	laser = 30
	energy = 25
	bomb = 20
	fire = 50
	acid = 50
	wound = 10

//Brig Physician

/obj/item/clothing/head/playbunnyears/brig_phys
	name = "brig physician's bunny ears"
	desc = "A pair of red and grey bunny ears attatched to a headband. Whoever's wearing these is surely a professional... right?"
	icon_state = "brig_phys"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/security/brig_phys_bunnysuit
	desc = "The staple of any bunny themed brig physicians. The rejected alternative to an already discontinued alternate uniform, now sold at a premium!"
	name = "brig physician's bunnysuit"
	icon_state = "bunnysuit_brig_phys"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/brig_phys_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/brig_phys_tailcoat
	name = "brig physician's tailcoat"
	desc = "A mostly sterile red and grey coat worn by bunny themed brig physicians. It lacks the padding of the \"standard\" security tailcoat."
	icon_state = "brig_phys"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/brig_phys
	name = "brig physician's bowtie"
	desc = "A red tie that includes a collar. Looking underappreciated!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_brig_phys_tied"
	tie_type = "bowtie_collar_brig_phys"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/brig_phys/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/brig_phys
	greyscale_colors = "#918f8c"
	flags_1 = null

//Detective

/obj/item/clothing/head/playbunnyears/detective
	name = "detective's bunny ears"
	desc = "Brown bunny ears attached to a headband. Big ears for listening to calls from hysteric dames."
	icon_state = "detective"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	armor_type = /datum/armor/playbunnyears_detective
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/playbunnyears_detective
	melee = 20
	laser = 20
	energy = 30
	fire = 30
	acid = 50
	wound = 5

/obj/item/clothing/under/rank/security/detective_bunnysuit
	desc = "The staple of any bunny themed detectives. Capable of storing precious candy corns."
	name = "detective's bunnysuit"
	icon_state = "bunnysuit_det"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/detective_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/det_suit/tailcoat
	name = "detective's tailcoat"
	desc = "A reinforced tailcoat worn by bunny themed detectives. Perfect for a hard boiled no-nonsense type of gal."
	icon_state = "detective"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'

/obj/item/clothing/neck/tie/bunnytie/detective
	name = "detective's tie collar"
	desc = "A brown tie that includes a collar. Looking inquisitive!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "tie_collar_det_tied"
	tie_type = "tie_collar_det"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/detective/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/detective
	greyscale_colors = "#784f44"
	flags_1 = null

//Prisoner

/obj/item/clothing/head/playbunnyears/prisoner
	name = "prisoner's bunny ears"
	desc = "Black and orange bunny ears attached to a headband. This outfit was long ago outlawed under the space geneva convention for being a “cruel and unusual punishment”."
	icon_state = "prisoner"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/security/prisoner_bunnysuit
	desc = "The staple of any bunny themed prisoners. Great for hiding shanks and other small contrabands."
	name = "prisoner's bunnysuit"
	icon_state = "bunnysuit_prisoner"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/prisoner_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/neck/tie/bunnytie/prisoner
	name = "prisoner's bowtie"
	desc = "A black tie that includes a collar. Looking criminal!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_prisoner_tied"
	tie_type = "bowtie_collar_prisoner"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/prisoner/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/prisoner
	greyscale_colors = "#ff8d1e"
	flags_1 = null

//Head of Security

/obj/item/clothing/head/playbunnyears/hos
	name = "head of security's bunny ears"
	desc = "Red and gold bunny ears attached to a headband. Shows your authority over all bunny officers."
	icon_state = "hos"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	clothing_flags = SNUG_FIT
	armor_type = /datum/armor/playbunnyears_hos
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/playbunnyears_hos
	melee = 30
	bullet = 30
	laser = 20
	energy = 30
	fire = 30
	bomb = 20
	acid = 30
	wound = 10

/obj/item/clothing/under/rank/security/head_of_security/bunnysuit
	desc = "The staple of any bunny themed security commanders. Includes kevlar weave stockings and a gilded tail."
	name = "Head of Security's bunnysuit"
	icon_state = "bunnysuit_hos"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/head_of_security/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/armor/hos_tailcoat
	name = "head of security's tailcoat"
	desc = "A reinforced tailcoat worn by bunny themed security commanders. Enhanced with a special alloy for some extra protection and style."
	icon_state = "hos"
	inhand_icon_state = "armor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	dog_fashion = null
	armor_type = /datum/armor/hos_tailcoat
	strip_delay = 80

/datum/armor/hos_tailcoat
	melee = 30
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 70
	acid = 90
	wound = 10

/obj/item/clothing/shoes/jackboots/gogo_boots
	name = "tactical go-go boots"
	desc = "Highly tactical footwear designed to give you a better view of the battlefield."
	icon_state = "hos_boots"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/heeled_shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/heeled_shoes_worn.dmi'

