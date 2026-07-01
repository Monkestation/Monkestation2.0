/// To store all the different cyborg models, instead of creating that for each cyborg.
GLOBAL_LIST_EMPTY(cyborg_model_list)
/// To store all of the different base cyborg model icons, instead of creating them every time we need to display a radial menu.
GLOBAL_LIST_EMPTY(cyborg_base_models_icon_list)

/// Initializes the global list for what cyborg models that are available for selection and their model icons for radial wheel purposes.
/proc/initialize_cyborg_model_lists()
	if(!length(GLOB.cyborg_model_list))
		var/valid_cyborg_models = list(
			"Engineering" = /datum/robot_model/engineering,
			"Medical" = /datum/robot_model/medical,
			"Cargo" = /datum/robot_model/cargo,
			"Miner" = /datum/robot_model/miner,
			"Janitor" = /datum/robot_model/janitor,
			"Service" = /datum/robot_model/service,
			"Science" = /datum/robot_model/science,
			"Standard" = /datum/robot_model/standard,
		)
		if(!CONFIG_GET(flag/disable_peaceborg))
			valid_cyborg_models["Peacekeeper"] = /datum/robot_model/peacekeeper
		if(!CONFIG_GET(flag/disable_secborg))
			valid_cyborg_models["Security"] = /datum/robot_model/security
		GLOB.cyborg_model_list = valid_cyborg_models
	if(!length(GLOB.cyborg_base_models_icon_list))
		var/valid_base_models = list()
		for(var/option in GLOB.cyborg_model_list)
			var/datum/robot_model/model = GLOB.cyborg_model_list[option]
			var/datum/robot_skin/skin = model.default_skin
			valid_base_models[option] = image(icon = skin.icon, icon_state = skin.icon_state)
		GLOB.cyborg_base_models_icon_list = valid_base_models

#define CYBORG_ICON_CARGO 'monkestation/code/modules/cargoborg/icons/robots_cargo.dmi'

/// Module is compatible with Cargo Cyborg model
#define BORG_MODEL_CARGO (BORG_MODEL_ENGINEERING<<1)
#define RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_CARGO "/Cargo Cyborgs"
