/obj/item/clothing/under/costume
	icon = 'icons/obj/clothing/under/costume.dmi'
	worn_icon = 'icons/mob/clothing/under/costume.dmi'

/obj/item/clothing/under/costume/roman
	name = "\improper Roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	inhand_icon_state = "armor"
	can_adjust = FALSE
	strip_delay = 100
	resistance_flags = NONE

/obj/item/clothing/under/costume/jabroni
	name = "jabroni outfit"
	desc = "The leather club is two sectors down."
	icon_state = "darkholme"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/owl
	name = "owl uniform"
	desc = "A soft brown jumpsuit made of synthetic feathers and strong conviction."
	icon_state = "owl"
	inhand_icon_state = "owl"
	can_adjust = FALSE

/obj/item/clothing/under/costume/griffin
	name = "griffon uniform"
	desc = "A soft brown jumpsuit with a white feather collar made of synthetic feathers and a lust for mayhem."
	icon_state = "griffin"
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl
	name = "blue schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl/red
	name = "red schoolgirl uniform"
	icon_state = "schoolgirlred"
	inhand_icon_state = null

/obj/item/clothing/under/costume/schoolgirl/green
	name = "green schoolgirl uniform"
	icon_state = "schoolgirlgreen"
	inhand_icon_state = null

/obj/item/clothing/under/costume/schoolgirl/orange
	name = "orange schoolgirl uniform"
	icon_state = "schoolgirlorange"
	inhand_icon_state = null

/obj/item/clothing/under/costume/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	inhand_icon_state = "kilt"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt/highlander
	desc = "You're the only one worthy of this kilt."

/obj/item/clothing/under/costume/kilt/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER_TRAIT)

/obj/item/clothing/under/costume/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = NO_FEMALE_UNIFORM
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/gladiator/ash_walker
	desc = "This gladiator uniform appears to be covered in ash and fairly dated."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/costume/maid
	name = "maid costume"
	desc = "Maid in China."
	icon_state = "maid"
	inhand_icon_state = "maid"
	body_parts_covered = CHEST|GROIN
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	can_adjust = FALSE

/obj/item/clothing/under/costume/maid/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/maidcorset/A = new (src)
	attach_accessory(A)

/obj/item/clothing/under/costume/geisha
	name = "geisha suit"
	desc = "Cute space ninja senpai not included."
	icon_state = "geisha"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/costume/yukata
	name = "black yukata"
	desc = "A comfortable black cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata1"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/yukata/green
	name = "green yukata"
	desc = "A comfortable green cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata2"

/obj/item/clothing/under/costume/yukata/white
	name = "white yukata"
	desc = "A comfortable white cotton yukata inspired by traditional designs, perfect for a non-formal setting."
	icon_state = "yukata3"

/obj/item/clothing/under/costume/kimono
	name = "black kimono"
	desc = "A luxurious black silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono1"
	inhand_icon_state = "yukata1"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/costume/kimono/red
	name = "red kimono"
	desc = "A luxurious red silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono2"
	inhand_icon_state = "kimono2"

/obj/item/clothing/under/costume/kimono/purple
	name = "purple kimono"
	desc = "A luxurious purple silk kimono with traditional flair, ideal for elegant festive occasions."
	icon_state = "kimono3"
	inhand_icon_state = "kimono3"

/obj/item/clothing/under/costume/villain
	name = "villain suit"
	desc = "A change of wardrobe is necessary if you ever want to catch a real superhero."
	icon_state = "villain"
	can_adjust = FALSE

/obj/item/clothing/under/costume/sailor
	name = "sailor suit"
	desc = "Skipper's in the wardroom drinkin gin'."
	icon_state = "sailor"
	inhand_icon_state = "b_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer
	desc = "Just looking at this makes you want to sing."
	body_parts_covered = CHEST|GROIN|ARMS
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer/yellow
	name = "yellow performer's outfit"
	icon_state = "ysing"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/under/costume/singer/blue
	name = "blue performer's outfit"
	icon_state = "bsing"
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/mummy
	name = "mummy wrapping"
	desc = "Return the slab or suffer my stale references."
	icon_state = "mummy"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/scarecrow
	name = "scarecrow clothes"
	desc = "Perfect camouflage for hiding in botany."
	icon_state = "scarecrow"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/draculass
	name = "draculass coat"
	desc = "A dress inspired by the ancient \"Victorian\" era."
	icon_state = "draculass"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

