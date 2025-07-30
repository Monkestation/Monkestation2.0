ADMIN_VERB_VISIBILITY(manipulate_organs, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(manipulate_organs, R_DEBUG, FALSE, "Manipulate Organs", "Manipulate the organs of a living carbon.", ADMIN_CATEGORY_DEBUG, mob/living/carbon/carbon_victim in world)
	var/operation = tgui_input_list(user, "Select organ operation", "Organ Manipulation", list("add organ", "add implant", "drop organ/implant", "remove organ/implant"))
	if (isnull(operation))
		return

	var/list/organs = list()
	switch(operation)
		if("add organ")
			for(var/path in subtypesof(/obj/item/organ))
				var/dat = replacetext("[path]", "/obj/item/organ/", ":")
				organs[dat] = path

			var/obj/item/organ/organ = tgui_input_list(user, "Select organ type", "Organ Manipulation", organs)
			if(isnull(organ))
				return
			if(isnull(organs[organ]))
				return
			organ = organs[organ]
			organ = new organ
			organ.Insert(carbon_victim)
			log_admin("[key_name(user)] has added organ [organ.type] to [key_name(carbon_victim)]")
			message_admins("[key_name_admin(user)] has added organ [organ.type] to [ADMIN_LOOKUPFLW(carbon_victim)]")

		if("add implant")
			for(var/path in subtypesof(/obj/item/implant))
				var/dat = replacetext("[path]", "/obj/item/implant/", ":")
				organs[dat] = path

			var/obj/item/implant/organ = tgui_input_list(user, "Select implant type", "Organ Manipulation", organs)
			if(isnull(organ))
				return
			if(isnull(organs[organ]))
				return
			organ = organs[organ]
			organ = new organ
			organ.implant(carbon_victim)
			log_admin("[key_name(user)] has added implant [organ.type] to [key_name(carbon_victim)]")
			message_admins("[key_name_admin(user)] has added implant [organ.type] to [ADMIN_LOOKUPFLW(carbon_victim)]")

		if("drop organ/implant", "remove organ/implant")
			for(var/obj/item/organ/user_organs as anything in carbon_victim.organs)
				organs["[user_organs.name] ([user_organs.type])"] = user_organs

			for(var/obj/item/implant/user_implants as anything in carbon_victim.implants)
				organs["[user_implants.name] ([user_implants.type])"] = user_implants

			var/obj/item/organ = tgui_input_list(user, "Select organ/implant", "Organ Manipulation", organs)
			if(isnull(organ))
				return
			if(isnull(organs[organ]))
				return
			organ = organs[organ]
			var/obj/item/organ/O
			var/obj/item/implant/I

			log_admin("[key_name(user)] has removed [organ.type] from [key_name(carbon_victim)]")
			message_admins("[key_name_admin(user)] has removed [organ.type] from [ADMIN_LOOKUPFLW(carbon_victim)]")

			if(isorgan(organ))
				O = organ
				O.Remove(carbon_victim)
			else
				I = organ
				I.removed(carbon_victim)

			organ.forceMove(get_turf(carbon_victim))

			if(operation == "remove organ/implant")
				qdel(organ)
			else if(I) // Put the implant in case.
				var/obj/item/implantcase/case = new(get_turf(carbon_victim))
				case.imp = I
				I.forceMove(case)
				case.update_appearance()
