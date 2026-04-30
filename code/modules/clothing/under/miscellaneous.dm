/obj/item/clothing/under/misc
	icon = 'icons/obj/clothing/under/misc.dmi'
	worn_icon = 'icons/mob/clothing/under/misc.dmi'

/obj/item/clothing/under/misc/pj
	name = "\improper PJs"
	desc = "A comfy set of sleepwear, for taking naps or being lazy instead of working."
	can_adjust = FALSE
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/misc/pj/red
	icon_state = "red_pyjamas"

/obj/item/clothing/under/misc/pj/blue
	icon_state = "blue_pyjamas"

/obj/item/clothing/under/misc/patriotsuit
	name = "Patriotic Suit"
	desc = "Motorcycle not included."
	icon_state = "ek"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	inhand_icon_state = "b_suit"
	clothing_traits = list(TRAIT_HATED_BY_DOGS)

/obj/item/clothing/under/misc/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/misc/psyche/get_general_color(icon/base_icon)
	return "#3f3f3f"

/obj/item/clothing/under/misc/vice_officer
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	inhand_icon_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/adminsuit
	name = "administrative cybernetic jumpsuit"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	desc = "A cybernetically enhanced jumpsuit used for administrative duties."
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor_type = /datum/armor/misc_adminsuit

	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT

	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/datum/armor/misc_adminsuit
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/item/clothing/under/misc/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	inhand_icon_state = null
	can_adjust = FALSE
	has_sensor = NO_SENSORS

/obj/item/clothing/under/misc/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	inhand_icon_state = "lb_suit"
	can_adjust = FALSE
	custom_price = PAYCHECK_CREW

/obj/item/clothing/under/misc/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	inhand_icon_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "durathread"
	inhand_icon_state = null
	can_adjust = FALSE
	armor_type = /datum/armor/misc_durathread

/datum/armor/misc_durathread
	melee = 10
	laser = 10
	fire = 40
	acid = 10
	bomb = 5
	bio = 10

/obj/item/clothing/under/misc/bouncer
	name = "bouncer uniform"
	desc = "A uniform made from a little bit more resistant fibers, makes you seem like a cool guy."
	icon_state = "bouncer"
	inhand_icon_state = null
	can_adjust = FALSE
	armor_type = /datum/armor/misc_bouncer

/datum/armor/misc_bouncer
	melee = 5
	bio = 10
	fire = 30
	acid = 30

/obj/item/clothing/under/misc/coordinator
	name = "coordinator jumpsuit"
	desc = "A jumpsuit made by party people, from party people, for party people."
	icon = 'icons/obj/clothing/under/captain.dmi'
	worn_icon = 'icons/mob/clothing/under/captain.dmi'
	icon_state = "captain_parade"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/misc/syndicate_souvenir
	name = "syndicate souvenir tee"
	desc = "I got kidnapped by a Syndicate operative and all I got was this lousy t-shirt!"
	icon = 'icons/obj/clothing/under/syndicate_souvenir.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate_souvenir.dmi'
	icon_state = "syndicate_souvenir"
	inhand_icon_state = "syndicate_souvenir"
	random_sensor = FALSE
	sensor_mode = NO_SENSORS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

// EGOdrobe changes start here.

/obj/item/clothing/under/projectmoon
	icon = 'icons/obj/clothing/projectmoon/lcuniform.dmi'
	worn_icon = 'icons/mob/clothing/projectmoon/under.dmi'

/obj/item/clothing/under/projectmoon/control
	name = "control department uniform"
	desc = "A red suit with golden trim, worn by clerks from the Control department."
	icon_state = "control"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/information
	name = "information department uniform"
	desc = "A purple waistcoat and trousers over a dress shirt, worn by clerks from the Information department."
	icon_state = "information"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/safety
	name = "safety department uniform"
	desc = "A seafoam-green suit jacket with black trousers, worn by clerks from the Safety department."
	icon_state = "safety"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/training
	name = "training department uniform"
	desc = "An orange suit jacket with black trousers and an orange bowtie, worn by clerks from the Training department."
	icon_state = "training"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/command
	name = "command department uniform"
	desc = "A yellow suit with a black dress shirt, worn by clerks from the Command department."
	icon_state = "command"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/discipline
	name = "discipline department uniform"
	desc = "A red tracksuit with athletic white lines worn by clerks from the Discipline department."
	icon_state = "disciplinary"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/welfare
	name = "welfare department uniform"
	desc = "An old fashioned gray sailor outfit with a blue necktie, worn by clerks from the Welfare department."
	icon_state = "welfare"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/extraction
	name = "extraction department uniform"
	desc = "A black jumpsuit with a grey vest jacket, embroidered with hexagonal gold patterns. Worn by clerks from the Extraction department."
	icon_state = "extraction"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/records
	name = "record department uniform"
	desc = "A white qipao and black trousers with grey cloud patterns. Buttons up at the chest, and fastened around the waist with a belt of fabric. Worn by clerks from the Records department."
	icon_state = "records"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/architecture
	name = "architecture department uniform"
	desc = "A black-and-white suit. Worn by clerks from the Architecture department."
	icon_state = "architecture"
	can_adjust = FALSE

/obj/item/clothing/under/projectmoon/wcorp
	name = "\improper w corp uniform"
	desc = "A blue and black uniform worn by W Corp's employees."
	icon_state = "wuniform"
	can_adjust = FALSE
