/datum/asset/json/loadout_store
	name = "loadout_store"
	early = TRUE

/datum/asset/json/loadout_store/generate()
	. = list()
	. += list(list("name" = "Belt", "title" = "Belt Slot Items", "contents" = list_to_data(GLOB.store_belts)))
	. += list(list("name" = "Ears", "title" = "Ear Slot Items", "contents" = list_to_data(GLOB.store_ears)))
	. += list(list("name" = "Glasses", "title" = "Glasses Slot Items", "contents" = list_to_data(GLOB.store_glasses)))
	. += list(list("name" = "Gloves", "title" = "Glove Slot Items", "contents" = list_to_data(GLOB.store_gloves)))
	. += list(list("name" = "Head", "title" = "Head Slot Items", "contents" = list_to_data(GLOB.store_head)))
	. += list(list("name" = "Mask", "title" = "Mask Slot Items", "contents" = list_to_data(GLOB.store_masks)))
	. += list(list("name" = "Neck", "title" = "Neck Slot Items", "contents" = list_to_data(GLOB.store_neck)))
	. += list(list("name" = "Shoes", "title" = "Shoe Slot Items", "contents" = list_to_data(GLOB.store_shoes)))
	. += list(list("name" = "Suit", "title" = "Suit Slot Items", "contents" = list_to_data(GLOB.store_suits)))
	. += list(list("name" = "Jumpsuit", "title" = "Uniform Slot Items", "contents" = list_to_data(GLOB.store_jumpsuits)))
	. += list(list("name" = "Formal", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.store_undersuits)))
	. += list(list("name" = "Misc. Under", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.store_miscunders)))
	. += list(list("name" = "Accessory", "title" = "Uniform Accessory Slot Items", "contents" = list_to_data(GLOB.store_accessory)))
	. += list(list("name" = "Inhand", "title" = "In-hand Items", "contents" = list_to_data(GLOB.store_inhand_items)))
	. += list(list("name" = "Toys", "title" = "Toys!", "contents" = list_to_data(GLOB.store_toys)))
	. += list(list("name" = "Plushies", "title" = "Adorable little plushies!", "contents" = list_to_data(GLOB.store_plushies)))
	. += list(list("name" = "Other", "title" = "Backpack Items", "contents" = list_to_data(GLOB.store_pockets)))

/datum/asset/json/loadout_store/proc/list_to_data(list_of_datums)
	. = list()
	if(!LAZYLEN(list_of_datums))
		return
	for(var/datum/store_item/item as anything in list_of_datums)
		if(item.hidden)
			continue
		var/obj/item/item_type = item.item_path
		var/list/formatted_item = list(
			"name" = item.name,
			"path" = item.item_path,
			"cost" = item.item_cost,
			"desc" = item_type::desc,
			"job_restricted" = null,
		)
		if((item_type::icon_preview && item_type::icon_state_preview) || !(item_type::greyscale_config && item_type::greyscale_colors))
			formatted_item["icon"] = item_type::icon_preview || item_type::icon
			formatted_item["icon_state"] = item_type::icon_state_preview || item_type::icon_state
		else
			formatted_item["icon"] = sanitize_css_class_name("[item_type]")

		var/datum/loadout_item/selected = GLOB.all_loadout_datums[item_type]
		if(length(selected?.restricted_roles))
			formatted_item["job_restricted"] = jointext(selected.restricted_roles, ", ")

		. += list(formatted_item)
