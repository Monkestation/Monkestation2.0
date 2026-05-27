/obj/item/clothing/head/polycowboyhat
	name = "Poly Cowboy Hat"
	desc = "A Cowboy hat, made out of a special polychromatic material allowing it to be colored"
	icon_state = "cowboyhat_poly"
	worn_icon_state = "wcowboyhat_poly"
	greyscale_config = /datum/greyscale_config/polycowhat
	greyscale_config_worn = /datum/greyscale_config/polycowhat_worn
	greyscale_colors = "#FFFFFF#AAAAAA"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/morningstar
	name = "Morningstar beret"
	desc = "This hat is definitely worth more than your head is."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "morningstar_hat"

/obj/item/clothing/head/saints
	name = "Saints hat"
	desc = "A hat to go with the best coats in the cosmos."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "saints_hat"

/obj/item/clothing/head/widered
	name = "Wide red hat"
	desc = "It is both wide, and red. Stylish!"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "widehat_red"

/obj/item/clothing/head/ushanka
	alternative_screams = list('monkestation/sound/misc/cheekibreeki.ogg', 'monkestation/sound/misc/cyka1.ogg')

/obj/item/clothing/head/cardborg
	alternative_screams = list('monkestation/sound/voice/screams/silicon/scream_silicon.ogg')

/obj/item/clothing/head/kitty
	alternative_screams = list('monkestation/sound/voice/screams/felinid/scream_cat.ogg')

/obj/item/clothing/head/foilhat
	alternative_screams = list(	'monkestation/sound/misc/jones/jones0.ogg',
								'monkestation/sound/misc/jones/jones1.ogg',
								'monkestation/sound/misc/jones/jones2.ogg',
								'monkestation/sound/misc/jones/jones3.ogg')

/obj/item/clothing/head/nanner_crown
	name = "Banana Crown"
	desc = "Looks like someone stuck bananas on this crown's spikes. It doesn't look half bad..."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "nanner_crown"
	armor_type = /datum/armor/nanner_crown
	resistance_flags = FIRE_PROOF

/datum/armor/nanner_crown
	melee = 15
	energy = 10
	fire = 100
	acid = 50
	wound = 5

/obj/item/clothing/head/nanner_crown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 80)

// Sec cowboy hats

/obj/item/clothing/head/helmet/hat/cowboy
	name = "bulletproof cowboy hat"
	desc = "A bulletproof cowboy hat that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	worn_icon = 'monkestation/icons/mob/head.dmi'
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	icon_state = "cowboy_hat_default"
	// I DUNNO LOL // armor = list("melee" = 15, "bullet" = 60, "laser" = 10, "energy" = 15, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30)
	can_flashlight = TRUE
	dog_fashion = null
	flags_inv = null //why isn't this a hat.

//for if we ever decide to try departmental sec
/obj/item/clothing/head/helmet/hat/cowboy/medical
	name = "bulletproof medical cowboy hat"
	icon_state = "cowboy_hat_medical"

/obj/item/clothing/head/helmet/hat/cowboy/engineering
	name = "bulletproof engineering cowboy hat"
	icon_state = "cowboy_hat_engi"

/obj/item/clothing/head/helmet/hat/cowboy/cargo
	name = "bulletproof cargo cowboy hat"
	icon_state = "cowboy_hat_cargo"

/obj/item/clothing/head/helmet/hat/cowboy/science
	name = "bulletproof science cowboy hat"
	icon_state = "cowboy_hat_science"

/obj/item/clothing/head/maidheadband/syndicate
	name = "tactical maid headband"
	desc = "Tacticute."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "syndieheadband"

/datum/armor/helmet_durathread
	bullet = 15
