/obj/item/assembly/flash/xenomorph
	name = "Hivenode Hijacker (Empty)"
	desc = "Experimental flash device with a slot for a xenomorph hive node."
	icon_state = "flash" //need CUSTOM ICON
	light_color = COLOR_PURPLE
	var/contains_node = FALSE //does NOT contain node by default

/obj/item/assembly/flash/xenomorph/attack(mob/living/M, mob/user)
	if(!try_use_flash(user))
		return FALSE

	. = TRUE
	if(isalien(M) && contains_node)
		log_combat(user, M, "brainwashed", src)
		update_icon(ALL, TRUE)
		M.mind.remove_all_antag_datums()
		var/datum/antagonist/xeno/xeno_datum = new
		var/datum/objective/custom/brainwashed_xenomorph = new
		brainwashed_xenomorph.explanation_text = "[user.name] is the Queen of the Hive. Obey and protect them."
		brainwashed_xenomorph.completed = TRUE // its just an objective for flavor less-so than for greentext
		xeno_datum.objectives += brainwashed_xenomorph
		M.mind.add_antag_datum(xeno_datum)


/obj/item/assembly/flash/xenomorph/attackby(obj/item/H, mob/living/user)
	if(istype(H, /obj/item/organ/internal/alien/hivenode)) //if its a hive node
		if(contains_node)
			to_chat(user, "The hijacker already contains a hive node")
		else
			update_icon(ALL, TRUE)
			contains_node = TRUE
			qdel(H) //GET IT OUT OF HERE
			to_chat(user, "You sucessfully insert the hive node into the hijacker")
			name = "Hivenode Hijacker (Loaded)"
			desc = "An experimental flash device used to hijack hiveminds and brainwash Xenmorphs."
	return

/obj/item/assembly/flash/xenomorph/screwdriver_act(mob/living/user, obj/item/I)
	if(contains_node)
		update_icon(ALL, TRUE)
		contains_node = FALSE //remove the node
		to_chat(user, "You sucessfully remove the hive node")
		name = "Hivenode Hijacker (Empty)"
		desc = "Experimental flash device with a slot for a xenomorph hive node."
		new /obj/item/organ/internal/alien/hivenode(user.loc)
	return
