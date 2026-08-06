/// Iron required to manufacture one standard fuel rod.
#define RBMK_PROCESSOR_IRON_COST (3 * SHEET_MATERIAL_AMOUNT)
/// Fissile material required to manufacture one standard fuel rod.
#define RBMK_PROCESSOR_FUEL_COST (10 * SHEET_MATERIAL_AMOUNT)
/// Material required to manufacture one moderator rod.
#define RBMK_PROCESSOR_MODERATOR_COST (5 * SHEET_MATERIAL_AMOUNT)

/// Describes one operation available to an RBMK fuel processor.
/datum/rbmk_fuel_recipe
	/// Name shown in the fuel-processor interface.
	var/name = "Unknown process"
	/// Explanation shown beneath the recipe name.
	var/description = "No description."
	/// Materials charged from the linked ore silo for each completed item.
	var/list/material_cost = list()
	/// Depleted rod type consumed by an extraction recipe.
	var/input_rod_type
	/// Atom type created directly by a fabrication recipe.
	var/output_type
	/// Sheet stack type recovered by an extraction recipe.
	var/extracted_sheet_type

/// Fabricates the starter uranium fuel rod.
/datum/rbmk_fuel_recipe/fabricate_uranium
	name = "Fabricate uranium fuel rod"
	description = "Presses uranium and iron into a fresh starter fuel rod."
	material_cost = list(
		/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
		/datum/material/uranium = RBMK_PROCESSOR_FUEL_COST,
	)
	output_type = /obj/item/rbmk/fuel_rod/uranium

/// Recovers thorium from depleted uranium fuel.
/datum/rbmk_fuel_recipe/extract_thorium
	name = "Extract thorium"
	description = "Extracts thorium from a depleted uranium rod and stores the ruined casing."
	input_rod_type = /obj/item/rbmk/fuel_rod/uranium
	extracted_sheet_type = /obj/item/stack/sheet/mineral/thorium

/// Fabricates a thorium fuel rod.
/datum/rbmk_fuel_recipe/fabricate_thorium
	name = "Fabricate thorium fuel rod"
	description = "Presses thorium and iron into a fresh thorium fuel rod."
	material_cost = list(
		/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
		/datum/material/thorium = RBMK_PROCESSOR_FUEL_COST,
	)
	output_type = /obj/item/rbmk/fuel_rod/thorium

/// Recovers plutonium from depleted thorium fuel.
/datum/rbmk_fuel_recipe/extract_plutonium
	name = "Extract plutonium"
	description = "Extracts plutonium from a depleted thorium rod and stores the ruined casing."
	input_rod_type = /obj/item/rbmk/fuel_rod/thorium
	extracted_sheet_type = /obj/item/stack/sheet/mineral/plutonium

/// Fabricates a plutonium fuel rod.
/datum/rbmk_fuel_recipe/fabricate_plutonium
	name = "Fabricate plutonium fuel rod"
	description = "Presses plutonium and iron into a fresh plutonium fuel rod."
	material_cost = list(
		/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
		/datum/material/plutonium = RBMK_PROCESSOR_FUEL_COST,
	)
	output_type = /obj/item/rbmk/fuel_rod/plutonium

/// Fabricates a plasma moderator rod.
/datum/rbmk_fuel_recipe/fabricate_plasma_moderator
	name = "Fabricate plasma moderator rod"
	description = "Presses stabilized plasma and iron into a plasma moderator rod."
	material_cost = list(
		/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
		/datum/material/plasma = RBMK_PROCESSOR_MODERATOR_COST,
	)
	output_type = /obj/item/rbmk/fuel_rod/plasma

/// Fabricates a bluespace moderator rod.
/datum/rbmk_fuel_recipe/fabricate_bluespace_moderator
	name = "Fabricate bluespace moderator rod"
	description = "Presses bluespace crystal and iron into a bluespace moderator rod."
	material_cost = list(
		/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
		/datum/material/bluespace = RBMK_PROCESSOR_MODERATOR_COST,
	)
	output_type = /obj/item/rbmk/fuel_rod/bluespace

/// Fabricates a diamond moderator rod.
/datum/rbmk_fuel_recipe/fabricate_diamond_moderator
	name = "Fabricate diamond moderator rod"
	description = "Presses diamond and iron into a diamond moderator rod."
	material_cost = list(
		/datum/material/iron = RBMK_PROCESSOR_IRON_COST,
		/datum/material/diamond = RBMK_PROCESSOR_MODERATOR_COST,
	)
	output_type = /obj/item/rbmk/fuel_rod/diamond

GLOBAL_LIST_INIT(rbmk_fuel_recipes, list(
	/datum/rbmk_fuel_recipe/fabricate_uranium = new /datum/rbmk_fuel_recipe/fabricate_uranium,
	/datum/rbmk_fuel_recipe/extract_thorium = new /datum/rbmk_fuel_recipe/extract_thorium,
	/datum/rbmk_fuel_recipe/fabricate_thorium = new /datum/rbmk_fuel_recipe/fabricate_thorium,
	/datum/rbmk_fuel_recipe/extract_plutonium = new /datum/rbmk_fuel_recipe/extract_plutonium,
	/datum/rbmk_fuel_recipe/fabricate_plutonium = new /datum/rbmk_fuel_recipe/fabricate_plutonium,
	/datum/rbmk_fuel_recipe/fabricate_plasma_moderator = new /datum/rbmk_fuel_recipe/fabricate_plasma_moderator,
	/datum/rbmk_fuel_recipe/fabricate_bluespace_moderator = new /datum/rbmk_fuel_recipe/fabricate_bluespace_moderator,
	/datum/rbmk_fuel_recipe/fabricate_diamond_moderator = new /datum/rbmk_fuel_recipe/fabricate_diamond_moderator,
))

#undef RBMK_PROCESSOR_IRON_COST
#undef RBMK_PROCESSOR_FUEL_COST
#undef RBMK_PROCESSOR_MODERATOR_COST
