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
		new /obj/item/reagent_containers/chemcanister(src)

/obj/item/bedsheet/prisoner
	name = "prisoner's blanket"
	desc = "An old, heavy-duty, Nanotrasen-issue prison bedsheet, recently swapped for brown ones. You try not to think about where those stains came from..."
	icon_state = "sheetprisoner"
	inhand_icon_state = "sheetprisoner"
	dream_messages = list("a prison cell", "orange", "a warden", "filth", "captivity", "shackles", "misconduct", "depravity")
	bedsheet_type = "abstract" // Not really, but we don't want this one randomly spawned
