//this is our base mineral sample we grab this, then using weights from here we create material stats and then bash names together a few times
/datum/mineral_sample_datum
	var/name = "???"
	var/list/base_traits = list()
	var/weight = 10
	var/icon_state = "miracle"

/datum/mineral_sample_datum/miraclium
	name = "miraclium"
	base_traits = list(/datum/material_trait/rainbow,/datum/material_trait/shiny)
	weight = 4
	icon_state = "miracle"

/datum/mineral_sample_datum/gorp
	name = "gorp"
	icon_state = "uqil"

/datum/mineral_sample_datum/glippy
	name = "glippy"
	base_traits = list(/datum/material_trait/holy)
	icon_state = "martian"

/datum/mineral_sample_datum/starstone
	name = "starstone"
	base_traits = list(
		/datum/material_trait/chemical_injector,
		/datum.material_trait/weak_weapon,
		/datum/material_trait/stamina_draining
	)
	weight = 1
	icon_state = "starstone"

/datum/mineral_sample_datum/stunnium
	name = "stunnium"
	base_traits = list(
		/datum/material_trait/stamina_draining,
		/datum/material_trait/shiny,
		/datum/material_trait/stunning
	)
	weight = 1
	icon_state = "molitz"

/datum/mineral_sample_datum/sploop
	name = "sploop"
	icon_state = "fibrilith"
	base_traits = list(/datum/material_trait/firestorm_bane)

/datum/mineral_sample_datum/bingus
	name = "bingus"
	base_traits = list(/datum/material_trait/honk_blessed)
	icon_state = "cobryl"

/datum/mineral_sample_datum/scarium
	name = "scarium"
	base_traits = list(/datum/material_trait/radioactive)
	weight = 3
	icon_state = "bohrum"
