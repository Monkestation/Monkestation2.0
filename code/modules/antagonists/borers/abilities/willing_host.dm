/datum/action/cooldown/borer/willing_host
	name = "Willing Host"
	cooldown_time = 2 MINUTES
	button_icon_state = "willing"
	chemical_cost = 150
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Asks your host if they accept your existance inside of them\n\
	If the host agrees, they'll become a more suitable environment to your needs and you will progress one of your objectives.\n\
	With enough willing hosts will make your evolution and chemical points accumulate quicker.\n\
	"

/datum/action/cooldown/borer/willing_host/IsAvailable(feedback)
	. = ..()
	if(!.)
		return

	var/mob/living/basic/cortical_borer/user = owner
	if(HAS_MIND_TRAIT(user.human_host, TRAIT_WILLING_HOST))
		if(feedback)
			owner.balloon_alert(owner, "host already willing")
		return FALSE

/datum/action/cooldown/borer/willing_host/check_conditions()
	. = ..()
	if(.)
		return

	var/mob/living/basic/cortical_borer/user = owner
	if(!user.human_host.mind) // Consent requires a certain amount of intelligence, that they dont have.
		owner.balloon_alert(owner, "host not willing!")
		return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/action/cooldown/borer/willing_host/Activate(mob/living/basic/cortical_borer/user)
	user.chemical_storage -= chemical_cost
	owner.balloon_alert(owner, "asking host...")
	var/mob/living/carbon/host = user.human_host
	var/host_choice = tgui_input_list(host, "Do you accept to be a willing host?", "Willing Host Request", list("Yes", "No"))
	if(!IsAvailable(TRUE) || check_conditions() || user.human_host != host)
		return

	if(host_choice != "Yes")
		owner.balloon_alert(owner, "host not willing!")
		return ..()

	owner.balloon_alert(owner, "host willing!")
	to_chat(host, span_notice("You have accepted being a willing host!"))
	ADD_TRAIT(host.mind, TRAIT_WILLING_HOST, owner.tag)
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	var/datum/antagonist/cortical_borer/antag = owner.mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(antag)
		var/datum/objective/borer/willing_hosts/objective = locate() in antag.objectives
		if(objective)
			objective.minds += host.mind
			objective.check_completion()

	host.add_mood_event("borer", /datum/mood_event/willing_borer) //If the host is being asked then they have a worm in their ear. The rest is done on insert/exit of the organ.
	return ..()
