#define wraith_icons 'monkestation/code/modules/antagonists/wraith/icons/mob.dmi'
/datum/action/cooldown/spell/wraith/evolve
	name = "Evolve"
	desc = "Evolve into a greater form, requires 3 soul-consumed corpses."
	button_icon_state = "whisper"

	essence_cost = 150

	var/list/evolutions = list(
		"harbinger" = icon(wraith_icons, "flip_light_switches"),
		"plaguebringer" = icon(wraith_icons, "break_lightbulbs"),
		"trickster" = icon(wraith_icons, "create_smoke"),
	)

/datum/action/cooldown/spell/wraith/evolve/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/basic/wraith/true_owner = owner
	if(!istype(true_owner)) // This one we cannot infact give to humans
		return FALSE

	if(true_owner.eaten_corpses < 3)
		if(feedback)
			to_chat(owner, span_warning("You need 3 corpses to evolve!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/wraith/evolve/cast(mob/living/basic/wraith/cast_on)
	. = ..()
	to_chat(owner, span_revenwarning("Finally, you can evolve into a greater form, choose one of the 3 provided ones."))
	to_chat(owner, span_revenwarning("The Harbinger: focuses on creating swarms of allies to do the dirty work for you."))
	to_chat(owner, span_revenwarning("The Plaguebringer: focuses on debuffing and annoying the crew to the greatest extent."))
	to_chat(owner, span_revenwarning("The Trickster: focuses on confusing the crew and manipulating their senses."))

	var/choice = show_radial_menu(owner, owner, evolutions, radius = 70, tooltips = TRUE)
	cast_on.base_icon_state = choice
	var/list/datum/action/abilities_to_give = null
	switch(choice)
		if("harbinger")

		if("plaguebringer")

		if("trickster")
			abilities_to_give = list(
				/datum/action/cooldown/spell/pointed/wraith/choose_disquise,
				/datum/action/cooldown/spell/pointed/wraith/creeping_dead,
				/datum/action/cooldown/spell/pointed/wraith/hallucinate,
				/datum/action/cooldown/spell/wraith/make_poltergeist,
				/datum/action/cooldown/spell/wraith/mass_whisper,
				/datum/action/cooldown/spell/wraith/rune_trap,
				// THIS IS NOT A FINISHED LIST
			)

		else
			cast_on.essence += essence_cost
			reset_spell_cooldown()
			return

	if(isnull(abilities_to_give))
		to_chat(owner, span_warning("Failed to give abilities, inform coders. Remove this warning when all forms are finished"))
		cast_on.essence += essence_cost
		return

	for(var/ability as anything in abilities_to_give)
		var/datum/action/spell = new ability(src)
		spell.Grant(src)

	qdel(src) // Only one evolution per wraith

#undef wraith_icons
