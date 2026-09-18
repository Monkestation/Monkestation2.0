/obj/item/clothing/under/costume/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/costume.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/costume.dmi'
	can_adjust = FALSE

//My least favorite file. Just... try to keep it sorted. And nothing over the top

/*
*	UNSORTED
*/
/obj/item/clothing/under/costume/nova/cavalry
	name = "cavalry uniform"
	desc = "Dedicate yourself to something better. To loyalty, honour, for it only dies when everyone abandons it."
	icon_state = "cavalry" //specifically an 1890s US Army Cavalry Uniform

/obj/item/clothing/under/costume/deckers/alt //not even going to bother re-pathing this one because its such a unique case of 'TGs item has something but this alt doesnt'
	name = "deckers maskless outfit"
	desc = "A decker jumpsuit with neon blue coloring."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/costume.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/costume.dmi'
	icon_state = "decking_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/nova/bathrobe
	name = "bathrobe"
	desc = "A warm fluffy bathrobe, perfect for relaxing after finally getting clean."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	SETUP_MAP_ICONS("robes", "/obj/item/clothing/under/costume/nova/bathrobe")
	greyscale_config = /datum/greyscale_config/bathrobe
	greyscale_config_worn = /datum/greyscale_config/bathrobe/worn
	greyscale_colors = "#434d7a" //THATS RIGHT, FUCK YOU! THE BATHROBE CAN BE RECOLORED!
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	flags_1 = IS_PLAYER_COLORABLE_1

/*
*	LUNAR AND JAPANESE CLOTHES
*/

/obj/item/clothing/under/costume/nova/qipao
	name = "qipao"
	desc = "A qipao, traditionally worn in ancient Earth China by women during social events and lunar new years."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	SETUP_MAP_ICONS("qipao", "/obj/item/clothing/under/costume/nova/qipao")
	greyscale_config = /datum/greyscale_config/qipao
	greyscale_config_worn = /datum/greyscale_config/qipao/worn
	greyscale_colors = "#2b2b2b"
	body_parts_covered = CHEST|GROIN|LEGS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/nova/qipao/customtrim
	SETUP_MAP_ICONS("qipao", "/obj/item/clothing/under/costume/nova/qipao/customtrim")
	greyscale_config = /datum/greyscale_config/qipao_customtrim
	greyscale_config_worn = /datum/greyscale_config/qipao_customtrim/worn
	greyscale_colors = "#2b2b2b#ffce5b"

/obj/item/clothing/under/costume/nova/cheongsam
	name = "cheongsam"
	desc = "A cheongsam, traditionally worn in ancient Earth China by men during social events and lunar new years."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	SETUP_MAP_ICONS("cheongsam", "/obj/item/clothing/under/costume/nova/cheongsam")
	greyscale_config = /datum/greyscale_config/cheongsam
	greyscale_config_worn = /datum/greyscale_config/cheongsam/worn
	greyscale_colors = "#2b2b2b#353535"
	body_parts_covered = CHEST|GROIN|LEGS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/nova/cheongsam/customtrim
	SETUP_MAP_ICONS("cheongsam", "/obj/item/clothing/under/costume/nova/cheongsam/customtrim")
	greyscale_config = /datum/greyscale_config/cheongsam_customtrim
	greyscale_config_worn = /datum/greyscale_config/cheongsam_customtrim/worn
	greyscale_colors = "#2b2b2b#ffce5b#353535"

/obj/item/clothing/under/costume/nova/yukata
	name = "yukata"
	desc = "A traditional ancient Earth Japanese yukata, typically worn in casual settings."
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	SETUP_MAP_ICONS("yukata", "/obj/item/clothing/under/costume/nova/yukata")
	greyscale_config = /datum/greyscale_config/yukata
	greyscale_config_worn = /datum/greyscale_config/yukata/worn
	greyscale_colors = "#2b2b2b#666666"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/nova/kamishimo
	name = "kamishimo"
	desc = "A traditional ancient Earth Japanese Kamishimo."
	icon_state = "kamishimo"

/*
*	CHRISTMAS CLOTHES
*/

/obj/item/clothing/under/costume/nova/christmas
	name = "christmas costume"
	desc = "Can you believe it guys? Christmas. Just a lightyear away!" //Lightyear is a measure of distance I hate it being used for this joke :(
	icon = 'icons/map_icons/clothing/under/costume.dmi'
	SETUP_MAP_ICONS("christmas_male", "/obj/item/clothing/under/costume/nova/christmas")
	greyscale_config = /datum/greyscale_config/chrimbo
	greyscale_config_worn = /datum/greyscale_config/chrimbo/worn
	greyscale_colors = "#cc0f0f#c4c2c2"
	body_parts_covered = CHEST|GROIN|ARMS
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/nova/christmas/green
	name = "green christmas costume"
	desc = "4:00, wallow in self-pity. 4:30, stare into the abyss. 5:00, solve world hunger, tell no one. 5:30, jazzercize; 6:30, dinner with me. \
		I can't cancel that again. 7:00, wrestle with my self-loathing. I'm booked. Of course, if I bump the loathing to 9, \
		I could still be done in time to lay in bed, stare at the ceiling and slip slowly into madness."
	SETUP_MAP_ICONS("christmas_male", "/obj/item/clothing/under/costume/nova/christmas/green")
	greyscale_colors = "#1a991a#c4c2c2"
/*
*	TREK CLOTHES
*/
/obj/item/clothing/under/trek/command
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/trek/engsec
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/trek/medsci
	flags_1 = IS_PLAYER_COLORABLE_1

//Cyberpunk PI Costume - Sprites from Eris, slightly modified
/obj/item/clothing/under/costume/cybersleek
	name = "sleek modern coat"
	desc = "A modern-styled coat typically worn on more urban planets, made with a neo-laminated fiber lining."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/uniform.dmi'
	icon_state = "cyberpunksleek"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS
	can_adjust = FALSE

/obj/item/clothing/under/costume/cybersleek/long
	name = "long modern coat"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	icon_state = "cyberpunksleek_long"

