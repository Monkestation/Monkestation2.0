/datum/scripture/clockwork_armaments
	name = "Clockwork Armaments"
	desc = "Summon clockwork armor and weapons, to be ready for battle."
	tip = "Summon clockwork armor and weapons, to be ready for battle."
	button_icon_state = "clockwork_armor"
	power_cost = STANDARD_CELL_CHARGE * 0.25
	invocation_time = 2 SECONDS
	invocation_text = list("Through courage and hope...", "we shall protect thee!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1


/datum/scripture/clockwork_armaments/invoke_success()
	var/choice = tgui_input_list(invoker, "What weapon do you want to call upon?", "Clockwork Armaments", list("Brass Spear", "Brass Battlehammer", "Brass Sword", "Brass Bow"))

	if(!choice)
		return FALSE

	var/static/datum/outfit/clockwork_armaments/base_outfit
	if(!base_outfit)
		base_outfit = new

	var/weapon_path = /obj/item/clockwork/weapon/brass_battlehammer
	var/say_the_line = "I've gotten me mallet!"

	switch(choice)
		if("Brass Spear")
			weapon_path = /obj/item/clockwork/weapon/brass_spear
			say_the_line = "My will shall pierce my foes!"
		if("Brass Battlehammer")
			weapon_path = /obj/item/clockwork/weapon/brass_battlehammer
			say_the_line = "I've gotten me mallet!"
		if("Brass Sword")
			weapon_path = /obj/item/clockwork/weapon/brass_sword
			say_the_line = "Let us cut them to pieces!"
		if("Brass Bow")
			weapon_path = /obj/item/gun/ballistic/bow/clockwork
			say_the_line = "May my arrows strike them dead!"

	base_outfit.equip(invoker)

	invoker.put_in_hands(new weapon_path, FALSE)
	clockwork_say(invoker, text2ratvar(say_the_line), FALSE)
