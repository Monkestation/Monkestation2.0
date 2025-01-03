/**
 * Gives vampires the ability to choose a clan if they aren't already in one.
 * The arg gives control over the clan selection to whatever mob you put there.
 * Uses a radial menu over the player's body, even when an admin is setting it.
 */
/datum/antagonist/vampire/proc/assign_clan(mob/person_selecting)
	if(clan)
		return
	person_selecting ||= owner.current

	var/list/options = list()
	var/list/radial_display = list()

	for(var/datum/vampire_clan/clan as anything in subtypesof(/datum/vampire_clan))
		var/clan_name = clan::name
		options[clan_name] = clan
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = clan::icon, icon_state = clan::icon_state)
		option.info = "[clan_name] - [span_boldnotice(clan::desc)]"
		radial_display[clan_name] = option

	var/chosen_clan = show_radial_menu(person_selecting, owner.current, radial_display)
	chosen_clan = options[chosen_clan]

	if(QDELETED(src) || QDELETED(owner.current))
		return FALSE
	if(!chosen_clan)
		to_chat(person_selecting, span_announce("You choose to remain ignorant, for now."))
		return

	clan = new chosen_clan(src)

/datum/antagonist/vampire/proc/remove_clan()
	QDEL_NULL(clan)
	to_chat(owner.current, span_announce("You have been forced out of your clan! You can re-enter one by regular means."))

/datum/antagonist/vampire/proc/admin_set_clan(mob/admin)
	assign_clan(admin)
