//Doctor

/obj/item/clothing/head/playbunnyears/doctor
	name = "medical bunny ears"
	desc = "White and blue bunny ears attached to a headband. Certainly cuter than a head mirror."
	icon_state = "doctor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/medical/doctor_bunnysuit
	desc = "The staple of any bunny themed doctors. The open design is great for both comfort and surgery."
	name = "medical bunnysuit"
	icon_state = "bunnysuit_doctor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/medical/doctor_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/doctor_tailcoat
	name = "medical tailcoat"
	desc = "A sterile white and blue coat worn by bunny themed doctors. Great for keeping the blood off."
	icon_state = "doctor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/doctor
	name = "medical bowtie"
	desc = "A light blue tie that includes a collar. Looking helpful!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_doctor_tied"
	tie_type = "bowtie_collar_doctor"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/doctor/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/white
	name = "white heels"
	greyscale_colors = "#ffffff"
	flags_1 = null

//Paramedic

/obj/item/clothing/head/playbunnyears/paramedic
	name = "paramedic's bunny ears"
	desc = "Blue and white bunny ears attached to a headband. Marks you clearly as a bunny first responder, allowing you a high degree of respect and deference… yeah right."
	icon_state = "paramedic"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/medical/paramedic_bunnysuit
	desc = "The staple of any bunny themed paramedics. Comes with spare pockets for medical supplies fastened to the leggings."
	name = "paramedic's bunnysuit"
	icon_state = "bunnysuit_paramedic"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/medical/paramedic_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/paramedic_tailcoat
	name = "paramedic's tailcoat"
	desc = "A heavy duty coat worn by bunny themed paramedics. Marked with high visibility lines for emergency operations in the dark."
	icon_state = "paramedic"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/paramedic
	name = "paramedic's bowtie"
	desc = "A white tie that includes a collar. Looking selfless!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_paramedic_tied"
	tie_type = "bowtie_collar_paramedic"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/paramedic/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/darkblue
	name = "dark blue heels"
	greyscale_colors = "#364660"
	flags_1 = null

//Chemist

/obj/item/clothing/head/playbunnyears/chemist
	name = "chemist's bunny ears"
	desc = "White and orange bunny ears attached to a headband. One of the ears is already crooked."
	icon_state = "chem"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/medical/chemist/bunnysuit
	desc = "The staple of any bunny themed chemists. The stockings are both airy and acid resistant."
	name = "chemist's bunnysuit"
	icon_state = "bunnysuit_chem"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/medical/chemist/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/chemist_tailcoat
	name = "chemist's tailcoat"
	desc = "A sterile white and orange coat worn by bunny themed chemists. The open chest isn't the greatest when working with dangerous substances."
	icon_state = "chem"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/chemist
	name = "chemist's bowtie"
	desc = "An orange tie that includes a collar. Looking explosive!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_chem_tied"
	tie_type = "bowtie_collar_chem"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/chemist/tied
	is_tied = TRUE

//Pathologist

/obj/item/clothing/head/playbunnyears/pathologist
	name = "pathologist's bunny ears"
	desc = "White and green bunny ears attached to a headband. This is not proper PPE gear."
	icon_state = "virologist"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/medical/pathologist_bunnysuit
	desc = "The staple of any bunny themed pathologists. The stockings, while cute, do nothing to combat pathogens."
	name = "pathologist's bunnysuit"
	icon_state = "bunnysuit_viro"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/medical/pathologist_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/pathologist_tailcoat
	name = "pathologist's tailcoat"
	desc = "A sterile white and green coat worn by bunny themed pathologists. The more stylish and ineffective alternative to a biosuit."
	icon_state = "virologist"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/pathologist
	name = "pathologist's bowtie"
	desc = "A green tie that includes a collar. Looking infectious!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_virologist_tied"
	tie_type = "bowtie_collar_virologist"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/pathologist/tied
	is_tied = TRUE

// Chief Medical Officer

/obj/item/clothing/head/playbunnyears/cmo
	name = "chief medical officer's bunny ears"
	desc = "White and blue bunny ears attached to a headband. A headband that commands respect from the entire medical team."
	icon_state = "cmo"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/medical/cmo_bunnysuit
	desc = "The staple of any bunny themed chief medical officers. The more vibrant blue accents denote a higher status."
	name = "chief medical officer's bunnysuit"
	icon_state = "bunnysuit_cmo"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/medical/cmo_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/cmo_tailcoat
	name = "chief medical officer's tailcoat"
	desc = "A sterile blue coat worn by bunny themed chief medical officers. The blue helps both the wearer and bloodstains stand out from other, lower ranked, and cleaner doctors."
	icon_state = "cmo"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/cmo
	name = "chief medical officer's bowtie"
	desc = "A blue tie that includes a collar. Looking responsible!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_cmo_tied"
	tie_type = "bowtie_collar_cmo"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/cmo/tied
	is_tied = TRUE