/obj/item/clothing/under/costume/drfreeze
	name = "doctor freeze's jumpsuit"
	desc = "A modified scientist jumpsuit to look extra cool."
	icon_state = "drfreeze"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/lobster
	name = "foam lobster suit"
	desc = "Who beheaded the college mascot?"
	icon_state = "lobster"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gondola
	name = "gondola hide suit"
	desc = "Now you're cooking."
	icon_state = "gondola"
	inhand_icon_state = "lb_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/skeleton
	name = "skeleton jumpsuit"
	desc = "A black jumpsuit with a white bone pattern printed on it. Spooky!"
	icon_state = "skeleton"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE
	alternative_screams = list('sound/voice/screams/skeleton/scream_skeleton.ogg')

/obj/item/clothing/under/costume/mech_suit
	name = "mech pilot's suit"
	desc = "A mech pilot's suit. Might make your butt look big."
	icon_state = "red_mech_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

	female_sprite_flags = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //covers hands but gloves can go over it. This is how these things work in my head.
	can_adjust = FALSE

	unique_reskin = list(
						"Red" = "red_mech_suit",
						"White" = "white_mech_suit",
						"Blue" = "blue_mech_suit",
						"Black" = "black_mech_suit",
						)

/obj/item/clothing/under/costume/russian_officer
	name = "\improper Russian officer's uniform"
	desc = "The latest in fashionable russian outfits."
	icon = 'icons/obj/clothing/under/security.dmi'
	icon_state = "hostanclothes"
	inhand_icon_state = null
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	alt_covers_chest = TRUE
	armor_type = /datum/armor/costume_russian_officer
	strip_delay = 50
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE

/datum/armor/costume_russian_officer
	melee = 10
	bio = 10
	fire = 30
	acid = 30

/obj/item/clothing/under/costume/buttondown
	gender = PLURAL
	female_sprite_flags = NO_FEMALE_UNIFORM
	custom_price = PAYCHECK_CREW
	icon = 'icons/obj/clothing/under/shorts_pants_shirts.dmi'
	worn_icon = 'icons/mob/clothing/under/shorts_pants_shirts.dmi'
	species_exception = list(/datum/species/golem)
	can_adjust = FALSE

/obj/item/clothing/under/costume/buttondown/slacks
	name = "buttondown shirt with slacks"
	desc = "A fancy buttondown shirt with slacks."
	icon_state = "buttondown_slacks"
	greyscale_config = /datum/greyscale_config/buttondown_slacks
	greyscale_config_worn = /datum/greyscale_config/buttondown_slacks_worn
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/buttondown/shorts
	name = "buttondown shirt with shorts"
	desc = "A fancy buttondown shirt with shorts."
	icon_state = "buttondown_shorts"
	greyscale_config = /datum/greyscale_config/buttondown_shorts
	greyscale_config_worn = /datum/greyscale_config/buttondown_shorts_worn
	greyscale_colors = "#EEEEEE#EE8E2E#222227#D8D39C"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/jackbros
	name = "jack bros outfit"
	desc = "For when it's time to hee some hos."
	icon_state = "JackFrostUniform"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/deckers
	name = "deckers outfit"
	icon_state = "decker_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/football_suit
	name = "football uniform"
	icon_state = "football_suit"
	can_adjust = FALSE
	greyscale_config = /datum/greyscale_config/football_suit
	greyscale_config_worn = /datum/greyscale_config/football_suit_worn
	greyscale_colors = "#D74722"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/costume/swagoutfit
	name = "Swag outfit"
	desc = "Why don't you go secure some bitches?"
	icon_state = "SwagOutfit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/referee
	name = "referee uniform"
	desc = "A standard black and white striped uniform to signal authority."
	icon_state = "referee"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/joker
	name = "comedian suit"
	desc = "The worst part of having a mental illness is people expect you to behave as if you don't."
	icon_state = "joker"
	can_adjust = FALSE

/obj/item/clothing/under/costume/yuri
	name = "yuri initiate jumpsuit"
	icon_state = "yuri_uniform"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/dutch
	name = "dutch's suit"
	desc = "You can feel a <b>god damn plan</b> coming on."
	icon_state = "DutchUniform"
	inhand_icon_state = null
	can_adjust = FALSE

// For the nuke-ops cowboy fit.
/obj/item/clothing/under/costume/dutch/syndicate
	desc = "You can feel a <b>god damn plan</b> coming on, and the armor lining in this suit'll do wonders in makin' it work."
	armor_type = /datum/armor/clothing_under/syndicate

