//Toxins and low-level healing chems
/datum/chemical_reaction/randomized/scichem
	randomize_req_temperature = FALSE

	randomize_inputs = TRUE
	min_input_reagent_amount = 1
	max_input_reagent_amount = 1
	min_input_reagents = 2
	max_input_reagents = 2
	possible_reagents = list(/datum/reagent/mixer, /datum/reagent/mixer/bicarbide, /datum/reagent/mixer/obicarbide, /datum/reagent/mixer/sbicarbide, /datum/reagent/mixer/pbicarbide,
							/datum/reagent/mixer/caemide, /datum/reagent/mixer/ncaemide)

	max_catalysts = 0

	results = list(/datum/reagent/toxin = 2)

//impure Bicard
/datum/chemical_reaction/randomized/scichem/sbicarid
	results = list(/datum/reagent/medicine/sbicarid = 2)

//impure kelo
/datum/chemical_reaction/randomized/scichem/skelo
	results = list(/datum/reagent/medicine/skelo = 2)

//Determination
/datum/chemical_reaction/randomized/scichem/determination
	results = list(/datum/reagent/determination = 2)

//Mint Toxin
/datum/chemical_reaction/randomized/scichem/mint
	min_input_reagents = 3
	max_input_reagents = 3
	results = list(/datum/reagent/consumable/mintextract)

//Tirizine
/datum/chemical_reaction/randomized/scichem/tirizine
	min_input_reagents = 3
	max_input_reagents = 3
	results = list(/datum/reagent/toxin/staminatoxin = 3)


//Table 2, for easier healing chems
//Ventrite
/datum/chemical_reaction/randomized/scichem/table2
	randomize_req_temperature = FALSE
	randomize_inputs = TRUE
	min_input_reagent_amount = 1
	max_input_reagent_amount = 1
	min_input_reagents = 2
	max_input_reagents = 2
	possible_reagents = list(/datum/reagent/mixer/paraide, /datum/reagent/mixer/sparaide, /datum/reagent/mixer/dparaide, /datum/reagent/mixer/rparaide, /datum/reagent/mixer/srparaide,
							/datum/reagent/mixer/hebitide, /datum/reagent/mixer/uhebitide, /datum/reagent/mixer/mhebitide)
	max_catalysts = 0
	results = list(/datum/reagent/medicine/ventrite = 2)

//Spirozrite
/datum/chemical_reaction/randomized/scichem/table2/spirozrite
	results = list(/datum/reagent/medicine/spirozrite = 2)

//Citisrite
/datum/chemical_reaction/randomized/scichem/table2/citisrite
	results = list(/datum/reagent/medicine/citisrite = 2)

//Purgrite
/datum/chemical_reaction/randomized/scichem/table2/purgrite
	results = list(/datum/reagent/medicine/purgrite = 2)

//Sanguirite
/datum/chemical_reaction/randomized/scichem/table2/sanguirite
	results = list(/datum/reagent/medicine/coagulant = 2)

//Giadone
/datum/chemical_reaction/randomized/scichem/table2/giadone
	results = list(/datum/reagent/medicine/giadone = 2)

//Bicarbital
/datum/chemical_reaction/randomized/scichem/table2/bicarbital
	min_input_reagents = 3
	max_input_reagents = 3
	results = list(/datum/reagent/medicine/bicarbital = 3)

//Keluri
/datum/chemical_reaction/randomized/scichem/table2/keluri
	min_input_reagents = 3
	max_input_reagents = 3
	results = list(/datum/reagent/medicine/keluri = 3)

//Table 3
//This is WAY harder to make but also very much worth it.

//Omnizine
/datum/chemical_reaction/randomized/scichem/table3
	randomize_req_temperature = FALSE
	randomize_inputs = TRUE
	min_input_reagent_amount = 1
	max_input_reagent_amount = 1
	min_input_reagents = 2
	max_input_reagents = 2
	possible_reagents = list(/datum/reagent/mixer/selenide, /datum/reagent/mixer/helioside, /datum/reagent/mixer/kelaide, /datum/reagent/mixer/proteoside, /datum/reagent/mixer/meteoside,
							/datum/reagent/mixer/hadronide, /datum/reagent/mixer/etheride, /datum/reagent/mixer/etherideii, /datum/reagent/mixer/etherideiii, /datum/reagent/mixer/etherideiv, /datum/reagent/mixer/etheridev)
	max_catalysts = 0
	results = list(/datum/reagent/medicine/omnizine = 2)

//Omnidrite
/datum/chemical_reaction/randomized/scichem/table3/omnidrite
	results = list(/datum/reagent/medicine/omnidrite = 2)

//Super Lube
/datum/chemical_reaction/randomized/scichem/table3/superlube
	results = list(/datum/reagent/lube/superlube = 2)

//Bicaridine
/datum/chemical_reaction/randomized/scichem/table3/bicaridine
	results = list(/datum/reagent/medicine/bicaridine = 2)

//Kelotane
/datum/chemical_reaction/randomized/scichem/table3/kelotane
	results = list(/datum/reagent/medicine/kelotane = 2)

//Mutation Toxin
/datum/chemical_reaction/randomized/scichem/table3/mutation
	min_input_reagents = 3
	max_input_reagents = 3
	results = list(/datum/reagent/mutationtoxin = 3)

//Hellwater
/datum/chemical_reaction/randomized/scichem/table3/hellwater
	min_input_reagents = 3
	max_input_reagents = 3
	results = list(/datum/reagent/hellwater = 3)
