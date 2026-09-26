/datum/bloodsucker_clan/tremere
	name = CLAN_TREMERE
	description = "The Tremere Clan is extremely weak to True Faith, and will burn when entering areas considered such, like the Chapel. \n\
		Additionally, a whole new moveset is learned, built on Blood magic rather than Blood abilities, which are upgraded overtime. \n\
		More ranks can be gained by Vassalizing crewmembers. \n\
		The Favorite Vassal gains the Batform spell, being able to morph themselves at will."
	clan_objective = /datum/objective/bloodsucker/tremere_power
	join_icon_state = "tremere"
	join_description = "You will burn if you enter the Chapel, lose all default powers, \
		but gain special Blood Magic instead, and gain ranks by Vassalizing crew."

/datum/bloodsucker_clan/tremere/give_starting_clan_powers()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if((initial(power.purchase_flags) & TREMERE_CAN_BUY) && initial(power.level_current) == 1)
			bloodsuckerdatum.BuyPower(new power)

/datum/bloodsucker_clan/tremere/Destroy(force)
	for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			bloodsuckerdatum.RemovePower(power)
	return ..()

/datum/bloodsucker_clan/tremere/handle_clan_life(datum/antagonist/bloodsucker/source)
	. = ..()
	var/area/current_area = get_area(bloodsuckerdatum.owner.current)
	if(istype(current_area, /area/station/service/chapel))
		to_chat(bloodsuckerdatum.owner.current, span_warning("You don't belong in holy areas! The Faith burns you!"))
		bloodsuckerdatum.owner.current.adjustFireLoss(10)
		bloodsuckerdatum.owner.current.adjust_fire_stacks(2)
		bloodsuckerdatum.owner.current.ignite_mob()

/datum/bloodsucker_clan/tremere/on_favorite_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/vassaldatum)
	var/datum/action/cooldown/spell/shapeshift/bat/batform = new(vassaldatum.owner || vassaldatum.owner.current)
	batform.Grant(vassaldatum.owner.current)

/datum/bloodsucker_clan/tremere/on_vassal_made(datum/antagonist/bloodsucker/source, mob/living/user, mob/living/target)
	. = ..()
	to_chat(bloodsuckerdatum.owner.current, span_danger("You have now gained an additional Rank to spend!"))
	bloodsuckerdatum.bloodsucker_level_unspent++
