#define FOCUS_COST 5

/datum/action/cooldown/borer/learn_focus
	name = "Learn Focus"
	button_icon_state = "getfocus"
	requires_host = TRUE
	sugar_restricted = TRUE
	stat_evo_points = 5
	ability_explanation = "\
	Lets you evolve strong passive modifiers into the hosts you inhabit\n\
	Your focuses will follow you when you leave your host\n\
	Head - Evolves the hosts eyes to be resistant against bright lights, see in the dark and understanding of the airlock wires. \n\
	Chest - Removes the need for a host to breathe, eat, or need a heart to live.\n\
	Arms - Insulates the host from any shocks, while improving their ability to carry bodies and build faster.\n\
	Legs - Increases the host's natural stride, letting them move faster.\n\
	"
	var/list/learnable_focuses = list()

/datum/action/cooldown/borer/learn_focus/New(Target, original)
	. = ..()
	for(var/datum/borer_focus/focus_path as anything in subtypesof(/datum/borer_focus))
		learnable_focuses += new focus_path

/datum/action/cooldown/borer/learn_focus/Destroy(force)
	QDEL_LIST(learnable_focuses)
	return ..()

/datum/action/cooldown/borer/learn_focus/Activate(mob/living/basic/cortical_borer/user)
	var/list/fancy_list = list()
	for(var/datum/borer_focus/focus as anything in learnable_focuses)
		fancy_list[focus.name] = focus

	var/focus_choice = tgui_input_list(user, "Learn a focus!", "Focus Choice", fancy_list)
	if(!IsAvailable(TRUE) || check_conditions())
		return

	if(!focus_choice)
		owner.balloon_alert(owner, "focus not chosen")
		return

	var/datum/borer_focus/picked_focus = fancy_list[focus_choice]
	if(!picked_focus)
		return

	user.stat_evolution -= FOCUS_COST
	learnable_focuses -= picked_focus
	user.body_focuses += picked_focus
	picked_focus.on_add(user.human_host, owner)
	owner.balloon_alert(owner, "focus learned successfully")
	. = ..()
	if(!length(learnable_focuses)) // Our job is done
		qdel(src)

#undef FOCUS_COST
