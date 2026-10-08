/datum/autowiki/uplink
	page = "Template:Autowiki/Uplink"

/datum/autowiki/uplink/generate()
	var/output = "<tabber>"

	var/list/categories = list()
	categories.len = 31

	for (var/datum/uplink_item/entry as anything in subtypesof(/datum/uplink_item))
		if(!ispath(entry.category)) continue
		if(entry.category.weight < 0) continue

		if(!categories[entry.category.weight+1])
			categories[entry.category.weight+1] = list()
		categories[entry.category.weight+1] += entry

	categories = reverseList(categories)
	var/turf/loc = locate(1,1,1)

	for (var/list/category as anything in categories)
		if(isnull(category))
			continue

		var/datum/uplink_item/temp = category[1]
		var/datum/uplink_category/cat = new temp.category (loc)
		output += "|-|[escape_value(format_text(cat.name))]={|"

		for (var/datum/uplink_item/entry as anything in category)
			if(isnull(entry.item))
				continue

			entry = new entry ()
			var/list/purchasable_keys = list()
			var/purchasable_by = ""
			if(entry.purchasable_from & UPLINK_TRAITORS) purchasable_keys += "\[\[traitors\]\]"
			if(entry.purchasable_from & UPLINK_NUKE_OPS) purchasable_keys += "\[\[nuclear operatives\]\]"
			if(entry.purchasable_from & UPLINK_CLOWN_OPS) purchasable_keys += "\[\[clown operatives\]\]"
			if(entry.purchasable_from & UPLINK_SPY) purchasable_keys += "\[\[spy missions\]\]"
			if(entry.purchasable_from & UPLINK_CONTRACTORS) purchasable_keys += "\[\[contractors\]\]"

			if(entry.restricted_roles)
				for (var/lock as anything in entry.restricted_roles)
					purchasable_keys += "\[\[[initial(lock)]\]\]"
			if(entry.restricted_species)
				for (var/lock as anything in entry.restricted_species)
					purchasable_keys += "\[\[[initial(lock)]\]\]"

			if(purchasable_keys)
				purchasable_by = purchasable_keys.Join(", ")
			else purchasable_by = "None"

			var/obj/object = entry.item
			object = new object(loc)
			var/filename = SANITIZE_FILENAME(escape_value("[length(object.icon)]_[object.icon_state]"))

			output += include_template("Autowiki/Uplink_Entry", list(
				"icon" = "autowiki-[filename].png",
				"name" = escape_value(entry.name),
				"desc" = escape_value(entry.desc),
				"cost" = entry.cost_override_string ? entry.cost_override_string : "[initial(entry.cost)] TC",
				"purchasable_by" = escape_value(purchasable_by),
				"notes" = escape_value("[entry.limited_stock!=-1 ? "Limited stock of [entry.limited_stock]. " : ""][entry.illegal_tech ? "" : "Not eligible for illegal technology. "][entry.lock_other_purchases ? "locks all item purchases<br>" : ""]")
			)) + "|-"

			upload_icon(getFlatIcon(object, no_anim = TRUE), filename)
		output += "|}"

	return output + "</tabber>"