/obj/item/clothing/under/costume/osi
	name = "O.S.I. jumpsuit"
	icon_state = "osi_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/tmc
	name = "Lost MC clothing"
	icon_state = "tmc_jumpsuit"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/gi
	name = "Martial Artist Gi"
	desc = "Assistant, nukie, whatever. You can beat anyone; it's called hard work!"
	icon_state = "martial_arts_gi"
	inhand_icon_state = null
	female_sprite_flags = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/susie
	name = "Rude Jacket"
	desc = "A replica of the black and purple jacket a legendary lizard wore while saving the world."
	icon_state = "susie"
	inhand_icon_state = null
	can_adjust = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/kris
	name = "Vessel's Armor"
	desc = "* It appears to be the replica of the armor a legendary vessel wore while saving the world."
	icon_state = "kris_armor"
	inhand_icon_state = null
	can_adjust = FALSE

/obj/item/clothing/under/costume/dio
	name = "flamboyant turtleneck"
	desc = "Looking at this REALLY makes you want to reject your humanity."
	icon_state = "dio_turtleneck"
	can_adjust = FALSE

/obj/item/clothing/under/costume/jimbo
	name = "joker's suit"
	desc = "A costume fit for an ace of spades, club, diamonds and hearts. It's a suit of suits."
	icon_state = "jimbo"
	can_adjust = FALSE

/obj/item/clothing/under/costume/villain
	alternative_screams = list(
		'sound/misc/robbie/robbie1.ogg',
		'sound/misc/robbie/robbie2.ogg',
		'sound/misc/robbie/robbie3.ogg',
		'sound/misc/robbie/robbie4.ogg',
		'sound/misc/robbie/robbie5.ogg',
		'sound/misc/robbie/robbie6.ogg',
		'sound/misc/robbie/robbie7.ogg',
		'sound/misc/robbie/robbie8.ogg',
		'sound/misc/robbie/robbie9.ogg',
		'sound/misc/robbie/robbie10.ogg',
		'sound/misc/robbie/robbie11.ogg',
		'sound/misc/robbie/robbie12.ogg',
		'sound/misc/robbie/robbie13.ogg',
		'sound/misc/robbie/robbie14.ogg',
		'sound/misc/robbie/robbie15.ogg',
	)

/obj/item/clothing/under/costume/skyrat
	can_adjust = FALSE

//My least favorite file. Just... try to keep it sorted. And nothing over the top (The victorian dresses were way too much)

/*
*	UNSORTED
*/
/obj/item/clothing/under/costume/skyrat/cavalry
	name = "cavalry uniform"
	desc = "Dedicate yourself to something better. To loyalty, honour, for it only dies when everyone abandons it."
	icon_state = "cavalry" //specifically an 1890s US Army Cavalry Uniform

/obj/item/clothing/under/costume/deckers/alt //not even going to bother re-pathing this one because its such a unique case of 'TGs item has something but this alt doesnt'
	name = "deckers maskless outfit"
	desc = "A decker jumpsuit with neon blue coloring."
	icon_state = "decking_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/worldchampiongi
	name = "World Champion Gi"
	desc = "Only the strongest wears this Gi, everyone else are just using tricks."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "worldchampion_gi"
	can_adjust = FALSE

/obj/item/clothing/under/costume/streetmime
	name = "street mime suit"
	desc = "Although unorthodoxly colorful, it is practical for standing out in space France."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "streetmime"
	can_adjust = FALSE

/obj/item/clothing/under/costume/milkman
	name = "milkman suit"
	desc = "I am the Milkman. My milk is delicious!"
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "milkman"
	can_adjust = FALSE

/obj/item/clothing/under/costume/batter
	name = "batter uniform"
	desc = "Purification in Progress."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "batter"
	can_adjust = FALSE

/obj/item/clothing/under/costume/tragic
	name = "tragic mime suit"
	desc = "A skin-tight black suit for theatre actors. You feel the need to remind a doctor to eat food and sleep."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "tragic"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	alternate_worn_layer = GLOVES_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/harlequin
	name = "harlequin jumpsuit"
	desc = "This is what you wear if you wanna be a weird fusion of a clown and mime."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "harlequin"
	can_adjust = FALSE

/obj/item/clothing/under/costume/bee
	name = "bee hide costume"
	desc = "A suit made of beehide"
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "bee"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	can_adjust = FALSE

/obj/item/clothing/under/costume/cop_mascot
	name = "policeman mascot suit"
	desc = "A blue police mascot suit. On the chest is a star badge with an eye in the middle. You feel like you should be chopping people apart with power tools while wearing this."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "cop_mascot"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	alternate_worn_layer = GLOVES_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/crueltysquad_under
	name = "CSIJ level I body armor"
	desc = "Armor used by assassins working for Cruelty Squad, stripped of all of its functions for kids to play with."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "crueltysquad_under"
	can_adjust = FALSE

