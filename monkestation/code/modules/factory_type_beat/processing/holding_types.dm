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

/**
 * Extra boulder types that add bonuses or have different minerals not generated from ssoregen.
 */
///Boulders with special artificats that can give higher mining points
/obj/item/boulder/artifact
	name = "artifact boulder"
	desc = "This boulder is brimming with strange energy. Cracking it open could contain something unusual for science."
