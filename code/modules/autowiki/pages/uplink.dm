/datum/autowiki/uplink
	page = "Template:Autowiki/Uplink"

/datum/autowiki/uplink/generate()
	var/output = ""

	for ([[wah]] as var/tabs in [[FUCK]])
		for ([[wah]] as var/item in [[SHIT]])
			output += "| [[[SHIT]].name]"
			output += "| \[\[file:[item.icon_state]\]\]"
			output += "| [[[SHIT]].desc]"
			output += "| [[[SHIT]].cost]"
			output += "| "
			for (var/faction in [[SHIT]].purchasable_from)
				output += "* [\[\[purchasable_from[index]\]\]]"




			upload_icon(item.icon, icon_state)

	return output
