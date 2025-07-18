/datum/smite/cluwne
	name = "Cluwnify"

/datum/smite/cluwne/effect(client/user, mob/living/target)
	. = ..()
	if(!ishuman(target))
		to_chat(user, span_warning("This must be used on a human."), confidential = TRUE)
		return
	if(target.GetComponent(/datum/component/cluwne))
		to_chat(user, span_warning("They have already been cursed."), confidential = TRUE)
		return
	var/choice = tgui_input_list(user, "How will they seek salvation?", "Select Deconversion Method", list("Never", "Death", "Divine Intervention"))
	var/deconversion_method
	switch(choice)
		if("Never")
			deconversion_method = CLUWNE_DECONVERT_NEVER
		if("Death")
			deconversion_method = CLUWNE_DECONVERT_ON_DEATH
		if("Divine Intervention")
			deconversion_method = CLUWNE_DECONVERT_ON_DIVINE_INTERVENTION

	target.AddComponent(/datum/component/cluwne, deconversion = deconversion_method)