/obj/item/clothing/under/costume/infinity_under
	name = "infinity shorts"
	desc = "Worn by those who want more matching team colors."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "infinity_shorts"
	body_parts_covered = CHEST|GROIN|LEGS
	can_adjust = FALSE

/obj/item/clothing/under/costume/bb_dress
	name = "bb dress"
	desc = "Howdy, it's me BB. Zines, zines, zines."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "bb_dress"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/costume/citizen_uniform
	name = "citizen uniform"
	desc = "A blue matching uniform. It makes you feel like you're in a labor camp."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "citizen_uniform"
	can_adjust = FALSE
/*
*	LUNAR AND JAPANESE CLOTHES
*/

/obj/item/clothing/under/costume/skyrat/kamishimo
	name = "kamishimo"
	desc = "A traditional ancient Earth Japanese Kamishimo."
	icon_state = "kamishimo"

/obj/item/clothing/under/costume/skyrat/kimono
	name = "fancy kimono"
	desc = "A traditional ancient Earth Japanese Kimono. Longer and fancier than a yukata."
	icon_state = "kimono"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alternate_worn_layer = ABOVE_SHOES_LAYER
/*
*	CHRISTMAS CLOTHES
*/

/obj/item/clothing/under/costume/skyrat/christmas
	name = "christmas costume"
	desc = "Can you believe it guys? Christmas. Just a lightyear away!" //Lightyear is a measure of distance I hate it being used for this joke :(
	icon_state = "christmas"

/obj/item/clothing/under/costume/skyrat/christmas/green
	name = "green christmas costume"
	desc = "4:00, wallow in self-pity. 4:30, stare into the abyss. 5:00, solve world hunger, tell no one. 5:30, jazzercize; 6:30, dinner with me. I can't cancel that again. 7:00, wrestle with my self-loathing. I'm booked. Of course, if I bump the loathing to 9, I could still be done in time to lay in bed, stare at the ceiling and slip slowly into madness."
	icon_state = "christmas_green"

/*
BUNNY SUITS
*/
/obj/item/clothing/under/costume/playbunny
	name = "bunny suit"
	desc = "The staple of any bunny themed waiters and the like. It has a little cottonball tail too."
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "playbunny"
	greyscale_colors = "#39393f#39393f#ffffff#87502e"
	greyscale_config = /datum/greyscale_config/bunnysuit
	greyscale_config_worn = /datum/greyscale_config/bunnysuit_worn
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/costume/playbunny/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny)

/obj/item/clothing/under/syndicate/syndibunny //heh
	name = "blood-red bunny suit"
	desc = "The staple of any bunny themed syndicate assassins. Are those carbon nanotube stockings?"
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = 'icons/mob/clothing/uniform.dmi'
	icon_state = "syndibunny"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/under/syndicate/syndibunny/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/small)

/obj/item/clothing/under/costume/playbunny/magician
	name = "magician's bunny suit"
	desc = "The staple of any bunny themed stage magician."
	icon_state = "playbunny_wiz"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/under/costume/playbunny/magician/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/tiny/magician)

/datum/storage/pockets/tiny/magician/New() //this is probably a good idea
	. = ..()
	var/static/list/exception_cache = typecacheof(list(
		/obj/item/gun/magic/wand,
		/obj/item/warp_whistle,
	))
	exception_hold = exception_cache

/obj/item/clothing/under/costume/playbunny/centcom
	name = "centcom bunnysuit"
	desc = "A modified Centcom version of a bunny outfit, using Lunarian technology to condense countless amounts of rabbits into a material that is extremely comfortable and light to wear."
	icon_state = "playbunny_centcom"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/suit/jacket/tailcoat/centcom/ntrep
	name = "Centcom tailcoat"
	desc = "An official coat usually worn by bunny themed executives. The inside is lined with comfortable yet tasteful bunny fluff. Now for Representatives"
	icon_state = "tailcoat_centcom"
	armor_type = /datum/armor/nanotrasen_representative_bathrobe
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/under/costume/playbunny/british
	name = "british bunny suit"
	desc = "The staple of any bunny themed monarchists. It has a little cottonball tail too."
	icon_state = "playbunny_brit"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/under/costume/playbunny/communist
	name = "really red bunny suit"
	desc = "The staple of any bunny themed communists. It has a little cottonball tail too."
	icon_state = "playbunny_communist"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/under/costume/playbunny/usa
	name = "striped bunny suit"
	desc = "A bunny outfit stitched together from several American flags. It has a little cottonball tail too."
	icon_state = "playbunny_usa"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null
/*
END OF BUNNY SUITS
*/
