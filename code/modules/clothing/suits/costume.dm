/obj/item/clothing/suit/costume
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'

/obj/item/clothing/suit/hooded/flashsuit
	name = "flashy costume"
	desc = "What did you expect?"
	icon_state = "flashsuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "armor"
	body_parts_covered = CHEST|GROIN
	hoodtype = /obj/item/clothing/head/hooded/flashsuit

/obj/item/clothing/head/hooded/flashsuit
	name = "flash button"
	desc = "You will learn to fear the flash."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "flashsuit"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACIALHAIR|HIDEFACE|HIDEMASK|HIDESNOUT

/obj/item/clothing/suit/costume/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(/obj/item/melee/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/cup/glass/bottle/rum, /obj/item/gun/energy/laser/musket, /obj/item/gun/energy/disabler/smoothbore)
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/costume/pirate/armored
	armor_type = /datum/armor/pirate_armored
	strip_delay = 40
	equip_delay_other = 20
	species_exception = null

/obj/item/clothing/suit/costume/pirate/captain
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/pirate/armored
	armor_type = /datum/armor/pirate_armored
	strip_delay = 40
	equip_delay_other = 20
	species_exception = null

/obj/item/clothing/suit/costume/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	flags_1 = CONDUCT_1
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/costume/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous" //Needs no fixing
	icon_state = "justice"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor_type = /datum/armor/costume_justice

/obj/item/clothing/suit/costume/justice/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_vest_allowed

/datum/armor/costume_justice
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 50
	acid = 50

/obj/item/clothing/suit/costume/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	inhand_icon_state = "judge"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes, /obj/item/stack/spacecash)

/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	inhand_icon_state = "overalls"
	body_parts_covered = CHEST|GROIN|LEGS
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/apron/purple_bartender
	name = "purple bartender apron"
	desc = "A fancy purple apron for a stylish person."
	icon_state = "purplebartenderapron"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/syndicatefake
	name = "red space suit replica" //monkestation edit
	icon_state = "syndicate" //monkestation edit
	icon = 'icons/obj/clothing/suits/spacesuit.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	inhand_icon_state = "space_suit_syndicate" //monkestation edit
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	desc = "A plastic replica of the Syndicate space suit. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = NONE

/obj/item/clothing/suit/costume/hastur
	name = "\improper Hastur's robe"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/costume/imperium_monk
	name = "\improper Imperium monk suit"
	desc = "Have YOU killed a xeno today?"
	icon_state = "imperium_monk"
	inhand_icon_state = "imperium_monk"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/cup/glass/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/flashlight/flare/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/costume/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	inhand_icon_state = "chickensuit"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/costume/monkeysuit
	name = "monkey suit"
	desc = "A suit that looks like a primate."
	icon_state = "monkeysuit"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	icon_state = "owl_wings"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	toggle_noun = "wings"
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/suit/toggle/owlwings/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/toggle/owlwings/griffinwings
	name = "griffon cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."
	icon_state = "griffin_wings"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	inhand_icon_state = "cardborg"
	body_parts_covered = CHEST|GROIN|LEGS
	flags_inv = HIDEJUMPSUIT
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/costume/cardborg/equipped(mob/living/user, slot)
	..()
	if(slot & ITEM_SLOT_OCLOTHING)
		disguise(user)

/obj/item/clothing/suit/costume/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/suit/costume/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/costume/cardborg/borghead)
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/costume/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY
			var/image/I = image(icon = 'icons/mob/silicon/robots.dmi' , icon_state = "robot", loc = H)
			I.override = 1
			I.add_overlay(mutable_appearance('icons/mob/silicon/robots.dmi', "robot_e")) //gotta look realistic
			add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "standard_borg_disguise", I) //you look like a robot to robots! (including yourself because you're totally a robot)

