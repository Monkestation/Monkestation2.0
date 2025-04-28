/datum/reagent/mixer
	name = "Mixide"
	description = "one of many experimental mixers used."
	color = "#252525"
	taste_description = "light poison"

/datum/reagent/mixer/on_mob_life(mob/living/M)
	M.adjustToxLoss(0.5*REM)
	..()
	return TRUE

/datum/chemical_reaction/mixer
	results = list(/datum/reagent/mixer = 3)
	required_reagents = list(/datum/reagent/consumable/salt = 1, /datum/reagent/fuel/oil = 2)



/datum/reagent/mixer/bicarbide
	name = "Salt of Bicarbide"

/datum/chemical_reaction/bicarbide
	results = list(/datum/reagent/mixer/bicarbide = 3)
	required_reagents = list(/datum/reagent/consumable/salt = 1, /datum/reagent/silicon = 2)


/datum/reagent/mixer/obicarbide
	name = "Organic Bicarbide"

/datum/chemical_reaction/obicarbide
	results = list(/datum/reagent/mixer/obicarbide = 2)
	required_reagents = list(/datum/reagent/blood = 1, /datum/reagent/mixer/bicarbide = 1)


/datum/reagent/mixer/sbicarbide
	name = "Soap of Bicarbide"

/datum/chemical_reaction/sbicarbide
	results = list(/datum/reagent/mixer/sbicarbide = 2)
	required_reagents = list(/datum/reagent/mixer/bicarbide = 1, /datum/reagent/lye = 1)

/datum/reagent/mixer/pbicarbide
	name = "Primal Bicarbide"

/datum/chemical_reaction/pbicarbide
	results = list(/datum/reagent/mixer/pbicarbide = 2)
	required_reagents = list(/datum/reagent/drug/space_drugs = 1, /datum/reagent/mixer/bicarbide = 1)



/datum/reagent/mixer/caemide
	name = "Caemide"

/datum/chemical_reaction/caemide
	results = list(/datum/reagent/mixer/caemide = 2)
	required_reagents = list(/datum/reagent/copper = 1, /datum/reagent/cryptobiolin = 1)

/datum/reagent/mixer/ncaemide
	name = "Neo Caemide"

/datum/chemical_reaction/ncaemide
	results = list(/datum/reagent/mixer/ncaemide = 2)
	required_reagents = list(/datum/reagent/mixer/caemide = 1, /datum/reagent/saltpetre = 1)

//Table 2 chems

/datum/reagent/mixer/paraide
	name = "Paraide"

/datum/chemical_reaction/paraide
	results = list(/datum/reagent/mixer/paraide = 3)
	required_reagents = list(/datum/reagent/lye = 1, /datum/reagent/drug/space_drugs = 1, /datum/reagent/saltpetre = 1)

/datum/reagent/mixer/sparaide
	name = "Stable Paraide"

/datum/chemical_reaction/sparaide
	results = list(/datum/reagent/mixer/sparaide = 2)
	required_reagents = list(/datum/reagent/mixer/paraide = 1, /datum/reagent/stable_plasma = 1)

/datum/reagent/mixer/dparaide
	name = "Distilled Paraide"

/datum/chemical_reaction/dparaide
	results = list(/datum/reagent/mixer/dparaide = 2)
	required_reagents = list(/datum/reagent/mixer/paraide = 1, /datum/reagent/drug/space_drugs = 1)

/datum/reagent/mixer/rparaide
	name = "Reactive Paraide"

/datum/chemical_reaction/rparaide
	results = list(/datum/reagent/mixer/rparaide = 2)
	required_reagents = list(/datum/reagent/mixer/paraide = 1, /datum/reagent/sodium = 1)

/datum/reagent/mixer/srparaide
	name = "Semi-Reactive Paraide"

/datum/chemical_reaction/srparaide
	results = list(/datum/reagent/mixer/srparaide = 2)
	required_reagents = list(/datum/reagent/mixer/sparaide = 1, /datum/reagent/sodium = 1)

/datum/reagent/mixer/hebitide
	name = "Hebitide"

