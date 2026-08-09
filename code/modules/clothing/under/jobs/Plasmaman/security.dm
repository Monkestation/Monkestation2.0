/obj/item/clothing/under/plasmaman/security
	name = "security plasma envirosuit"
	desc = "A plasmaman containment suit designed for security officers, offering a limited amount of extra protection."
	greyscale_colors = "#a52f29#a52f29#39393f#a52f29#39393f#18191e"
	sleek_greyscale_colors = "#39393f#39393f#a52f29#39393f#a52f29"
	armor_type = /datum/armor/plasmaman_security
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/armor/plasmaman_security
	melee = 10
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/under/plasmaman/security/warden
	name = "warden plasma envirosuit"
	desc = "A plasmaman containment suit designed for the warden, white stripes being added to differentiate them from other members of security."
	greyscale_config = /datum/greyscale_config/plasmaman_suit/striped
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/striped
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/striped
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/striped
	greyscale_colors = "#a52f29#a52f29#39393f#a52f29#39393f#eeeeee#18191e"
	sleek_greyscale_colors = "#a52f29#39393f#eeeeee#39393f#39393f"

/obj/item/clothing/under/plasmaman/secmed
	name = "security medical envirosuit"
	desc = "A new pattern plasmaman suit for those qualified as security medical personnel."
	icon_state = "cross"
	worn_icon_state = "cross_w"
	inhand_icon_state = "cross"
	greyscale_config = /datum/greyscale_config/plasmaman_suit/symbol
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/symbol
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/symbol
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/symbol
	greyscale_colors = "#918F8c#918F8c#a52f29#918F8c#a52f29#a52f29#3f1329"
	sleek_greyscale_colors = "#918F8c#39393f#a52f29#39393f#a52f29"