/obj/item/clothing/suit/costume/snowman
	name = "snowman outfit"
	desc = "Two white spheres covered in white glitter. 'Tis the season."
	icon_state = "snowman"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/costume/poncho
	name = "poncho"
	desc = "Your classic, non-racist poncho."
	icon_state = "classicponcho"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/costume/poncho/green
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is green."
	icon_state = "greenponcho"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/poncho/red
	name = "red poncho"
	desc = "Your classic, non-racist poncho. This one is red."
	icon_state = "redponcho"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/poncho/ponchoshame
	name = "poncho of shame"
	desc = "Forced to live on your shameful acting as a fake Mexican, you and your poncho have grown inseparable. Literally."
	icon_state = "ponchoshame"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/poncho/ponchoshame/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/suit/costume/whitedress
	name = "white dress"
	desc = "A fancy white dress."
	icon_state = "white_dress"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	flags_inv = HIDEJUMPSUIT|HIDESHOES

/obj/item/clothing/suit/hooded/carp_costume
	name = "carp costume"
	desc = "A costume made from 'synthetic' carp scales, it smells."
	icon_state = "carp_casual"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT //Space carp like space, so you should too
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/gun/ballistic/rifle/boltaction/harpoon)
	hoodtype = /obj/item/clothing/head/hooded/carp_hood

/obj/item/clothing/head/hooded/carp_hood
	name = "carp hood"
	desc = "A hood attached to a carp costume."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "carp_casual"
	body_parts_covered = HEAD

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/head/hooded/carp_hood/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot & ITEM_SLOT_HEAD)
		user.faction |= "carp"

/obj/item/clothing/head/hooded/carp_hood/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "carp"

/obj/item/clothing/suit/hooded/carp_costume/spaceproof
	name = "carp space suit"
	desc = "A slimming piece of dubious space carp technology, you suspect it won't stand up to hand-to-hand blows."
	icon_state = "carp_suit"
	inhand_icon_state = "space_suit_syndicate"
	armor_type = /datum/armor/carp_costume_spaceproof
	allowed = list(/obj/item/tank/internals, /obj/item/gun/ballistic/rifle/boltaction/harpoon) //I'm giving you a hint here
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT

	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	hoodtype = /obj/item/clothing/head/hooded/carp_hood/spaceproof
	resistance_flags = NONE

/datum/armor/carp_costume_spaceproof
	melee = -20
	bio = 100
	fire = 60
	acid = 75

/obj/item/clothing/head/hooded/carp_hood/spaceproof
	name = "carp helmet"
	desc = "Spaceworthy and it looks like a space carp's head, smells like one too."
	icon_state = "carp_helm"
	armor_type = /datum/armor/carp_hood_spaceproof
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR //facial hair will clip with the helm, this'll need a dynamic_fhair_suffix at some point.
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT

	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL|SNUG_FIT|PLASMAMAN_HELMET_EXEMPT
	body_parts_covered = HEAD
	resistance_flags = NONE
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH|PEPPERPROOF

/datum/armor/carp_hood_spaceproof
	melee = -20
	bio = 100
	fire = 60
	acid = 75

/obj/item/clothing/head/hooded/carp_hood/spaceproof/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/hooded/carp_costume/spaceproof/old
	name = "battered carp space suit"
	desc = "It's covered in bite marks and scratches, yet seems to be still perfectly functional."
	slowdown = 1

/obj/item/clothing/suit/hooded/ian_costume //It's Ian, rub his bell- oh god what happened to his inside parts?
	name = "corgi costume"
	desc = "A costume that looks like someone made a human-like corgi, it won't guarantee belly rubs."
	icon_state = "ian"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	//
	//min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()
	hoodtype = /obj/item/clothing/head/hooded/ian_hood
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/head/hooded/ian_hood
	name = "corgi hood"
	desc = "A hood that looks just like a corgi's head, it won't guarantee dog biscuits."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "ian"
	body_parts_covered = HEAD
	//
	//min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/bee_costume // It's Hip!
	name = "bee costume"
	desc = "Bee the true Queen!"
	icon_state = "bee"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	clothing_flags = THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/bee_hood

