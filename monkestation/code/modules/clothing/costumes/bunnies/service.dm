//Head of Personnel

/obj/item/clothing/head/playbunnyears/hop
	name = "head of personnel's bunny ears"
	desc = "A pair of muted blue bunny ears attached to a headband. The preferred color of bureaucrats everywhere."
	icon_state = "hop"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	armor_type = /datum/armor/playbunnyears_hop
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/playbunnyears_hop
	melee = 20
	bullet = 10
	laser = 20
	energy = 30
	bomb = 20
	fire = 50
	acid = 50

/obj/item/clothing/under/rank/civilian/hop_bunnysuit
	name = "head of personnel's bunny suit"
	desc = "The staple of any bunny themed bureaucrats. It has a spare “pocket” for holding extra pens and paper."
	icon_state = "bunnysuit_hop"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/hop_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/armor/hop_tailcoat
	name = "head of personnel's tailcoat"
	desc = "A strict looking coat usually worn by bunny themed bureaucrats. The pauldrons are sure to make people finally take you seriously."
	icon_state = "hop"
	inhand_icon_state = "armor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	dog_fashion = null

/obj/item/clothing/neck/tie/bunnytie/hop
	name = "head of personnel's bowtie"
	desc = "A dull red tie that includes a collar. Looking bogged down."
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_hop_tied"
	tie_type = "bowtie_collar_hop"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/hop/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/hop
	greyscale_colors = "#3e6588"
	flags_1 = null

//Janitor

/obj/item/clothing/head/playbunnyears/janitor
	name = "janitor's bunny ears"
	desc = "A pair of purple bunny ears attached to a headband. Kept meticulously clean."
	icon_state = "janitor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/janitor/bunnysuit
	name = "janitor's bunny suit"
	desc = "The staple of any bunny themed janitors. The stockings are made of cotton to allow for easy laundering."
	icon_state = "bunnysuit_janitor"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/janitor/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/janitor
	name = "janitor's tailcoat"
	desc = "A clean looking coat usually worn by bunny themed janitors. The purple sleeves are a late 24th century style."
	icon_state = "janitor"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/janitor
	name = "janitor's bowtie"
	desc = "A purple tie that includes a collar. Looking tidy!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_janitor_tied"
	tie_type = "bowtie_collar_janitor"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/janitor/tied
	is_tied = TRUE

/obj/item/clothing/shoes/galoshes/heeled
	name = "heeled galoshes"
	desc = "A pair of yellow rubber heels, designed to prevent slipping on wet surfaces. These are even harder to walk in than normal heels."
	icon_state ="galoshes_heeled"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/heeled_shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/heeled_shoes_worn.dmi'
	custom_premium_price = PAYCHECK_CREW * 3

//Bartender

/obj/item/clothing/head/playbunnyears/bartender
	name = "bartender's bunny ears"
	desc = "A pair of classy black and white bunny ears attached to a headband. They smell faintly of alchohol."
	icon_state = "bar"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	custom_price = PAYCHECK_CREW

/obj/item/clothing/under/rank/civilian/bartender_bunnysuit
	name = "bartender's bunnysuit"
	desc = "The staple of any bunny themed bartenders. Looks even more stylish than the standard bunny suit."
	icon_state = "bunnysuit_bar"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE
	custom_price = PAYCHECK_CREW

/obj/item/clothing/under/rank/civilian/bartender_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/neck/tie/bunnytie/bartender
	name = "bartender's bowtie"
	desc = "A black tie that includes a collar. Looking fancy!"
	flags_1 = null
	custom_price = PAYCHECK_CREW

/obj/item/clothing/neck/tie/bunnytie/bartender/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/bartender
	greyscale_colors = "#39393f"
	flags_1 = null

//Cook

/obj/item/clothing/head/playbunnyears/cook
	name = "cook's bunny ears"
	desc = "A pair of white and red bunny ears attached to a headband. Helps keep hair out of the food."
	icon_state = "chef"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/cook_bunnysuit
	name = "cook's bunny suit"
	desc = "The staple of any bunny themed chefs. Shame there aren't any fishnets."
	icon_state = "bunnysuit_chef"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/cook_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/cook
	name = "cook's tailcoat"
	desc = "A professional white coat worn by bunny themed chefs. The red accents pair nicely with the monkey blood that often stains this."
	icon_state = "chef"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null
	allowed = list(
		/obj/item/kitchen,
		/obj/item/knife/kitchen,
		/obj/item/storage/bag/tray,
	)

