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

/datum/action/cooldown/borer/willing_host/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	if(cortical_owner.human_host.is_willing_host(cortical_owner.human_host))
		owner.balloon_alert(owner, "host already willing")
		return

	owner.balloon_alert(owner, "asking host...")
	cortical_owner.chemical_storage -= chemical_cost

	var/host_choice = tgui_input_list(cortical_owner.human_host,"Do you accept to be a willing host?", "Willing Host Request", list("Yes", "No"))
	if(host_choice != "Yes")
		owner.balloon_alert(owner, "host not willing!")
		StartCooldown()
		return

	owner.balloon_alert(owner, "host willing!")
	to_chat(cortical_owner.human_host, span_notice("You have accepted being a willing host!"))
	GLOB.willing_hosts += cortical_owner.human_host.mind
	cortical_owner.human_host.add_mood_event("borer", /datum/mood_event/has_borer) //If the host is being asked then they have a worm in their ear. The rest is done on insert/exit of the organ.
	StartCooldown()
