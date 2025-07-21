/datum/asset/spritesheet_batched/pipes
	name = "pipes"

/datum/asset/spritesheet_batched/pipes/create_spritesheets()
	for (var/each in list('icons/obj/atmospherics/pipes/pipe_item.dmi', 'monkestation/icons/obj/atmospherics/pipes/disposal.dmi', 'icons/obj/atmospherics/pipes/transit_tube.dmi', 'icons/obj/plumbing/fluid_ducts.dmi'))
		insert_all_icons("", each, GLOB.alldirs)
