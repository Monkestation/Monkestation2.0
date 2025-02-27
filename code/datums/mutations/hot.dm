/datum/mutation/human/cryokinesis/pyrokinesis
	name = "Pyrokinesis"
	desc = "Draws positive energy from the surroundings to heat surrounding temperatures at subject's will."
	text_gain_indication = span_notice("Your hand feels hot!")
	locked = TRUE
	power_path = /datum/action/cooldown/spell/pointed/projectile/cryo/pyro

/datum/action/cooldown/spell/pointed/projectile/cryo/pyro
	name = "Pyrobeam"
	desc = "This power fires a heated bolt at a target."
	button_icon_state = "firebeam"
	base_icon_state = "firebeam"
	cooldown_time = 30 SECONDS

	active_msg = "You focus your pyrokinesis!"
	deactive_msg = "You cool down."
	projectile_type = /obj/projectile/temp/pyro