/obj/item/clothing/neck/tie/bunnytie/cook
	name = "cook's bowtie"
	desc = "A red tie that includes a collar. Looking culinary!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_chef_tied"
	tie_type = "bowtie_collar_chef"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/cook/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/chef
	greyscale_colors = null
	flags_1 = null

//Botanist

/obj/item/clothing/head/playbunnyears/botanist
	name = "botanist's bunny ears"
	desc = "A pair of green and blue bunny ears attached to a headband. Good for keeping the sweat out of your eyes during long days on the farm."
	icon_state = "botany"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/hydroponics/bunnysuit
	name = "botanist's bunny suit"
	desc = "The staple of any bunny themed botanists. The stockings are made of faux-denim to mimic the look of overalls."
	icon_state = "bunnysuit_botany"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/hydroponics/bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/botanist
	name = "botanist's tailcoat"
	desc = "A green leather coat worn by bunny themed botanists. Great for keeping the sun off your back."
	icon_state = "botany"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null
	allowed = list(
		/obj/item/cultivator,
		/obj/item/geneshears,
		/obj/item/graft,
		/obj/item/hatchet,
		/obj/item/plant_analyzer,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/secateurs,
		/obj/item/seeds,
		/obj/item/storage/bag/plants,
	)

/obj/item/clothing/neck/tie/bunnytie/botanist
	name = "botanist's bowtie"
	desc = "A blue tie that includes a collar. Looking green-thumbed!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_collar_botany_tied"
	tie_type = "bowtie_collar_botany"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/botanist/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/botanist
	greyscale_colors = "#50d967"
	flags_1 = null

//Clown

/obj/item/clothing/head/playbunnyears/clown
	name = "clown's bunny ears"
	desc = "A pair of orange and pink bunny ears. They even squeak."
	icon_state = "clown"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/clown_bunnysuit
	name = "clown's bunny suit"
	desc = "The staple of any bunny themed clowns. Now this is just ridiculous."
	icon_state = "bunnysuit_clown"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/clown_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/clown
	name = "clown's tailcoat"
	desc = "An orange polkadot coat worn by bunny themed clowns. Shows everyone who the real ringmaster is."
	icon_state = "clown"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/clown
	name = "clown's bowtie"
	desc = "An outrageously large blue bowtie. Looking funny!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "bowtie_clown_tied"
	tie_type = "bowtie_clown"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null
	tie_timer = 8 SECONDS //It's a BIG bowtie

/obj/item/clothing/neck/tie/clown/tied
	is_tied = TRUE

/obj/item/clothing/shoes/clown_shoes/heeled
	name = "honk heels"
	desc = "A pair of high heeled clown shoes. What kind of maniac would design these?"
	icon_state ="honk_heels"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/heeled_shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/heeled_shoes_worn.dmi'

//Mime

/obj/item/clothing/head/playbunnyears/mime
	name = "mime's bunny ears"
	desc = "Red and black bunny ears attached to a headband. Great for street performers sick of the standard beret."
	icon_state = "mime"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/mime_bunnysuit
	name = "mime's bunny suit"
	desc = "The staple of any bunny themed mimes. Includes black and white stockings in order to comply with mime federation outfit regulations."
	icon_state = "bunnysuit_mime"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/mime_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/mime
	name = "mime's tailcoat"
	desc = "A stripy sleeved black coat worn by bunny themed mimes. The red accents mimic the suspenders seen in more standard mime outfits."
	icon_state = "mime"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/shoes/heels/mime
	greyscale_colors = "#a52f29"
	flags_1 = null

//Chaplain

/obj/item/clothing/head/playbunnyears/chaplain
	name = "chaplain's bunny ears"
	desc = "A pair of black and white bunny ears attached to a headband. Worn in worship of The Great Hare"
	icon_state = "chaplain"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/chaplain_bunnysuit
	name = "chaplain's bunny suit"
	desc = "The staple of any bunny themed chaplains. The wool for the stockings came from a sacrificial lamb, making them extra holy."
	icon_state = "bunnysuit_chaplain"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/chaplain_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/chaplain
	name = "chaplain's tailcoat"
	desc = "A gilded black coat worn by bunny themed chaplains. Traditional vestments of the lagomorphic cult."
	icon_state = "chaplain"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null
	allowed = list(
		/obj/item/storage/book/bible,
		/obj/item/nullrod,
		/obj/item/reagent_containers/cup/glass/bottle/holywater,
		/obj/item/storage/fancy/candle_box,
		/obj/item/flashlight/flare/candle,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman
	)

