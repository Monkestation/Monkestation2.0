/datum/mod_theme/moonlight
	name = "elite"
	desc = "An elite suit upgraded by Cybersun Industries, offering upgraded armor values."
	extended_desc = "An evolution of the syndicate suit, featuring a bulkier build and a matte black color scheme, \
		this suit is only produced for high ranking Syndicate officers and elite strike teams. \
		It comes built with a secondary layering of ceramic and Kevlar into the plating providing it with \
		exceptionally better protection along with fire and acid proofing. A small tag hangs off of it reading; \
		'Property of the Gorlex Marauders, with assistance from Cybersun Industries. \
		All rights reserved, tampering with suit will void life expectancy.'"
	armor_type = /datum/armor/mod_theme_moonlight
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	default_skin = "brigadegen"
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.5
	ui_theme = "ntos"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
	)

	skins = list(
		"brigadecom" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_icons.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_onmob.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"brigadesec" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_icons.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_onmob.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"brigadeeng" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_icons.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_onmob.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"brigademed" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_icons.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_onmob.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"brigadegen" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_icons.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/veth_misc_items/moonlight_brigade/brigade_onmob.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)
/datum/mod_theme/moonlight/knight_commander
	name = "Moonlight Knight Commander MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments."
	extended_desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments. This MOD is a heavily modified unit that projects several layers of hard light when it is active. This was made to make you FEEL cool."
	default_skin = "brigadecom"

/datum/mod_theme/moonlight/knight
	name = "Moonlight Knight MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments and offers a heavy layer of protection."
	extended_desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments and offers a heavy layer of protection. This one is in the style of a knight of old. The helmet has the Moonlight Brigade emblem burned on the side."
	default_skin = "brigadesec"

/datum/mod_theme/moonlight/cleric
	name = "Moonlight Cleric MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a decorated powered suit that allows for easy identification of medics."
	extended_desc = "The control unit of a Modular Outerwear Device, a decorated powered suit that allows for easy identification of medics. The plating on the suit allows for ease of movement and protects against environmental hazards. The shoulder plate has the Moonlight Brigade emblem burned onto it."
	default_skin = "brigademed"

/datum/mod_theme/moonlight/artificer
	name = "Moonlight Artificer MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments."
	extended_desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments. This suit's lining was particularly crafted to deal with severe temperature changes and fires. The thigh plate has the Moonlight Brigade emblem burned on the side."
	default_skin = "brigadegen"

/datum/mod_theme/moonlight/rogue
	name = "Moonlight Rogue MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments and gives you a sense of cloak and dagger."
	extended_desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments and gives you a sense of cloak and dagger. This suit balanced practicality with style, on the palm of the suit the Moonlight Brigade’s emblem was burned in."
	default_skin = "brigadeeng"

/datum/armor/mod_theme_moonlight
	melee = 35
	bullet = 30
	laser = 35
	energy = 35
	bomb = 55
	bio = 100
	fire = 100
	acid = 100
	wound = 25

/obj/item/mod/control/pre_equipped/moonlight/knight_commander
	starting_frequency = MODLINK_FREQ_MOONLIGHT
	theme = /datum/mod_theme/moonlight/knight_commander
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/megaphone,
		/obj/item/mod/module/projectile_dampener,
		/obj/item/mod/module/pepper_shoulders,
		/obj/item/mod/module/visor/sechud, // monkestation addition
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
	)

/obj/machinery/suit_storage_unit/moonlight/knight_commander
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/moonlight/knight_commander

/obj/item/mod/control/pre_equipped/moonlight/security_knight
	starting_frequency = MODLINK_FREQ_MOONLIGHT
	theme = /datum/mod_theme/moonlight/knight
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/projectile_dampener,
		/obj/item/mod/module/pepper_shoulders,
		/obj/item/mod/module/visor/sechud,
	)

/obj/machinery/suit_storage_unit/moonlight/security_knight
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/moonlight/security_knight

/obj/item/mod/control/pre_equipped/moonlight/medical_cleric
	starting_frequency = MODLINK_FREQ_MOONLIGHT
	theme = /datum/mod_theme/moonlight/cleric
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/quick_carry,
		/obj/item/mod/module/visor/medhud,
	)

/obj/machinery/suit_storage_unit/moonlight/medical_cleric
	mask_type = /obj/item/clothing/mask/breath/medical
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/moonlight/medical_cleric

/obj/item/mod/control/pre_equipped/moonlight/engineering_artificer
	starting_frequency = MODLINK_FREQ_MOONLIGHT
	theme = /datum/mod_theme/moonlight/artificer
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/visor/diaghud,
	)

/obj/machinery/suit_storage_unit/moonlight/engineering_artificer
	mask_type = /obj/item/clothing/mask/gas/atmos
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/moonlight/engineering_artificer

/obj/item/mod/control/pre_equipped/moonlight/stealth_rogue
	starting_frequency = MODLINK_FREQ_MOONLIGHT
	theme = /datum/mod_theme/moonlight/rogue
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/stealth,
		/obj/item/mod/module/quick_carry,
	)

/obj/machinery/suit_storage_unit/moonlight/stealth_rogue
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/internals/oxygen
	mod_type = /obj/item/mod/control/pre_equipped/moonlight/stealth_rogue
