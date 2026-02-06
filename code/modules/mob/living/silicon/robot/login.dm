
/mob/living/silicon/robot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	if(pending_model)
		model.transform_to(pending_model, FALSE)
		pending_model = null
	regenerate_icons()
	show_laws(0)
