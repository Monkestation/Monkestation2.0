
/datum/cult_tattoo/memorize
	name = TATTOO_MEMORIZE//Arcane Dimension
	desc = "Allows you to hide a tome into thin air, and pull it out whenever you want."
	icon_state = "memorize"
	tier = 2

/datum/cult_tattoo/memorize/getTattoo(mob/M)
	..()
	if (IS_CULTIST(M))
		var/datum/action/cooldown/spell/cult/arcane_dimension/new_spell = new
		new_spell.Grant(M)
