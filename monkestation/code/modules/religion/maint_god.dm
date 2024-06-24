/datum/religion_sect/maintenance
    rites_list = list(/datum/religion_rites/maint_adaptation, /datum/religion_rites/adapted_eyes, /datum/religion_rites/adapted_food, /datum/religion_rites/ritual_totem, /datum/religion_rites/weapon_granter)

/datum/religion_rites/weapon_granter
	name = "Maintenance Knowledge"
	desc = "Creates a tome teaching you how to make an improved improvised weapon."
	favor_cost = 100 //You still have to make the weapon afterwards, might want to change this though.
	invoke_msg = "Grant me your ingenuity!"
	ritual_length = 5 SECONDS

/datum/religion_rites/weapon_granter/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
		/obj/item/book/granter/crafting_recipe/maint_gun/pipegun_prime,
		/obj/item/book/granter/crafting_recipe/trash_cannon,
		/obj/item/book/granter/crafting_recipe/maint_gun/laser_musket_prime,
		/obj/item/book/granter/crafting_recipe/maint_gun/smoothbore_disabler_prime,
	)

	new blessing(altar_turf)
	return TRUE
