/datum/smite/choke_on_this
	name = "Choke on this!"

/datum/smite/choke_on_this/configure(client/user)
	to_paper = tgui_input_text(user, "What words do you want them to choke on?", "Admins stink!", max_length = 250, multiline = true)

/datum/smite/choke_on_this/effect(client/user, mob/living/target)
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target

	target.AddComponent(/datum/component/choke/smite, atom/movable/choke_on, flaming = TRUE, vomit_delay = -1)
