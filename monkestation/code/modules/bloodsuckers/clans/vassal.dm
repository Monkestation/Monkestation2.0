/**
 * Vassal Clan
 *
 * Automatically assigned to Vassals who become Bloodsuckers mid-round.
 * We can't make vassals of our own.
 */
/datum/bloodsucker_clan/vassal
	name = CLAN_VASSAL
	description = "As a Vassal, you are too young to enter a Clan or make thralls of your own, though you may still rank up by drinking the blood of others.\n\
		Continue to help your Master advance in their aspirations."
	joinable_clan = FALSE
	display_in_archive = FALSE
	blood_drink_type = BLOODSUCKER_DRINK_SNOBBY //You drink the same as your Master.

/datum/bloodsucker_clan/vassal/give_starting_clan_powers()
	for(var/datum/action/cooldown/bloodsucker/power as anything in bloodsuckerdatum.all_bloodsucker_powers)
		if (locate(power) in bloodsuckerdatum.powers)
			continue
		if((initial(power.purchase_flags) & BLOODSUCKER_CAN_BUY))
			bloodsuckerdatum.BuyPower(new power)

/datum/bloodsucker_clan/vassal/interact_with_vassal(datum/antagonist/bloodsucker/source, datum/antagonist/vassal/favorite/vassaldatum)
	return FALSE
