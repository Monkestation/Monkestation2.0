/// Lazylist of slime types that have been mutated so far
GLOBAL_LIST(obtained_slime_types)
/// Lazylist of xenofauna the ranch can print, filled in as slimes that want to eat them show up
GLOBAL_LIST(unlocked_xenofauna)
/// Mapping of slime colors to their respective typepaths.
GLOBAL_ALIST_INIT(slime_colors_to_types, init_slime_colors_to_types())

/datum/slime_type
	///Our slime's color as text. Used by both description, and icon
	var/color
	///Whether the slime icons should be semi-transparent
	var/transparent = FALSE
	///The type our slime spawns
	var/core_type
	///The hexcode used by the slime to colour their victims
	var/rgb_code
	/// For slime types that use fancy visual effects.
	var/obj/effect/abstract/visual_effect/visual_effect
	/// List of `/datum/slime_mutation`s this slime type is eligible for.
	/// Slimes with no further mutations can only go rainbow.
	var/list/possible_mutations = list(/datum/slime_mutation/rainbow)

/datum/slime_type/Destroy(force)
	if(!force)
		. = QDEL_HINT_LETMELIVE
		CRASH("Something tried to delete a \"/datum/slime_type\", this should never happen as could lead to slime colors being broken!")
	return ..()

//TIER 0

/datum/slime_type/grey
	color = SLIME_TYPE_GREY
	transparent = TRUE
	core_type = /obj/item/slime_extract/grey
	rgb_code = COLOR_SLIME_GREY
	possible_mutations = list(
		/datum/slime_mutation/metal,
		/datum/slime_mutation/orange,
		/datum/slime_mutation/purple,
		/datum/slime_mutation/blue,
	)

//TIER 1

/datum/slime_type/blue
	color = SLIME_TYPE_BLUE
	transparent = TRUE
	core_type = /obj/item/slime_extract/blue
	rgb_code = COLOR_SLIME_BLUE
	possible_mutations = list(
		/datum/slime_mutation/silver,
		/datum/slime_mutation/darkblue,
		/datum/slime_mutation/pink,
	)

/datum/slime_type/metal
	color = SLIME_TYPE_METAL
	core_type = /obj/item/slime_extract/metal
	rgb_code = COLOR_SLIME_METAL
	possible_mutations = list(
		/datum/slime_mutation/silver,
		/datum/slime_mutation/yellow,
		/datum/slime_mutation/gold,
	)

/datum/slime_type/purple
	color = SLIME_TYPE_PURPLE
	transparent = TRUE
	core_type = /obj/item/slime_extract/purple
	rgb_code = COLOR_SLIME_PURPLE
	possible_mutations = list(
		/datum/slime_mutation/green,
		/datum/slime_mutation/darkblue,
		/datum/slime_mutation/darkpurple,
	)

/datum/slime_type/orange
	color = SLIME_TYPE_ORANGE
	transparent = TRUE
	core_type = /obj/item/slime_extract/orange
	rgb_code = COLOR_SLIME_ORANGE
	possible_mutations = list(
		/datum/slime_mutation/darkpurple,
		/datum/slime_mutation/yellow,
		/datum/slime_mutation/red,
	)

//TIER 2

/datum/slime_type/darkblue
	color = SLIME_TYPE_DARK_BLUE
	transparent = TRUE
	core_type = /obj/item/slime_extract/darkblue
	rgb_code = COLOR_SLIME_DARK_BLUE
	possible_mutations = list(
		/datum/slime_mutation/blue,
		/datum/slime_mutation/purple,
		/datum/slime_mutation/cerulean,
	)

/datum/slime_type/darkpurple
	color = SLIME_TYPE_DARK_PURPLE
	core_type = /obj/item/slime_extract/darkpurple
	rgb_code = COLOR_SLIME_DARK_PURPLE
	possible_mutations = list(
		/datum/slime_mutation/sepia,
		/datum/slime_mutation/purple,
		/datum/slime_mutation/orange,
	)

/datum/slime_type/silver
	color = SLIME_TYPE_SILVER
	core_type = /obj/item/slime_extract/silver
	rgb_code = COLOR_SLIME_SILVER
	possible_mutations = list(
		/datum/slime_mutation/pyrite,
		/datum/slime_mutation/metal,
		/datum/slime_mutation/blue,
	)

