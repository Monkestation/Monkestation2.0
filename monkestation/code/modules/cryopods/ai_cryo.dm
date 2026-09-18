/mob/living/silicon/ai/verb/ai_cryo()
	set name = "AI Cryogenic Stasis"
	set desc = "Puts the current AI personality into cryogenic stasis, freeing the space for another."
	set category = "AI Commands"

	if(incapacitated())
		return
	switch(alert("Would you like to enter cryo? This will ghost you. Remember to AHELP before cryoing out of important roles, even with no admins online.",,"Yes.","No."))
		if("Yes.")
			log_silicon("[key_name(src)] entered cryogenic storage.")
			log_admin("[key_name(src)] entered AI cryogenic storage.")
			message_admins("[key_name_admin(src)] has entered cryogenic storage as an AI.")
			src.ghostize(FALSE)
			minor_announce("[src] has been uploaded to AI cryogenic storage.", "AI Cryogenic Oversight")
			if(src.mind)
				//Handle job slot/tater cleanup.
				if(src.mind.assigned_role.title == JOB_AI)
					SSjob.FreeRole(JOB_AI)
			src.mind.special_role = null
			qdel(src)
		else
			return