/datum/chemical_reaction/hebitide
	results = list(/datum/reagent/mixer/hebitide = 3)
	required_reagents = list(/datum/reagent/diethylamine = 1, /datum/reagent/lye = 1, /datum/reagent/acetone = 1)

/datum/reagent/mixer/uhebitide
	name = "Unstable Hebitide"

/datum/chemical_reaction/uhebitide
	results = list(/datum/reagent/mixer/uhebitide = 2)
	required_reagents = list(/datum/reagent/mixer/hebitide = 1, /datum/reagent/impedrezene = 1)

/datum/reagent/mixer/mhebitide
	name = "Mutated Hebitide"

/datum/chemical_reaction/mhebitide
	results = list(/datum/reagent/mixer/mhebitide = 2)
	required_reagents = list(/datum/reagent/mixer/hebitide = 1, /datum/reagent/blood = 1)

//Table 3 Chems


/datum/reagent/mixer/selenide
	name = "Selenide"

/datum/chemical_reaction/selenide
	results = list(/datum/reagent/mixer/selenide = 2)
	required_reagents = list(/datum/reagent/toxin/cyanide = 1, /datum/reagent/ash = 1)


/datum/reagent/mixer/helioside
	name = "Selenic Helioside"

/datum/chemical_reaction/helioside
	results = list(/datum/reagent/mixer/helioside = 2)
	required_reagents = list(/datum/reagent/mixer/selenide = 1, /datum/reagent/acetone = 1)



/datum/reagent/mixer/kelaide
	name = "Kelaide"

/datum/chemical_reaction/kelaide
	results = list(/datum/reagent/mixer/kelaide = 3)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/drug/methamphetamine = 1, /datum/reagent/phenol = 1)

/datum/reagent/mixer/proteoside
	name = "Kelaic Proteoside"

/datum/chemical_reaction/proteoside
	results = list(/datum/reagent/mixer/proteoside = 2)
	required_reagents = list(/datum/reagent/mixer/kelaide = 1, /datum/reagent/copper = 1)

/datum/reagent/mixer/meteoside
	name = "Kelaic Meteoside"

/datum/chemical_reaction/meteoside
	results = list(/datum/reagent/mixer/meteoside = 2)
	required_reagents = list(/datum/reagent/mixer/kelaide = 1, /datum/reagent/toxin/cyanide = 1)

/datum/reagent/mixer/hadronide
	name = "Meteoic Hadronide"

/datum/chemical_reaction/hadronide
	results = list(/datum/reagent/mixer/hadronide = 2)
	required_reagents = list(/datum/reagent/mixer/meteoside = 1, /datum/reagent/copper = 1)



/datum/reagent/mixer/etheride
	name = "Etheride"

/datum/chemical_reaction/etheride
	results = list(/datum/reagent/mixer/etheride = 2)
	required_reagents = list(/datum/reagent/medicine/higadrite = 1, /datum/reagent/pentaerythritol = 1)

/datum/reagent/mixer/etherideii
	name = "Etheride II"

/datum/chemical_reaction/etherideii
	results = list(/datum/reagent/mixer/etherideii = 2)
	required_reagents = list(/datum/reagent/mixer/etheride = 1, /datum/reagent/oxygen = 1)

/datum/reagent/mixer/etherideiii
	name = "Etheride III"

/datum/chemical_reaction/etherideiii
	results = list(/datum/reagent/mixer/etherideiii = 2)
	required_reagents = list(/datum/reagent/mixer/etherideii = 1, /datum/reagent/mercury = 1)

/datum/reagent/mixer/etherideiv
	name = "Etheride IV"

/datum/chemical_reaction/etherideiv
	results = list(/datum/reagent/mixer/etherideiv = 2)
	required_reagents = list(/datum/reagent/mixer/etherideiii = 1, /datum/reagent/silicon = 1)

/datum/reagent/mixer/etheridev
	name = "Etheride V"

/datum/chemical_reaction/etheridev
	results = list(/datum/reagent/mixer/etheridev = 2)
	required_reagents = list(/datum/reagent/mixer/etherideiv = 1, /datum/reagent/iron = 1)
