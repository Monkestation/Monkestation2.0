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

/datum/supply_pack/science/chromosomes
	name = "Genetic Chromosomes Crate"
	desc = "Have you ever had issues with harvesting chromosomes from your local crew? This crate is exactly what you need. Contains 5 chromosomes that were nearest to our hands while packing this crate."
	cost = CARGO_CRATE_VALUE * 5
	access = ACCESS_GENETICS
	contains = list()
	crate_name = "surplus chromosome crate"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/science/chromosomes/fill(obj/structure/closet/crate/our_crate)
	for(var/i in 1 to 5)
		var/chromosome_path = generate_chromosome()
		new chromosome_path(our_crate)
