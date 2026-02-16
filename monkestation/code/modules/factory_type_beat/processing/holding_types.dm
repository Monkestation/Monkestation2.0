/**
 * The objects used to store minerals for further refinement steps.
 */
/obj/item/processing
	name = "generic dust"
	desc = "Some unknown waste refinery product."
	icon = 'monkestation/code/modules/factory_type_beat/icons/processing.dmi'
	icon_state = "dust"

	///When a refinery machine is working on this resource, we'll set this. Re reset when the process is finished, but the resource may still be refined/operated on further.
	var/obj/machinery/processed_by = null

/obj/item/processing/proc/set_colors()
	var/list/color_amounts = list()
	var/total_amount = 0
	var/alpha_sum = 0
	for(var/datum/material/material as anything in custom_materials)
		var/color = material.greyscale_colors
		var/amount = custom_materials[material]
		var/mat_alpha = material.alpha
		color_amounts[color] += amount // Accumulate if same color appears
		total_amount += amount
		alpha_sum += mat_alpha * amount

	if(total_amount <= 0)
		return

	// Normalize weights
	var/list/weighted_colors = list()
	for(var/color in color_amounts)
		var/weight = color_amounts[color] / total_amount
		var/rounded_weight = round(weight, MOVABLE_PHYSICS_PRECISION)

		weighted_colors[color] = rounded_weight

	var/final_color = BlendMultipleRGB(weighted_colors)
	if(isnull(final_color))
		return

	// Calculate final alpha as weighted average
	var/final_alpha = clamp(round(alpha_sum / total_amount, 1), 0, 255)

	add_atom_colour(final_color, FIXED_COLOUR_PRIORITY)
	alpha = final_alpha

/obj/item/processing/refined_dust
	name = "refined dust"
	desc = "After being enriched it has turned into some concentrated refined dust."

/obj/item/processing/dirty_dust
	name = "dirty dust"
	desc = "After crushing some clumps we are left with this. Still contaminated with residue and needs enriching."
	icon = 'monkestation/icons/obj/items/drugs.dmi'
	icon_state = "crack"

/obj/item/processing/clumps
	name = "ore clumps"
	desc = "After being purified we are left with some clumps of ore. It needs to be crushed."
	icon_state = "clump"

/obj/item/processing/shards
	name = "ore shards"
	desc = "After being filled with chemicals and shattered we are left with some shards of ores. That need to be baked."
	icon_state = "shard"

/obj/item/processing/crystals
	name = "ore crystals"
	desc = "After crystalizing some clean slurry we have crystals. They need to be split apart."
	icon_state = "crystal"

/datum/reagent/brine
	name = "Brine"
	restricted = TRUE

/**
 * Extra boulder types that add bonuses or have different minerals not generated from ssoregen.
 */
///Boulders with special artificats that can give higher mining points
/obj/item/boulder/artifact
	name = "artifact boulder"
	desc = "This boulder is brimming with strange energy. Cracking it open could contain something unusual for science."
	icon_state = "boulder_artifact"
	/// References to the relic inside the boulder, if any.
	var/obj/item/artifact_inside

/obj/item/boulder/artifact/Initialize(mapload)
	. = ..()
	artifact_inside = spawn_artifact(src) /// This could be poggers for archaeology in the future.

/obj/item/boulder/artifact/Destroy(force)
	QDEL_NULL(artifact_inside)
	return ..()

/obj/item/boulder/artifact/convert_to_ore()
	. = ..()
	artifact_inside.forceMove(drop_location())
	artifact_inside = null

/obj/item/boulder/artifact/break_apart()
	artifact_inside = null
	return ..()

///Boulders usually spawned in lavaland labour camp area
/obj/item/boulder/gulag
	name = "low-quality boulder"
	desc = "This rocks. It's a low quality boulder, so it's probably not worth as much."

/obj/item/boulder/gulag/Initialize(mapload)
	. = ..()

	/// Static list of all minerals to populate gulag boulders with.
	var/list/static/gulag_minerals = list(
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 95,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)

	set_custom_materials(list(pick_weight(gulag_minerals) = SHEET_MATERIAL_AMOUNT * rand(1, 3)))

///Boulders usually spawned in lavaland labour camp area but with bluespace material
/obj/item/boulder/gulag_expanded
	name = "low-density boulder"
	desc = "This rocks. It's not very well packed, and can't contain as many minerals."

/obj/item/boulder/gulag_expanded/Initialize(mapload)
	. = ..()

	/// Static list of all minerals to populate gulag boulders with, but with bluespace added where safe.
	var/list/static/expanded_gulag_minerals = list(
		/datum/material/bluespace = 1,
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 94,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)

	set_custom_materials(list(pick_weight(expanded_gulag_minerals) = SHEET_MATERIAL_AMOUNT * rand(1, 3)))

///lowgrade boulder, most commonly spawned
/obj/item/boulder/shabby
	name = "shabby boulder"
	desc = "A bizzare, twisted boulder. Wait, wait no, it's just a rock."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.1, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.1)
	durability = 1
