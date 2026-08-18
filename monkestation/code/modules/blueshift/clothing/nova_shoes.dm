/obj/item/clothing/shoes/wraps
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	name = "gilded leg wraps"
	desc = "Ankle coverings. These ones have a golden design."
	icon_state = "gildedcuffs"
	body_parts_covered = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_MASK

// Wraps have different icons so parent doesn't fit properly.
#define SHOE_SAMPLE_X 14
#define SHOE_SAMPLE_Y 3

/obj/item/clothing/shoes/wraps/get_general_color(icon/base_icon)
	// just grabs the color of the middle of the left foot
	return base_icon.GetPixel(SHOE_SAMPLE_X, SHOE_SAMPLE_Y) || ..()

#undef SHOE_SAMPLE_X
#undef SHOE_SAMPLE_Y

/obj/item/clothing/shoes/wraps/silver
	name = "silver leg wraps"
	desc = "Ankle coverings. Not made of real silver."
	icon_state = "silvergildedcuffs"

/obj/item/clothing/shoes/wraps/red
	name = "red leg wraps"
	desc = "Ankle coverings. Show off your style with these shiny red ones!"
	icon_state = "redcuffs"

/obj/item/clothing/shoes/wraps/blue
	name = "blue leg wraps"
	desc = "Ankle coverings. Hang ten, brother."
	icon_state = "bluecuffs"

/obj/item/clothing/shoes/cowboyboots
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	name = "cowboy boots"
	desc = "A standard pair of brown cowboy boots."
	icon_state = "cowboyboots"

/obj/item/clothing/shoes/cowboyboots/black
	name = "black cowboy boots"
	desc = "A pair of black cowboy boots, pretty easy to scuff up."
	icon_state = "cowboyboots_black"

/obj/item/clothing/shoes/high_heels
	name = "high heels"
	desc = "A fancy pair of high heels. Won't compensate for your below average height that much."
	icon = 'icons/map_icons/clothing/shoes.dmi'
	SETUP_MAP_ICONS("heels", "/obj/item/clothing/shoes/high_heels")
	greyscale_config = /datum/greyscale_config/heels
	greyscale_config_worn = /datum/greyscale_config/heels/worn
	greyscale_colors = "#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/high_heels/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shoesteps/tap_shoes)
	//AddComponent(/datum/component/squeak, list('monkestation/code/modules/blueshift/sounds/effects/heel1.ogg' = 1, 'monkestation/code/modules/blueshift/sounds/effects/heel2.ogg' = 1), 50)

/obj/item/clothing/shoes/fancy_heels
	name = "fancy heels"
	desc = "A pair of fancy high heels that are much smaller on your feet."
	icon = 'icons/map_icons/clothing/shoes.dmi'
	SETUP_MAP_ICONS("fancyheels", "/obj/item/clothing/shoes/fancy_heels")
	greyscale_config = /datum/greyscale_config/fancyheels
	greyscale_config_worn = /datum/greyscale_config/fancyheels/worn
	greyscale_colors = "#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/fancy_heels/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shoesteps/tap_shoes)
	//AddComponent(/datum/component/squeak, list('monkestation/code/modules/blueshift/sounds/effects/heel1.ogg' = 1, 'monkestation/code/modules/blueshift/sounds/effects/heel2.ogg' = 1), 50)

/obj/item/clothing/shoes/discoshoes
	name = "green snakeskin shoes"
	desc = "They may have lost some of their lustre over the years, but these green crocodile leather shoes fit you perfectly."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "lizardskin_shoes"

/obj/item/clothing/shoes/kimshoes
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	name = "aerostatic boots"
	desc = "A brown pair of boots, prim and proper, ready to set off and get a body out of a tree."
	icon_state = "aerostatic_boots"


/obj/item/clothing/shoes/jungleboots
	name = "jungle boots"
	desc = "Take me to your paradise, I want to see the Jungle. A brown pair of boots."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "jungle"
	inhand_icon_state = "jackboots"
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE

/obj/item/clothing/shoes/jungleboots/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/jackboots/black
	name = "dark jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time. These are fully black."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "blackjack"

/obj/item/clothing/shoes/wraps/cloth
	name = "cloth foot wraps"
	desc = "Boxer tape or bandages wrapped like a mummy, all left up to the choice of the wearer."
	icon = 'icons/map_icons/clothing/shoes.dmi'
	SETUP_MAP_ICONS("clothwrap", "/obj/item/clothing/shoes/wraps/cloth")
	greyscale_config = /datum/greyscale_config/clothwraps
	greyscale_config_worn = /datum/greyscale_config/clothwraps/worn
	greyscale_colors = "#FFFFFF"
	body_parts_covered = FALSE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/wraps/colourable
	name = "colourable foot wraps"
	desc = "Ankle coverings. These ones have a customisable colour design."
	icon = 'icons/map_icons/clothing/shoes.dmi'
	SETUP_MAP_ICONS("legwrap", "/obj/item/clothing/shoes/wraps/colourable")
	greyscale_config = /datum/greyscale_config/legwraps
	greyscale_config_worn = /datum/greyscale_config/legwraps/worn
	greyscale_colors = "#FFFFFF"
	body_parts_covered = FALSE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/sports
	name = "sport shoes"
	desc = "Shoes for the sporty individual. The giants of Charlton play host to the titans of Ipswich - making them both seem normal sized."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "sportshoe"

/obj/item/clothing/shoes/jackboots/knee
	name = "knee boots"
	desc = "Black leather boots that go up to the knee."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "kneeboots"

/obj/item/clothing/shoes/jackboots/timbs
	name = "fashionable boots"
	desc = "Fresh from Luna, deadass good for rappers."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "timbs"

/obj/item/clothing/shoes/clown_shoes/pink
	name = "pink clown shoes"
	desc = "A particularly pink pair of punny shoes."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/feet.dmi'
	icon_state = "pink_clown_shoes"
