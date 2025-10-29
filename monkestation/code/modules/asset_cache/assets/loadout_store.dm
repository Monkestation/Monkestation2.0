/datum/asset/spritesheet_batched/loadout_store
	name = "loadout_store"

/datum/asset/spritesheet_batched/loadout_store/create_spritesheets()
	var/list/id_list = list()
	for(var/datum/store_item/store_item as anything in subtypesof(/datum/store_item))
		if(!store_item::name || !store_item::item_path)
			continue
		var/obj/item_type = store_item::item_path
		if(!should_generate_icon(item_type))
			continue
		var/id = sanitize_css_class_name("[item_type]")
		if(id_list[id])
			continue
		insert_icon(id, gags_to_universal_icon(item_type))
		id_list[id] = TRUE

/datum/asset/spritesheet_batched/loadout_store/proc/should_generate_icon(obj/item/item)
	if(item::icon_preview && item::icon_state_preview)
		return FALSE
	if(item::greyscale_config && item::greyscale_colors)
		return TRUE
	return FALSE
