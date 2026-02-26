/datum/asset/spritesheet_batched/cassettes
	name = "cassettes"

/datum/asset/spritesheet_batched/cassettes/create_spritesheets()
	for(var/_name, icon_state in GLOB.cassette_icons)
		var/id = sanitize_css_class_name("[icon_state]")
		var/datum/universal_icon/icon = uni_icon(/obj/item/cassette_tape::icon, icon_state)
		icon.crop(10, 11, 23, 21)
		insert_icon(id, icon)