/obj/item/clothing/shoes/heels/chaplain
	greyscale_colors = "#39393f"
	flags_1 = null

/obj/item/clothing/neck/bunny_pendant
	name = "bunny pendant"
	desc = "A golden pendant depicting a holy rabbit."
	icon_state = "chaplain_pendant"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'

//Curator Red

/obj/item/clothing/head/playbunnyears/curator_red
	name = "curator's red bunny ears"
	desc = "A pair of red and beige bunny ears attached to a headband. Marks you as an expert in all things bunny related."
	icon_state = "curator_red"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/curator_bunnysuit_red
	name = "curator's red bunny suit"
	desc = "The staple of any bunny themed librarians. A professional yet comfortable suit perfect for the aspiring bunny academic."
	icon_state = "bunnysuit_curator_red"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/curator_bunnysuit_red/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/curator_red
	name = "curator's red tailcoat"
	desc = "A red linen coat worn by bunny themed librarians. Keeps the dust off your shoulders during long shifts in the archives."
	icon_state = "curator_red"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/shoes/heels/curator_red
	greyscale_colors = "#a52f29"
	flags_1 = null

//Curator Green

/obj/item/clothing/head/playbunnyears/curator_green
	name = "curator's green bunny ears"
	desc = "A pair of green and black bunny ears attached to a headband. Marks you as an expert in all things bunny related."
	icon_state = "curator_green"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/curator_bunnysuit_green
	name = "curator's green bunny suit"
	desc = "The staple of any bunny themed librarians. A professional yet comfortable suit perfect for the aspiring bunny academic."
	icon_state = "bunnysuit_curator_green"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/curator_bunnysuit_green/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/curator_green
	name = "curator's green tailcoat"
	desc = "A green linen coat worn by bunny themed librarians. Keeps the dust off your shoulders during long shifts in the archives."
	icon_state = "curator_green"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/shoes/heels/curator_green
	greyscale_colors = "#47853a"
	flags_1 = null

//Curator Teal

/obj/item/clothing/head/playbunnyears/curator_teal
	name = "curator's teal bunny ears"
	desc = "A pair of teal bunny ears attached to a headband. Marks you as an expert in all things bunny related."
	icon_state = "curator_teal"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/curator_bunnysuit_teal
	name = "curator's teal bunny suit"
	desc = "The staple of any bunny themed librarians. A professional yet comfortable suit perfect for the aspiring bunny academic."
	icon_state = "bunnysuit_curator_teal"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/curator_bunnysuit_teal/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/curator_teal
	name = "curator's teal tailcoat"
	desc = "A teal linen coat worn by bunny themed librarians. Keeps the dust off your shoulders during long shifts in the archives."
	icon_state = "curator_teal"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/shoes/heels/curator_teal
	greyscale_colors = "#5cbfaa"
	flags_1 = null

//Lawyer Black

/obj/item/clothing/head/playbunnyears/lawyer_black
	name = "lawyer's black bunny ears"
	desc = "A pair of black bunny ears attached to a headband. The perfect headband to wear while negotiating a settlement."
	icon_state = "lawyer_black"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_black
	name = "lawyer's black bunny suit"
	desc = "A black linen coat worn by bunny themed lawyers. May or may not contain souls of the damned in suit pockets."
	icon_state = "bunnysuit_law_black"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_black/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/lawyer_black
	name = "lawyer's black tailcoat"
	desc = "The staple of any bunny themed lawyers. EXTREMELY professional."
	icon_state = "lawyer_black"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_black
	name = "lawyer's black tie collar"
	desc = "A black tie that includes a collar. Looking legal!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "tie_collar_lawyer_black_tied"
	tie_type = "tie_collar_lawyer_black"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_black/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/lawyer_black
	greyscale_colors = "#2f3038"
	flags_1 = null

//Lawyer Blue

