/// To store all the different cyborg models, instead of creating that for each cyborg.
GLOBAL_LIST_INIT(cyborg_model_list, initialize_cyborg_model_list())
/// To store all of the different base cyborg model icons, instead of creating them every time we need to display a radial menu.
GLOBAL_LIST_INIT(cyborg_base_models_icon_list, initialize_cyborg_base_models_icon_list())

/proc/initialize_cyborg_model_list()
	var/valid_cyborg_models = list(
		"Engineering" = /obj/item/robot_model/engineering,
		"Medical" = /obj/item/robot_model/medical,
		"Cargo" = /obj/item/robot_model/cargo, //monkestation edit
		"Miner" = /obj/item/robot_model/miner,
		"Janitor" = /obj/item/robot_model/janitor,
		"Service" = /obj/item/robot_model/service,
		"Standard" = /obj/item/robot_model/standard,
	)
	if(!CONFIG_GET(flag/disable_peaceborg))
		valid_cyborg_models["Peacekeeper"] = /obj/item/robot_model/peacekeeper
	if(!CONFIG_GET(flag/disable_secborg))
		valid_cyborg_models["Security"] = /obj/item/robot_model/security
	return valid_cyborg_models

/proc/initialize_cyborg_base_models_icon_list()
	var/valid_base_models = list()
	for(var/option in GLOB.cyborg_model_list)
		var/obj/item/robot_model/model = GLOB.cyborg_model_list[option]
		var/model_icon = initial(model.cyborg_base_icon)
		valid_base_models[option] = image(icon = 'monkestation/icons/mob/robots.dmi', icon_state = model_icon)
	return valid_base_models

#define CYBORG_ICON_CARGO 'monkestation/code/modules/cargoborg/icons/robots_cargo.dmi'

/// Module is compatible with Cargo Cyborg model
#define BORG_MODEL_CARGO (BORG_MODEL_ENGINEERING<<1)
#define RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_CARGO "/Cargo Cyborgs"