/obj/item/clothing/head/hooded/bee_hood
	name = "bee hood"
	desc = "A hood attached to a bee costume."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "bee"
	body_parts_covered = HEAD
	clothing_flags = THICKMATERIAL
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/bloated_human //OH MY GOD WHAT HAVE YOU DONE!?!?!?
	name = "bloated human suit"
	desc = "A horribly bloated suit made from human skins."
	icon_state = "lingspacesuit"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	allowed = list()
	actions_types = list(/datum/action/item_action/toggle_human_head)
	hoodtype = /obj/item/clothing/head/hooded/human_head
	species_exception = list(/datum/species/golem) //Finally, flesh

/obj/item/clothing/head/hooded/human_head
	name = "bloated human head"
	desc = "A horribly bloated and mismatched human head."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "lingspacehelmet"
	body_parts_covered = HEAD
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/costume/shrine_maiden
	name = "shrine maiden's outfit"
	desc = "Makes you want to exterminate some troublesome youkai."
	icon_state = "shrine_maiden"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/costume/striped_sweater
	name = "striped sweater"
	desc = "Reminds you of someone, but you just can't put your finger on it..."
	icon_state = "waldo_shirt"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/dracula
	name = "dracula coat"
	desc = "Looks like this belongs in a very old movie set."
	icon_state = "draculacoat"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/drfreeze_coat
	name = "doctor freeze's labcoat"
	desc = "A labcoat imbued with the power of features and freezes."
	icon_state = "drfreeze_coat"
	inhand_icon_state = null

/obj/item/clothing/suit/costume/gothcoat
	name = "gothic coat"
	desc = "Perfect for those who want to stalk around a corner of a bar."
	icon_state = "gothcoat"
	body_parts_covered = ARMS|HANDS|CHEST|GROIN //the model has a glove on it so protect the hands.
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_OCLOTHING|ITEM_SLOT_NECK
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/costume/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	inhand_icon_state = "xenos_suit"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/clothing/mask/facehugger/toy)

/obj/item/clothing/suit/costume/nemes
	name = "pharoah tunic"
	desc = "Lavish space tomb not included."
	icon_state = "pharoah"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/costume/changshan_red
	name = "red changshan"
	desc = "A gorgeously embroidered silk shirt."
	icon_state = "changshan_red"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/suit/costume/changshan_blue
	name = "blue changshan"
	desc = "A gorgeously embroidered silk shirt."
	icon_state = "changshan_blue"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/suit/costume/cheongsam_red
	name = "red cheongsam"
	desc = "A gorgeously embroidered silk dress."
	icon_state = "cheongsam_red"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/suit/costume/cheongsam_blue
	name = "blue cheongsam"
	desc = "A gorgeously embroidered silk dress."
	icon_state = "cheongsam_blue"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/suit/costume/bronze
	name = "bronze suit"
	desc = "A big and clanky suit made of bronze that offers no protection and looks very unfashionable. Nice."
	icon_state = "clockwork_cuirass_old"
	armor_type = /datum/armor/costume_bronze

/obj/item/clothing/suit/hooded/mysticrobe
	name = "mystic's robe"
	desc = "Wearing this makes you feel more attuned with the nature of the universe... as well as a bit more irresponsible. "
	icon_state = "mysticrobe"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = "mysticrobe"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/spellbook, /obj/item/book/bible)
	flags_inv = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/mysticrobe

/obj/item/clothing/head/hooded/mysticrobe
	name = "mystic's hood"
	desc = "The balance of reality tips towards order."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "mystichood"
	inhand_icon_state = null
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACIALHAIR|HIDEFACE|HIDEMASK

/obj/item/clothing/suit/coordinator
	name = "coordinator jacket"
	desc = "A jacket for a party ooordinator, stylish!."
	icon_state = "capformal"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	inhand_icon_state = null
	armor_type = /datum/armor/suit_coordinator

/datum/armor/suit_coordinator
	melee = 25
	bullet = 15
	laser = 25
	energy = 35
	bomb = 25
	fire = 50
	acid = 50

