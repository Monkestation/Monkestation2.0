/datum/smite/choke_on_this
	name = "Choke on this!"
	var/to_paper = null

/datum/smite/choke_on_this/configure(client/user)
	to_paper = tgui_input_text(user, "What words do you want them to choke on?", "Admins stink!", max_length = 250, multiline = TRUE)

/datum/smite/choke_on_this/effect(client/user, mob/living/target)
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	var/obj/item/paper/chokepaper = new
	chokepaper.add_raw_text(to_paper)
	target.AddComponent(/datum/status_effect/choke, chokepaper, flaming = TRUE, vomit_delay = -1)
