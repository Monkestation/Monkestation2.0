/obj/item/processing
	name = "generic dust"
	desc = "Some unknown waste refinery product."
	icon = 'monkestation/code/modules/factory_type_beat/icons/processing.dmi'
	icon_state = "dust"

	///When a refinery machine is working on this resource, we'll set this. Re reset when the process is finished, but the resource may still be refined/operated on further.
	var/obj/machinery/processed_by = null
