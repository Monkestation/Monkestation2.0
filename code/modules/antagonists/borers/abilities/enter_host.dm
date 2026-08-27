//to either get inside, or out, of a host
/datum/action/cooldown/borer/choosing_host
	name = "Inhabit/Uninhabit Host"
	cooldown_time = 10 SECONDS
	button_icon_state = "host"
	ability_explanation = "\
	Using this ability we can eighter enter or exit a host.\n\
	Whilst leaving a host, they cannot have sugar within them and we require to be carefull in order to not immediatelly get squished.\n\
	Going inside of a host will usually take 6 seconds if we are not a hivelord, we must take causion for the host to not move.\n\
	Whilst going inside of a host we require the following:\n\
	- they must not have one of us within them\n\
	- they must be of compatible species\n\
	- and they must not have helmets designed against us\n\
	"
	/// What biotypes does our target need?
	var/accepted_biotypes = MOB_ORGANIC
	/// Can we enter changelings?
	var/allow_changelings = FALSE

/datum/action/cooldown/borer/choosing_host/Activate(mob/living/basic/cortical_borer/user)
	//having a host means we need to leave them
	if(user.human_host)
		if(user.host_sugar())
			if(user.human_host.stat != DEAD)
				owner.balloon_alert(owner, "cannot function with sugar in host")
				return
			// we have a host with sugar and our host is dead. Amazing fuckup
			owner.balloon_alert(owner, "struggling to leave")
			to_chat(owner, span_userdanger("We struggle to leave our host, barelly able to due to the sugar in their blood no longer moving, this will take time..."))
			StartCooldown(30 SECONDS) // stay in place now
			if(!do_after(user, 30 SECONDS, user.human_host, IGNORE_TARGET_LOC_CHANGE, hidden = TRUE))
				return

		owner.balloon_alert(owner, "detached from host")
		if(!(user.upgrade_flags & BORER_STEALTH_MODE))
			to_chat(user.human_host, span_notice("Something carefully tickles your inner ear..."))

		//log the interaction
		var/logging_text = "[key_name(user)] left [key_name(user.human_host)] at [loc_name(user.human_host)]"
		user.log_message(logging_text, LOG_GAME)
		user.human_host.log_message(logging_text, LOG_GAME)
		user.leave_host()
		return ..()

	//we dont have a host so lets inhabit one
	var/list/usable_hosts = list()
	for(var/mob/living/carbon/human/listed_human in range(1, user))
		if(!ishuman(listed_human)) // No non-human hosts
			to_chat(user, span_warning("[listed_human] is not a human!"))
			continue

		if(has_borer(listed_human)) // Cannot have multiple borers
			to_chat(user, span_warning("[listed_human] already has our sister within them!"))
			continue

		if(!(listed_human.dna.species.inherent_biotypes & accepted_biotypes)) // Hosts need to be organic
			to_chat(user, span_warning("[listed_human] has incompatible biology with us!"))
			continue

		if(!(listed_human.mob_biotypes & accepted_biotypes)) // Hosts NEED to be organic
			to_chat(user, span_warning("[listed_human] has incompatible biology with us!"))
			continue

		if(listed_human.mind && !allow_changelings) // Hosts cannot be changelings unless we specify otherwise
			var/datum/antagonist/changeling/changeling = listed_human.mind.has_antag_datum(/datum/antagonist/changeling)
			if(changeling)
				to_chat(user, span_warning("[listed_human] has incompatible biology with us!"))
				continue

		if(head_protected(listed_human) == TRUE) // Hosts cannot have bio protected headgear
			to_chat(user, span_warning("[listed_human] has too hard of a helmet to crawl inside of their ear!"))
			continue
		usable_hosts += listed_human

	// If the list of possible hosts is one, just go straight in, no choosing
	if(length(usable_hosts) == 1)
		enter_host(user, usable_hosts[1])
		return

	// If the list of possible host is more than one, allow choosing a host
	var/target = tgui_input_list(user, "Choose your host!", "Host Choice", usable_hosts)
	if(!target)
		owner.balloon_alert(owner, "no target selected")
		return

	. = ..() // Start the cooldown now, enter_host will also start one on success
	enter_host(user, target)

/datum/action/cooldown/borer/choosing_host/proc/enter_host(mob/living/basic/cortical_borer/user, mob/living/carbon/target)
	if(head_protected(target))
		owner.balloon_alert(owner, "target head too protected!")
		return
	if(has_borer(target))
		owner.balloon_alert(owner, "target already occupied")
		return
	var/boring_time = 6 SECONDS
	if(user.upgrade_flags & BORER_FAST_BORING && !(user.upgrade_flags & BORER_HIDING))
		boring_time *= 0.5

	if(!do_after(user, boring_time, target = target, hidden = TRUE))
		owner.balloon_alert(owner, "you and target must be still")
		return
	if(get_dist(target, user) > 1)
		owner.balloon_alert(owner, "target too far away")
		return
	user.human_host = target
	user.forceMove(target)
	SEND_SIGNAL(user, COMSIG_HOST_CHANGED)
	if(!(user.upgrade_flags & BORER_STEALTH_MODE))
		to_chat(target, span_notice("A chilling sensation goes down your spine..."))

	var/obj/item/organ/internal/borer_body/borer_organ = new(target)
	borer_organ.borer = owner
	borer_organ.Follow_Insert(target, ORGAN_SLOT_BRAIN) // The worm follows the brain
	user.bodytemp_heat_damage_limit = target.bodytemp_heat_damage_limit
	user.bodytemp_cold_damage_limit = target.bodytemp_cold_damage_limit

	var/turf/human_turftwo = get_turf(target)
	var/logging_text = "[key_name(user)] went into [key_name(target)] at [loc_name(human_turftwo)]"
	user.log_message(logging_text, LOG_GAME)
	target.log_message(logging_text, LOG_GAME)

	ADD_TRAIT(user, TRAIT_WEATHER_IMMUNE, "borer_in_host")
	StartCooldown()

/// Checks if the target's head is bio protected, returns true if this is the case
/datum/action/cooldown/borer/choosing_host/proc/head_protected(mob/living/carbon/human/target)
	if(isobj(target.head))
		if(target.head.get_armor_rating(BIO) >= 100)
			return TRUE
	if(isobj(target.wear_mask))
		if(target.wear_mask.get_armor_rating(BIO) >= 100)
			return TRUE
	if(isobj(target.wear_neck))
		if(target.wear_neck.get_armor_rating(BIO) >= 100)
			return TRUE
	return FALSE
