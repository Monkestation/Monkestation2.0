/datum/map_template/ruin/lavaland/yogs_base
	name = "Yogs lavaland base"
//	id = "yog-base-ruin" Purposefully left out so SSmapping won't spawn us naturally
	description = "The Yogs lavaland base, gulag spawned seperatelly"
	prefix = "_maps/map_files/Mining/"
	suffix = "lavabase_yog.dmm"
	allow_duplicates = FALSE
	always_place = TRUE

/obj/structure/fluff/papershredder
	name = "paper shredder"
	desc = "A very old and non-functional machine for shredding illegal documents, turns out a recycler worked better than these and they were promptly abandoned."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "papershredder"
	density = TRUE

/obj/structure/sign/departments/mining
	name = "\improper Mining sign"
	sign_change_name = "Department - Cargo: Mining"
	desc = "A sign labelling the mining division of the station. Minions of Smaug."
	icon_state = "mining_old"
	is_editable = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/departments/mining, 32)

/obj/structure/curtain/closed
	icon_state = "bathroom-closed"

/obj/structure/curtain/closed/Initialize(mapload)
	. = ..()
	toggle()

/obj/item/storage/lockbox/vialbox/blood
	name = "blood sample vial box"
	desc = "A small box that can hold up to six vials in a sealed environment. This one is intended to store blood."

/obj/item/storage/lockbox/vialbox/blood/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/cup/vial(src)

/obj/item/bedsheet/prisoner
	name = "prisoner's blanket"
	desc = "An old, heavy-duty, Nanotrasen-issue prison bedsheet, recently swapped for brown ones. You try not to think about where those stains came from..."
	icon_state = "sheetprisoner"
	inhand_icon_state = "sheetprisoner"
	dream_messages = list("a prison cell", "orange", "a warden", "filth", "captivity", "shackles", "misconduct", "depravity")
	bedsheet_type = "abstract" // Not really, but we don't want this one randomly spawned
