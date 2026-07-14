/obj/item/clothing/under/plasmaman/captain
	name = "captain's plasma envirosuit"
	desc = "It's a blue envirosuit with some gold markings denoting the rank of \"Captain\"."
	icon_state = "medal"
	worn_icon_state = "medal_w"
	inhand_icon_state = "medal"
	greyscale_config = /datum/greyscale_config/plasmaman_suit/symbol
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/symbol
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/symbol
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/symbol
	greyscale_colors = "#41579a#41579a#e6a345#e6a345#e6a345#e6a345#924100"
	sleek_greyscale_colors = "#41579a#39393f#e6a345#ffd64d#e6a345"
	inhand_icon_state = null
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	armor_type = /datum/armor/plasmaman_captain

/datum/armor/plasmaman_captain
	bio = 100
	fire = 95
	acid = 95
	wound = 15

/obj/item/clothing/under/plasmaman/head_of_personnel
	name = "head of personnel's plasma envirosuit"
	desc = "It's an envirosuit worn by someone who works in the position of \"Head of Personnel\"."
	greyscale_colors = "#3e6588#3e6588#a52f29#3e6588#3e6588#d4d7df"
	sleek_greyscale_colors = "#3e6588#39393f#a52f29#a52f29#a52f29"

/obj/item/clothing/under/plasmaman/security/head_of_security
	name = "head of security's envirosuit"
	desc = "A plasmaman containment suit decorated for those few with the dedication to achieve the position of Head of Security."
	greyscale_config = /datum/greyscale_config/plasmaman_suit/striped
	greyscale_config_worn = /datum/greyscale_config/plasmaman_suit/worn/striped
	greyscale_config_inhand_left = /datum/greyscale_config/plasmaman_suit/inhand_left/striped
	greyscale_config_inhand_right = /datum/greyscale_config/plasmaman_suit/inhand_right/striped
	greyscale_colors = "#a52f29#a52f29#39393f#39393f#39393f#e6a345#c06822"
	sleek_greyscale_colors = "#a52f29#39393f#ffc400#a52f29#39393f"
	armor_type = /datum/armor/plasmaman_head_of_security
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/armor/plasmaman_head_of_security
	melee = 10
	bio = 100
	fire = 95
	acid = 95
	wound = 10

/obj/item/clothing/under/plasmaman/engineering/chief_engineer
	name = "chief engineer's plasma envirosuit"
	desc = "An air-tight suit designed to be used by plasmamen insane enough to achieve the rank of \"Chief Engineer\"."
	greyscale_colors = "#deb63d#eeeeee#2e992e#2e992e#deb63d#2e992e#8c4722"
	sleek_greyscale_colors = "#deb63d#39393f#2e992e#e6a345#eeeeee"

/obj/item/clothing/under/plasmaman/medical/chief_medical_officer
	name = "chief medical officer's plasma envirosuit"
	desc = "It's an envirosuit worn by those with the experience to be \"Chief Medical Officer\"."
	greyscale_colors = "#eeeeee#eeeeee#5eb8b8#5eb8b8#5eb8b8#5eb8b8#224d49"
	sleek_greyscale_colors = "#5eb8b8#39393f#e6a345#5eb8b8#eeeeee"
	armor_type = /datum/armor/plasmaman_chief_medical_officer

/datum/armor/plasmaman_chief_medical_officer
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/under/plasmaman/research_director
	name = "research director's plasma envirosuit"
	desc = "It's an envirosuit worn by those with the know-how to achieve the position of \"Research Director\"."
	greyscale_colors = "#876c33#bcad6c#b347a1#b347a1#876c33#432913"
	sleek_greyscale_colors = "#876c33#39393f#bcad6c#b347a1#b347a1"
	armor_type = /datum/armor/plasmaman_research_director

/datum/armor/plasmaman_research_director
	bio = 100
	fire = 95
	acid = 95
