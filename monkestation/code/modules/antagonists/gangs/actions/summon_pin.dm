/datum/action/cooldown/summon_gang_pin
	name = "Summon Gang Pin"
	desc = "Summon a pin to show affiliation to your gang."
	button_icon = 'icons/obj/clothing/accessories.dmi'
	button_icon_state = "anti_sec"
	check_flags = AB_CHECK_HANDS_BLOCKED
	cooldown_time = 5 SECONDS

/datum/action/cooldown/summon_gang_pin/Activate()
	if(!IsAvailable() || !owner)
		return

	var/obj/item/created = new /obj/item/clothing/accessory/gang_pin(owner.drop_location())
	owner.put_in_hands(created)
	owner.balloon_alert(owner, "summoned a [created]")
	StartCooldown()
