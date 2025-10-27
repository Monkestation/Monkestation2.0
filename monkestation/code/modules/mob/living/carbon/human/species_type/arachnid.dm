/datum/species/arachnid
	name = "\improper Arachnid"
	plural_form = "Arachnids"
	id = SPECIES_ARACHNIDS
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	visual_gender = FALSE
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_ARACHNID_WEB_SURFER,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	external_organs = list(
		/obj/item/organ/external/arachnid_appendages = "long",
		/obj/item/organ/external/chelicerae = "basic")
	mutant_organs = list(
		/obj/item/organ/internal/silkgland)
	meat = /obj/item/food/meat/slab/spider
	species_language_holder = /datum/language_holder/fly
	mutanttongue = /obj/item/organ/internal/tongue/arachnid
	mutanteyes = /obj/item/organ/internal/eyes/night_vision/arachnid
	mutantheart = /obj/item/organ/internal/heart/spider
	exotic_bloodtype = /datum/blood_type/crew/spider
	inherent_factions = list(FACTION_SPIDER)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/arachnid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/arachnid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/arachnid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/arachnid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/arachnid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/arachnid,
	)

/datum/species/arachnid/handle_chemical(datum/reagent/chem, mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REM * seconds_per_tick)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)
		return TRUE
	return ..()

/datum/species/arachnid/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))

/datum/species/arachnid/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

/datum/species/arachnid/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		damage_mods += 30 // Yes, a 30x damage modifier

/datum/species/arachnid/get_species_description()
	return "Arachnids are a species of humanoid spiders from a planet long lost to history. \
	They are known for their useful silks, which have saved lives in emergencies." // Allan please add details

/datum/species/arachnid/prepare_human_for_preview(mob/living/carbon/human/arachnid)
	arachnid.dna.features["arachnid_appendages"] = "Zigzag"
	arachnid.dna.features["chelicerae"] = "basic"
	var/datum/color_palette/generic_colors/colors = arachnid.dna.color_palettes[/datum/color_palette/generic_colors]
	colors.mutant_color = "#e9e9e9"
	arachnid.update_body(TRUE)

/datum/species/arachnid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Sericulture",
			SPECIES_PERK_DESC = "Arachnids have a silk gland organ that connects to their wrists, \
			allowing them to convert nutrition into silk related items and furniture.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Arachnids run slightly faster than other species, but are still outpaced by Goblins.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Big Appendages",
			SPECIES_PERK_DESC = "Arachnids have appendages that are not hidden by space suits \
			or MODsuits. This can make concealing your identity harder.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Maybe Too Many Eyes",
			SPECIES_PERK_DESC = "Arachnids cannot equip any kind of eyewear, requiring \
			alternatives like welding helmets or implants. Their eyes have night vision however.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Arachnid Biology",
			SPECIES_PERK_DESC = "Fly swatters and pest killer will deal significantly higher amounts of damage to an Arachnid.",
		),
	)

	return to_add

/datum/reagent/mutationtoxin/arachnid
	name = "Arachnid Mutation Toxin"
	description = "A spidering toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/arachnid
	taste_description = "webs"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/arachnid_mutationtoxin
	results = list(/datum/reagent/mutationtoxin/arachnid = 1)
	required_reagents = list(/datum/reagent/toxin = 1, /datum/reagent/mutationtoxin/lizard = 1)
	reaction_tags = REACTION_TAG_HARD

/*
 * Silk and Sericulture recipes
 */
/obj/item/stack/sheet/silk
	name = "silk"
	singular_name = "silk"
	desc = "A webby material, best to keep a couple handy."
	inhand_icon_state = null
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	icon = 'monkestation/icons/obj/stack_objects.dmi'
	icon_state = "silk"
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	mats_per_unit = list(/datum/material/silk = SHEET_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/cellulose = 20)
	tableVariant = /obj/structure/table/silk
	walltype = /turf/closed/wall/material/silk
	material_type = /datum/material/silk
	merge_type = /obj/item/stack/sheet/silk
	sheettype = "silk"
	novariants = TRUE