/obj/item/clothing/head/playbunnyears/lawyer_blue
	name = "lawyer's blue bunny ears"
	desc = "A pair of blue and white bunny ears attached to a headband. The perfect headband to wear while negotiating a settlement."
	icon_state = "lawyer_blue"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_blue
	name = "lawyer's blue bunny suit"
	desc = "The staple of any bunny themed lawyers. EXTREMELY professional."
	icon_state = "bunnysuit_law_blue"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_blue/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/lawyer_blue
	name = "lawyer's blue tailcoat"
	desc = "A blue linen coat worn by bunny themed lawyers. May or may not contain souls of the damned in suit pockets."
	icon_state = "lawyer_blue"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_blue
	name = "lawyer's blue tie collar"
	desc = "A blue tie that includes a collar. Looking defensive!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "tie_collar_lawyer_blue_tied"
	tie_type = "tie_collar_lawyer_blue"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_blue/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/lawyer_blue
	greyscale_colors = "#1165c5"
	flags_1 = null

//Lawyer Red

/obj/item/clothing/head/playbunnyears/lawyer_red
	name = "lawyer's red bunny ears"
	desc = "A pair of red and white bunny ears attached to a headband. The perfect headband to wear while negotiating a settlement."
	icon_state = "lawyer_red"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_red
	name = "lawyer's red bunny suit"
	desc = "The staple of any bunny themed lawyers. EXTREMELY professional."
	icon_state = "bunnysuit_law_red"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_red/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/lawyer_red
	name = "lawyer's red tailcoat"
	desc = "A red linen coat worn by bunny themed lawyers. May or may not contain souls of the damned in suit pockets."
	icon_state = "lawyer_red"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_red
	name = "lawyer's red tie collar"
	desc = "A red tie that includes a collar. Looking prosecutive!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "tie_collar_lawyer_red_tied"
	tie_type = "tie_collar_lawyer_red"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_red/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/lawyer_red
	greyscale_colors = "#a52f29"
	flags_1 = null

//Lawyer Good

/obj/item/clothing/head/playbunnyears/lawyer_good
	name = "good lawyer's bunny ears"
	desc = "A pair of beige and blue bunny ears attached to a headband. The perfect headband to wear while negotiating a settlement."
	icon_state = "lawyer_good"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_good
	name = "good lawyer's bunny suit"
	desc = "The staple of any bunny themed lawyers. EXTREMELY professional."
	icon_state = "bunnysuit_law_good"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer_bunnysuit_good/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/lawyer_good
	name = "good lawyer's tailcoat"
	desc = "A beige linen coat worn by bunny themed lawyers. May or may not contain souls of the damned in suit pockets."
	icon_state = "lawyer_good"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_good
	name = "good lawyer's tie collar"
	desc = "A black tie that includes a collar. Looking technically legal!"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/neckwear.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/neckwear_worn.dmi'
	icon_state = "tie_collar_lawyer_good_tied"
	tie_type = "tie_collar_lawyer_good"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	flags_1 = null

/obj/item/clothing/neck/tie/bunnytie/lawyer_good/tied
	is_tied = TRUE

/obj/item/clothing/shoes/heels/lawyer_good
	greyscale_colors = "#a69e9a"
	flags_1 = null

//Psychologist

/obj/item/clothing/head/playbunnyears/psychologist
	name = "psychologist's bunny ears"
	desc = "A pair of black bunny ears. And how do they make you feel?"
	icon_state = "psychologist"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunny_ears.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunny_ears_worn.dmi'
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/under/rank/civilian/psychologist_bunnysuit
	name = "psychologist's bunny suit"
	desc = "The staple of any bunny themed psychologists. Perhaps not the best choice for making your patients feel at home."
	icon_state = "bunnysuit_psychologist"
	inhand_icon_state = null
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/bunnysuits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/bunnysuits_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/psychologist_bunnysuit/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/suit/jacket/tailcoat/psychologist
	name = "psychologist's tailcoat"
	desc = "A black linen coat worn by bunny themed psychologists. A casual open coat for making you seem approachable, maybe too casual."
	icon_state = "psychologist"
	icon = 'monkestation/icons/obj/clothing/costumes/bunnysprites/tailcoats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/bunnysprites/tailcoats_worn.dmi'
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade = null
	greyscale_colors = null

/obj/item/clothing/shoes/heels/psychologist
	greyscale_colors = "#46464d"
	flags_1 = null
