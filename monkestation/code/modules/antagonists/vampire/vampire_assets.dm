/datum/asset/simple/vampire_icons

/datum/asset/simple/vampire_icons/register()
	for(var/datum/vampire_clan/clan as anything in typesof(/datum/vampire_clan))
		add_vampire_icon(initial(clan.icon), initial(clan.icon_state))

	for(var/datum/action/cooldown/vampire/power as anything in subtypesof(/datum/action/cooldown/vampire))
		add_vampire_icon(initial(power.button_icon), initial(power.button_icon_state))

	return ..()

/datum/asset/simple/vampire_icons/proc/add_vampire_icon(icon, icon_state)
	assets[SANITIZE_FILENAME("vampire.[icon_state].png")] = icon(icon, icon_state)