/obj/item/clothing/suit/costume/hawaiian
	name = "hawaiian overshirt"
	desc = "A cool shirt for chilling on the beach."
	icon_state = "hawaiian_blue"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/costume/football_armor
	name = "football protective gear"
	desc = "Given to members of the football team!"
	icon_state = "football_armor"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	greyscale_config = /datum/greyscale_config/football_armor
	greyscale_config_worn = /datum/greyscale_config/football_armor_worn
	greyscale_colors = "#D74722"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/costume/joker
	name = "comedian coat"
	desc = "I mean, don’t you have to be funny to be a comedian?"
	icon_state = "joker_coat"

/obj/item/clothing/suit/costume/deckers
	name = "decker hoodie"
	desc = "Based? Based on what?"
	icon_state = "decker_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/soviet
	name = "soviet armored coat"
	desc = "Conscript reporting! Sponsored by DonkSoft Co. for historical reenactment of the Third World War!"
	icon_state = "soviet_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/suit/costume/soviet/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_vest_allowed


/obj/item/clothing/suit/costume/yuri
	name = "yuri initiate coat"
	desc = "Yuri is master! Sponsored by DonkSoft Co. for historical reenactment of the Third World War!"
	icon_state = "yuri_coat"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/suit/costume/yuri/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_vest_allowed

/obj/item/clothing/suit/costume/tmc
	name = "\improper Lost M.C. cut"
	desc = "Making sure everyone knows you're in the best biker gang this side of Alderney."
	icon_state = "tmc_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/pg
	name = "powder ganger jacket"
	desc = "Remind Security of their mistakes in giving prisoners blasting charges."
	icon_state = "pg_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/irs
	name = "internal revenue service jacket"
	desc = "I'm crazy enough to take on The Owl, but the IRS? Nooo thank you!"
	icon_state = "irs_suit"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/costume/irs/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_vest_allowed

/obj/item/clothing/suit/hooded/hotdog
	name = "hotdog suit"
	desc = "With great hotdog comes great responsi-bun-ity."
	icon_state = "hotdog"
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN
	hoodtype = /obj/item/clothing/head/hooded/hotdog

/obj/item/clothing/head/hooded/hotdog
	name = "hotdog suit hood"
	desc = "There's a certain joke to be made here."
	icon_state = "hotdog"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR

/obj/item/clothing/suit/costume/dio
	name = "flamboyant jacket"
	desc = "It exudes a menancing aura."
	icon_state = "dio_jacket"
	inhand_icon_state = null
	body_parts_covered = CHEST|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/hooded/dinojammies
	name = "dinosaur pajamas"
	desc = "The ultimate in reptile-pajama-costume fusion."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "dinojammies"
	worn_icon_state = "dinojammies"
	hoodtype = /obj/item/clothing/head/hooded/dinojammies

/obj/item/clothing/head/hooded/dinojammies
	desc = "A dinosaur head hood."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "dinojammies_hood"
	worn_icon_state = "dinojammies_hood"
	flags_inv = HIDEHAIR

/obj/item/clothing/suit/hooded/gorilla
	name = "gorilla costume"
	desc = "Ooga!"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "gorilla"
	worn_icon_state = "gorilla"
	hoodtype = /obj/item/clothing/head/hooded/gorilla
	alternative_screams = list('sound/creatures/gorilla.ogg')

/obj/item/clothing/head/hooded/gorilla
	desc = "A gorilla costume hood."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "gorilla"
	worn_icon_state = "gorilla"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/costume/bunnysuit/regular
	slowdown = 0
	desc = "Hop Hop Hop! It looks old."

/obj/item/clothing/suit/shipwreckedsuit
	name = "shipwrecked captain suit"
	desc = "DISCLAIMER:Not Space Proof. Wearing this suit gives you the luck of a true space captain! Just avoid the space rocks..."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "shipwrecked_suit"
	worn_icon_state = "shipwrecked_suit"

/obj/item/clothing/head/shipwreckedhelmet
	name = "shipwrecked captain helmet"
	desc = "DISCLAIMER:Not Space Proof. A vital part of keeping out the poisonous oxygen!... what do you mean oxygen is good for me?"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "shipwrecked_helmet"
	worn_icon_state = "shipwrecked_helmet"
	worn_y_offset = 4

