/mob/dead/observer
	var/appearance_backup

/mob/dead/observer/Initialize(mapload)
	. = ..()
	if(GLOB.eclipse.eclipse_start_time && !GLOB.eclipse.eclipse_finished)
		narsie_act()

/mob/dead/observer/narsie_act()
	var/prompt = tgui_alert(src, "Do you wish to become a cult ghost?", "[name]", list("Yes", "No"), timeout = 20 SECONDS)
	if(prompt == "No")
		return
	if(invisibility != 0)
		var/datum/action/cooldown/blood_doodle/doodle = new
		doodle.Grant(src)
		appearance_backup = appearance
		icon = 'monkestation/code/modules/bloody_cult/icons/mob.dmi'
		icon_state = "ghost-narsie"
		invisibility = 0
		alpha = 0
		animate(src, alpha = 127, time = 0.5 SECONDS)
		//to_chat(src, span_cult("Even as a non-corporal being, you can feel Nar-Sie's presence altering you. You are now visible to everyone.") )
		flick("rune_seer", src)