/datum/slime_type/yellow
	color = SLIME_TYPE_YELLOW
	transparent = TRUE
	core_type = /obj/item/slime_extract/yellow
	rgb_code = COLOR_SLIME_YELLOW
	possible_mutations = list(
		/datum/slime_mutation/bluespace,
		/datum/slime_mutation/metal,
		/datum/slime_mutation/orange,
	)

//TIER 3

/datum/slime_type/bluespace
	color = SLIME_TYPE_BLUESPACE
	core_type = /obj/item/slime_extract/bluespace
	rgb_code = COLOR_SLIME_BLUESPACE
	visual_effect = /obj/effect/abstract/visual_effect/bluespace

/datum/slime_type/cerulean
	color = SLIME_TYPE_CERULEAN
	transparent = TRUE
	core_type = /obj/item/slime_extract/cerulean
	rgb_code = COLOR_SLIME_CERULEAN

/datum/slime_type/pyrite
	color = SLIME_TYPE_PYRITE
	core_type = /obj/item/slime_extract/pyrite
	rgb_code = COLOR_SLIME_PYRITE

/datum/slime_type/sepia
	color = SLIME_TYPE_SEPIA
	transparent = TRUE
	core_type = /obj/item/slime_extract/sepia
	rgb_code = COLOR_SLIME_SEPIA

//TIER 4

/datum/slime_type/gold
	color = SLIME_TYPE_GOLD
	core_type = /obj/item/slime_extract/gold
	rgb_code = COLOR_SLIME_GOLD
	visual_effect = /obj/effect/abstract/visual_effect/gold
	possible_mutations = list(
		/datum/slime_mutation/adamantine,
	)

/datum/slime_type/green
	color = SLIME_TYPE_GREEN
	transparent = TRUE
	core_type = /obj/item/slime_extract/green
	rgb_code = COLOR_SLIME_GREEN
	possible_mutations = list(
		/datum/slime_mutation/black,
	)

/datum/slime_type/pink
	color = SLIME_TYPE_PINK
	transparent = TRUE
	core_type = /obj/item/slime_extract/pink
	rgb_code = COLOR_SLIME_PINK
	possible_mutations = list(
		/datum/slime_mutation/lightpink,
	)

/datum/slime_type/red
	color = SLIME_TYPE_RED
	transparent = TRUE
	core_type = /obj/item/slime_extract/red
	rgb_code = COLOR_SLIME_RED
	possible_mutations = list(
		/datum/slime_mutation/oil,
	)

//TIER 5

/datum/slime_type/adamantine
	color = SLIME_TYPE_ADAMANTINE
	core_type = /obj/item/slime_extract/adamantine
	rgb_code = COLOR_SLIME_ADAMANTINE

/datum/slime_type/black
	color = SLIME_TYPE_BLACK
	transparent = TRUE
	core_type = /obj/item/slime_extract/black
	rgb_code = COLOR_SLIME_BLACK
	visual_effect = /obj/effect/abstract/visual_effect/black

/datum/slime_type/lightpink
	color = SLIME_TYPE_LIGHT_PINK
	transparent = TRUE
	core_type = /obj/item/slime_extract/lightpink
	rgb_code = COLOR_SLIME_LIGHT_PINK

/datum/slime_type/oil
	color = SLIME_TYPE_OIL
	core_type = /obj/item/slime_extract/oil
	rgb_code = COLOR_SLIME_OIL
	visual_effect = /obj/effect/abstract/visual_effect/oil

//Tier Special

/datum/slime_type/rainbow
	color = SLIME_TYPE_RAINBOW
	transparent = TRUE
	core_type = /obj/item/slime_extract/rainbow
	rgb_code = COLOR_SLIME_RAINBOW
	visual_effect = /obj/effect/abstract/visual_effect/rainbow
	possible_mutations = list()

/// Maps each slime color to its /datum/slime_type.
/proc/init_slime_colors_to_types() as /alist
	. = alist()
	for(var/datum/slime_type/slime_type as anything in subtypesof(/datum/slime_type))
		if(slime_type::color)
			.[slime_type::color] = slime_type
