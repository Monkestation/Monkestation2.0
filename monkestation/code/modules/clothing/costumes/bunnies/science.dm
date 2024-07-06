//Scientist

/obj/item/clothing/head/playbunnyears/scientist
	name = "scientist's bunny ears"
	desc = "Purple and white bunny ears attached to a headband. Completes the look for lagomorphic studies."
	icon_state = "science"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/rnd/scientist/bunnysuit
	desc = "The staple of any bunny themed scientists. Smart bunnies, Hef."
	name = "scientist's bunnysuit"
	icon_state = "bunnysuit_sci"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/scientist/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/science_tailcoat
	name = "scientist's tailcoat"
	desc = "A smart white coat worn by bunny themed scientists. Decent protection against slimes."
	icon_state = "science"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/scientist
	name = "scientist's bowtie"
	desc = "A purple tie that includes a collar. Looking intelligent!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_science_tied"
	tie_type = "bowtie_collar_science"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/scientist/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/scientist
	greyscale_colors = null
	flags_1 = null

//Roboticist

/obj/item/clothing/head/playbunnyears/roboticist
	name = "roboticist's bunny ears"
	desc = "Black and red bunny ears attached to a headband. Installed with servos to imitate the movement of real bunny ears."
	icon_state = "roboticist"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/rnd/scientist/roboticist_bunnysuit
	desc = "The staple of any bunny themed roboticists. The open design and thin leggings help to keep cool when piloting mechs."
	name = "roboticist's bunnysuit"
	icon_state = "bunnysuit_roboticist"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/scientist/roboticist_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/roboticist_tailcoat
	name = "roboticist's tailcoat"
	desc = "A smart white coat with red pauldrons worn by bunny themed roboticists. Looks surprisingly good with oil stains on it."
	icon_state = "roboticist"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/roboticist
	name = "roboticist's bowtie"
	desc = "A red tie that includes a collar. Looking transhumanist!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_roboticist_tied"
	tie_type = "bowtie_collar_roboticist"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/roboticist/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/roboticist
	greyscale_colors = "#39393f"
	flags_1 = null

//Geneticist

/obj/item/clothing/head/playbunnyears/geneticist
	name = "geneticist's bunny ears"
	desc = "Blue and white bunny ears attached to a headband. For when you have no bunnies to splice your genes with."
	icon_state = "genetics"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/rnd/geneticist/bunnysuit
	desc = "The staple of any bunny themed geneticists. Doesn’t go great with an abominable green muscled physique, but then again, what does?"
	name = "geneticist's bunnysuit"
	icon_state = "bunnysuit_genetics"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/geneticist/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/toggle/labcoat/geneticist_tailcoat
	name = "geneticist's tailcoat"
	desc = "A smart white and blue coat worn by bunny themed geneticists. Nearly looks like a real doctor's lab coat."
	icon_state = "genetics"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN
	species_exception = null

/obj/item/clothing/neck/tie/bunnytie/geneticist
	name = "geneticist's bowtie"
	desc = "A blue tie that includes a collar. Looking aberrant!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_genetics_tied"
	tie_type = "bowtie_collar_genetics"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/geneticist/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/geneticist
	greyscale_colors = null
	flags_1 = null

//Research Director

/obj/item/clothing/head/playbunnyears/rd
	name = "research director's bunny ears"
	desc = "Purple and black bunny ears attached to a headband. Large amounts of funding went into creating a piece of headgear capable of increasing the wearers height, this is what was produced."
	icon_state = "rd"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/rnd/research_director/bunnysuit
	desc = "The staple of any bunny themed head researchers. Advanced technology allows this suit to stimulate spontaneous bunny tail growth when worn, though it's nigh-indistinguishable from the standard cottonball and disappears as soon as the suit is removed."
	name = "research director's bunnysuit"
	icon_state = "bunnysuit_rd"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/research_director/tailcoat
	name = "research director's tailcoat"
	desc = "A smart purple coat worn by bunny themed head researchers. Created from captured abductor technology, what looks like a coat is actually an advanced hologram emitted from the pauldrons. Feels exactly like the real thing, too."
	icon_state = "rd"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|ARMS|GROIN

/obj/item/clothing/neck/tie/bunnytie/rd
	name = "research director's bowtie"
	desc = "A purple tie that includes a collar. Looking inventive!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_science_tied"
	tie_type = "bowtie_collar_science"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/scientist/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/rd
	greyscale_colors = "#7e1980"
	flags_1 = null
