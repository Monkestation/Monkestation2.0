/datum/asset/json/loadout_items
	name = "loadout_items"
	early = TRUE

/datum/asset/json/loadout_items/generate()
	. = list()
	. += list(list("name" = "Belt", "title" = "Belt Slot Items", "contents" = list_to_data(GLOB.loadout_belts)))
	. += list(list("name" = "Ears", "title" = "Ear Slot Items", "contents" = list_to_data(GLOB.loadout_ears)))
	. += list(list("name" = "Glasses", "title" = "Glasses Slot Items", "contents" = list_to_data(GLOB.loadout_glasses)))
	. += list(list("name" = "Gloves", "title" = "Glove Slot Items", "contents" = list_to_data(GLOB.loadout_gloves)))
	. += list(list("name" = "Head", "title" = "Head Slot Items", "contents" = list_to_data(GLOB.loadout_helmets)))
	. += list(list("name" = "Mask", "title" = "Mask Slot Items", "contents" = list_to_data(GLOB.loadout_masks)))
	. += list(list("name" = "Neck", "title" = "Neck Slot Items", "contents" = list_to_data(GLOB.loadout_necks)))
	. += list(list("name" = "Shoes", "title" = "Shoe Slot Items", "contents" = list_to_data(GLOB.loadout_shoes)))
	. += list(list("name" = "Suit", "title" = "Suit Slot Items", "contents" = list_to_data(GLOB.loadout_exosuits)))
	. += list(list("name" = "Jumpsuit", "title" = "Uniform Slot Items", "contents" = list_to_data(GLOB.loadout_jumpsuits)))
	. += list(list("name" = "Formal", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.loadout_undersuits)))
	. += list(list("name" = "Misc. Under", "title" = "Uniform Slot Items (cont)", "contents" = list_to_data(GLOB.loadout_miscunders)))
	. += list(list("name" = "Accessory", "title" = "Uniform Accessory Slot Items", "contents" = list_to_data(GLOB.loadout_accessory)))
	. += list(list("name" = "Inhand", "title" = "In-hand Items", "contents" = list_to_data(GLOB.loadout_inhand_items)))
	. += list(list("name" = "Toys", "title" = "Toys! ([MAX_ALLOWED_MISC_ITEMS] max)", "contents" = list_to_data(GLOB.loadout_toys)))
	. += list(list("name" = "Plushies", "title" = "Adorable little plushies! ([MAX_ALLOWED_PLUSHIES] max)", "contents" = list_to_data(GLOB.loadout_plushies)))
	. += list(list("name" = "Other", "title" = "Backpack Items ([MAX_ALLOWED_MISC_ITEMS] max)", "contents" = list_to_data(GLOB.loadout_pocket_items)))
	. += list(list("name" = "Effects", "title" = "Unique Effects", "contents" = list_to_data(GLOB.loadout_effects)))

/datum/asset/json/loadout_items/proc/list_to_data(list/list_of_datums)
	. = list()
	for(var/datum/loadout_item/item as anything in list_of_datums)
		var/atom/loadout_atom = item.item_path
		var/list/formatted_item = list()
		formatted_item["name"] = item.name
		formatted_item["path"] = item.item_path
		formatted_item["is_greyscale"] = !!(loadout_atom::greyscale_config && loadout_atom::greyscale_colors && (loadout_atom::flags_1 & IS_PLAYER_COLORABLE_1))
		formatted_item["is_renamable"] = item.can_be_named
		formatted_item["is_job_restricted"] = !isnull(item.restricted_roles)
		formatted_item["is_admin_only"] = item.admin_only
		formatted_item["is_donator_only"] = !isnull(item.donator_only)
		formatted_item["is_ckey_whitelisted"] = !isnull(item.ckeywhitelist)
		formatted_item["required_season"] = item.required_season
		formatted_item["requires_purchase"] = item.requires_purchase
		if(LAZYLEN(item.additional_tooltip_contents))
			formatted_item["tooltip_text"] = jointext(item.additional_tooltip_contents, "\n")

		. += list(formatted_item)
