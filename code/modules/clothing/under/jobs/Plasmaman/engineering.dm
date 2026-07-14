/obj/item/clothing/under/plasmaman/engineering
	name = "engineering plasma envirosuit"
	desc = "An air-tight suit designed to be used by plasmamen employed as engineers, the usual purple stripes being replaced by engineering's orange. It protects the user from fire and acid damage."
	icon_state = "plasmaman_suit_engi"
	worn_icon_state = "plasmaman_suit_engi_worn"
	inhand_icon_state = "plasmaman_suit_engi"
	greyscale_config = /datum/greyscale_config/plasmaman_suit/symbol
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/symbol
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/symbol
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/symbol
	greyscale_colors = "#deb63d#deb63d#d15b1b#d15b1b#deb63d#d15b1b#8c4722" //f6e400
	sleek_greyscale_colors = "#d15b1b#39393f#deb63d#39393f#deb63d"
	armor_type = /datum/armor/plasmaman_engineering

/obj/item/clothing/under/plasmaman/engineering/atmospherics
	name = "atmospherics plasma envirosuit"
	desc = "An air-tight suit designed to be used by plasmamen employed as atmos technicians, the usual purple stripes being replaced by atmos' blue."
	greyscale_colors = "#deb63d#deb63d#47bfff#47bfff#deb63d#47bfff#8c4722"
	sleek_greyscale_colors = "#deb63d#39393f#47bfff#39393f#47bfff"

/obj/item/clothing/under/plasmaman/engineering/signal_tech
	name = "signal technician plasma envirosuit"
	desc = "An air-tight suit designed to be used by plasmamen employed as signal technicians, \
		the usual purple stripes being replaced by a unique bright green. It protects the user from fire and acid damage."
	greyscale_colors = "#deb63d#deb63d#00ff33#00ff33#deb63d#00ff33#8c4722"
	sleek_greyscale_colors = "#deb63d#39393f#00ff33#39393f#00ff33"

/datum/armor/plasmaman_engineering
	bio = 100
	fire = 95
	acid = 95
