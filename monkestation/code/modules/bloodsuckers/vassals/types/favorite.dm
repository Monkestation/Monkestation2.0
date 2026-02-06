/**
 * Favorite Vassal
 *
 * Gets some cool abilities depending on the Clan.
 */
/datum/antagonist/vassal/favorite
	name = "\improper Favorite Vassal"
	show_in_antagpanel = FALSE
	antag_hud_name = "vassal6"
	special_type = FAVORITE_VASSAL
	vassal_description = "The Favorite Vassal gets unique abilities over other Vassals depending on your Clan. If part of Ventrue, this is the Vassal you will rank up."

	///Bloodsucker levels, but for Vassals, used by Ventrue.
	var/vassal_level

/datum/antagonist/vassal/favorite/on_gain()
	. = ..()
	SEND_SIGNAL(master, COMSIG_BLOODSUCKER_MAKE_FAVORITE, src)

///Transfers the vassals powers to the new bloodsucker datum
/datum/antagonist/vassal/favorite/proc/transfer_vassal_powers(datum/antagonist/bloodsucker/vassal_bloodsucker_datum)
	for(var/datum/action/cooldown/bloodsucker/bloodsucker_power as anything in powers)
		RemovePower(bloodsucker_power)
		vassal_bloodsucker_datum.BuyPower(bloodsucker_power)
		bloodsucker_power.bloodsuckerdatum_power = vassal_bloodsucker_datum