/obj/item/clothing/suit/kingofbugssuit
	name = "king of bugs suit"
	desc = "DISCLAIMER:Not Space Proof. Dandori Issues "
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "kingofbugs_suit"
	worn_icon_state = "kingofbugs_suit"

/obj/item/clothing/head/kingofbugshelmet
	name = "king of bugs helmet"
	desc = "DISCLAIMER:Not Space Proof. FOOD!!!"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "kingofbugs_helmet"
	worn_icon_state = "kingofbugs_helmet"
	worn_y_offset = 5

/obj/item/clothing/head/helldiverhelmet
	name = "helldiver helmet"
	desc = "Have a Nice Cup of LIBER-TEA"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "helldiver_helm"
	worn_icon_state = "helldiver_helm"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT

/datum/loadout_item/head/helldiverhelmet
	name = "Helldiver Helmet"
	item_path = /obj/item/clothing/head/helldiverhelmet

/datum/store_item/head/helldiverhelmet
	name = "Helldiver Helmet"
	item_path = /obj/item/clothing/head/helldiverhelmet
	item_cost = 10000

/obj/item/clothing/suit/helldiverarmor
	name = "helldiver armor"
	desc = "How Do You Like The Taste of DEMOCRACY?!"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "helldiver_armor"
	worn_icon_state = "helldiver_armor"
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/helldiverarmor/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_vest_allowed

/datum/loadout_item/suit/helldiverarmor
	name = "Helldiver Armor"
	item_path = /obj/item/clothing/suit/helldiverarmor

/datum/store_item/suit/helldiverarmor
	name = "Helldiver Armor"
	item_path = /obj/item/clothing/suit/helldiverarmor
	item_cost = 10000

/obj/item/clothing/suit/hooded/ashsuit
	name = "ashsuit suit"
	desc = "Whoever controls the Plasma, controls the Spinward Sector."
	icon_state = "ashsuit"
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/ashsuit
	armor_type = /datum/armor/hooded_ashsuit
	allowed = list(
		/obj/item/flashlight,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/resonator,
		/obj/item/storage/bag/ore,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/tank/internals,
		)
	resistance_flags = FIRE_PROOF
	clothing_traits = list(TRAIT_SNOWSTORM_IMMUNE)

/datum/armor/hooded_ashsuit
	melee = 30
	bullet = 10
	laser = 10
	energy = 20
	bomb = 50
	fire = 50
	acid = 50

/obj/item/clothing/head/hooded/ashsuit
	name = "ashsuit hood"
	desc = "For covering your face when walking the ash dunes."
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "ashsuit"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hooded_explorer
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/hooded/ashsuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/hooded/ashsuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/suit/chameleon/syndie_armor
	name = "syndicate body armor"
	desc = "A set of red and black body armor. Lightweight but great protection."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "armor_syndie"
	armor_type = /datum/armor/mod_theme_infiltrator
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/chameleon/syndie_armor/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets)

/obj/item/clothing/suit/chameleon/syndie_armor/item_interaction(mob/living/user, obj/item/attacking_item, list/modifiers)
	if(attacking_item.tool_behaviour != TOOL_MULTITOOL)
		return ..()

	if(chameleon_action.hidden)
		chameleon_action.hidden = FALSE
		actions += chameleon_action
		chameleon_action.Grant(user)
		log_game("[key_name(user)] has removed the disguise lock on the chameleon body armor ([name]) with [attacking_item]")
	else
		chameleon_action.hidden = TRUE
		actions -= chameleon_action
		chameleon_action.Remove(user)
		log_game("[key_name(user)] has locked the disguise of the chameleon body armor ([name]) with [attacking_item]")
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/suit/infinity_jacket
	name = "infinity jersey"
	desc = "A jersey labelled '88', somehow leaving a threatening aura around it."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "infinity_jersey"

/obj/item/clothing/suit/thekiller_robe
	name = "killer's robe"
	desc = "As long as there has been man, there has been The Killer. They are surprisingly into the theater scene."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "thekiller_robe"
	flags_inv = HIDEJUMPSUIT
