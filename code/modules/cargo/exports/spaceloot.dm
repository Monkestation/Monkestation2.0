//ALL OF THIS IS MONKESTATION EDIT

/datum/export/space_salvage
	cost = CARGO_CRATE_VALUE * 2
	unit_name = "space salvage"

/datum/export/space_salvage/syndicate
	unit_name = "syndicate salvage"

/datum/export/space_salvage/syndicate/blackbox
	cost = CARGO_CRATE_VALUE * 10 //good luck getting it though lmao
	unit_name = "vital syndicate intelligence"
	export_types = list(/obj/item/syndicate_blackbox)

/datum/export/space_salvage/syndicate/key
	cost = CARGO_CRATE_VALUE * 3 //you can get them from traitors, but explorers can get them from deep storage and depot (even if nobody spawns) and the other syndicate roles. sell that shit, dont give it to sec. trust me bro.
	unit_name = "syndicate encryption equipment"
	export_types = list(/obj/item/encryptionkey/syndicate)
