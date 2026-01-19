/obj/structure/blob/special // Generic type for nodes/factories/cores/resource

/obj/structure/blob/special/be_pulsed()
	blob_team.blobstrain.on_special_pulsed(src)
	return ..()
