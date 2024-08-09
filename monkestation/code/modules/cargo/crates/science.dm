/datum/supply_pack/science/xenobio
	name = "Xenobiology Lab Crate"
	desc = "In case a freak accident has rendered the xenobiology lab non-functional! Contains two grey slime extracts, some plasma, and the required circuit boards to get your lab up and running! Requires xenobiology access to open."
	cost = CARGO_CRATE_VALUE * 20
	access = ACCESS_XENOBIOLOGY
	contains = list(/obj/item/slime_extract/grey = 2,
					/obj/item/reagent_containers/syringe/plasma,
					/obj/item/circuitboard/computer/slime_market,
					/obj/item/circuitboard/machine/slime_market_pad,
					/obj/item/circuitboard/machine/biomass_recycler,
					/obj/item/vacuum_pack)
	crate_name = "xenobiology starter crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/secureboard
	name = "Secure Science Board Crate"
	desc = "Control the Silicons with upload and robotics control console boards."
	cost = CARGO_CRATE_VALUE * 20
	access = ACCESS_RD
	contains = list(/obj/item/circuitboard/computer/aiupload, /obj/item/circuitboard/computer/robotics, /obj/item/circuitboard/computer/borgupload)
	crate_name = "secure science board crate"
	crate_type = /obj/structure/closet/crate/secure/science