GLOBAL_LIST_INIT(silk_recipes, list ( \
	new /datum/stack_recipe_list("clothing", list(
		new /datum/stack_recipe("silk loincloth", /obj/item/clothing/under/silk/loincloth, 2, check_density = FALSE, category = CAT_CLOTHING), \
		new /datum/stack_recipe("black kimono", /obj/item/clothing/under/costume/kimono, 3, check_density = FALSE, category = CAT_CLOTHING), \
		new /datum/stack_recipe("red kimono", /obj/item/clothing/under/costume/kimono/red, 3, check_density = FALSE, category = CAT_CLOTHING), \
		new /datum/stack_recipe("purple kimono", /obj/item/clothing/under/costume/kimono/purple, 3, check_density = FALSE, category = CAT_CLOTHING), \
		new /datum/stack_recipe("mummy wrapping", /obj/item/clothing/under/costume/mummy, 3, check_density = FALSE, category = CAT_CLOTHING), \
		)),
	new /datum/stack_recipe_list("arachnid web structures", list(
		new /datum/stack_recipe("arachnid web", /obj/structure/spider/stickyweb/arachnid, 3, time = 6 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE), \
		new /datum/stack_recipe("arachnid solid web", /obj/structure/spider/solid/arachnid, 4, time = 6 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE), \
		new /datum/stack_recipe("arachnid web spikes", /obj/structure/spider/spikes/arachnid, 5, time = 6 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE), \
		new /datum/stack_recipe("arachnid web passage", /obj/structure/spider/passage/arachnid, 3, time = 4 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE), \
		)),
	new /datum/stack_recipe("refine silk into cloth", /obj/item/stack/sheet/cloth, 2, 1, 6, time = 2 SECONDS, check_density = FALSE, category = CAT_TOOLS), \
	new /datum/stack_recipe("improvised gauze", /obj/item/stack/medical/gauze/improvised, 2, 2, 6, check_density = FALSE, category = CAT_TOOLS), \
	new /datum/stack_recipe("rag", /obj/item/reagent_containers/cup/rag, 1, check_density = FALSE, category = CAT_CHEMISTRY), \
	new /datum/stack_recipe("silk chair", /obj/structure/chair/silk, 3, time = 1 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_FURNITURE), \
	new /datum/stack_recipe("silk bed", /obj/structure/bed/silk, 2, time = 1 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_FURNITURE), \
	new /datum/stack_recipe("silk floor tile", /obj/item/stack/tile/silk, 1, 4, 20, check_density = FALSE, category = CAT_TILES),
	))

/obj/item/stack/sheet/silk/get_main_recipes()
	. = ..()
	. += GLOB.silk_recipes

/obj/item/stack/sheet/silk/fifty
	amount = 50

/datum/material/silk
	name = "silk"
	desc = "Arachnid silk, for web development."
	color = "#ffffff"
	greyscale_colors = "#ffffff"
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/silk
	value_per_unit = 45 / SHEET_MATERIAL_AMOUNT
	armor_modifiers = list(MELEE = 0.1, BULLET = 0.1, LASER = 0.1, ENERGY = 0.1, BOMB = 0.1, BIO = 1, ACID = 1)
	beauty_modifier = 600 / SHEET_MATERIAL_AMOUNT
	texture_layer_icon_state = "silk"

/*
 * Weaker versions of the spider structures
 */

/obj/structure/spider/solid/arachnid //reduced integrity.
	name = "arachnid solid web"
	desc = "A solid wall of arachnid silk, thick enough to block air flow. Since arachnid silk is softer than the average silk, it's easier to destroy."
	max_integrity = 30

/obj/structure/spider/passage/arachnid // reduced integrity, see-through.
	name = "arachnid web passage"
	desc = "A messy connection of webs that block airflow, but still allows passage."
	max_integrity = 30
	opacity = FALSE

/obj/structure/spider/spikes/arachnid // minimum damage reduced from 20 to 5, max damage reduced from 30 to 5, integrity reduced.
	name = "arachnid web spikes"
	desc = "Silk hardened into small yet deadly spikes. Since arachnid silk is softer than the average silk, their efficiency is somewhat reduced."
	max_integrity = 10

/obj/structure/spider/spikes/arachnid/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 5, max_damage = 5, flags = CALTROP_NOSTUN | CALTROP_BYPASS_SHOES)

/obj/structure/spider/stickyweb/arachnid // reduced integrity, only carbons with more than two arachnid limbs can surf on it freely.
	name = "arachnid web"
	desc = "Designed to slow anything that isn't an arachnid. Really fragile."
	max_integrity = 10
	arachnid = TRUE

/obj/structure/spider/stickyweb/arachnid/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isliving(mover))
		if(HAS_TRAIT(mover, TRAIT_ARACHNID_WEB_SURFER))
			return TRUE
		if(mover.pulledby && HAS_TRAIT(mover.pulledby, TRAIT_ARACHNID_WEB_SURFER))
			return TRUE
		if(prob(50))
			loc.balloon_alert(mover, "stuck in web!")
			return FALSE
	else if(isprojectile(mover))
		return prob(30)
