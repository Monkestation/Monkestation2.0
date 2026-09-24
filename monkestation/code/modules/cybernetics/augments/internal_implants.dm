/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	visual = FALSE
	organ_flags = ORGAN_ROBOTIC
	var/implant_color = "#FFFFFF"
	var/implant_overlay

/obj/item/organ/internal/cyberimp/New(mob/implanted_mob = null)
	if(iscarbon(implanted_mob))
		src.Insert(implanted_mob)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "Injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/stun_amount = 200/severity
	owner.Stun(stun_amount)
	to_chat(owner, span_warning("Your body seizes up!"))


/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	icon_state = "brain_implant_antidrop"
	var/active = FALSE
	var/list/stored_items = list()
	implant_overlay = null
	implant_color = null
	slot = ORGAN_SLOT_BRAIN_ANTIDROP
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click()
	active = !active

	if(active)
		var/list/hold_list = owner.get_empty_held_indexes()
		if(LAZYLEN(hold_list) == owner.held_items.len)
			to_chat(owner, span_notice("You are not holding any items, your hands relax..."))
			active = FALSE
			return
		for(var/obj/item/held_item as anything in owner.held_items)
			if(!held_item)
				continue
			if (held_item.type in ANTI_DROP_BLACKLIST())
				to_chat(owner, span_notice("You can't seem to get a good grip on the [held_item]."))
				continue
			stored_items += held_item
			to_chat(owner, span_notice("Your [owner.get_held_index_name(owner.get_held_index_of_item(held_item))]'s grip tightens."))
			ADD_TRAIT(held_item, TRAIT_NODROP, IMPLANT_TRAIT)
			RegisterSignal(held_item, COMSIG_ITEM_DROPPED, PROC_REF(on_held_item_dropped))
	else
		release_items()
		to_chat(owner, span_notice("Your hands relax..."))


/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/range = severity ? 10 : 5
	var/atom/throw_target
	if(active)
		release_items()
	for(var/obj/item/stored_item as anything in stored_items)
		throw_target = pick(oview(range))
		stored_item.throw_at(throw_target, range, 2)
		to_chat(owner, span_warning("Your [owner.get_held_index_name(owner.get_held_index_of_item(stored_item))] spasms and throws the [stored_item.name]!"))
	stored_items = list()


/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	for(var/obj/item/stored_item as anything in stored_items)
		REMOVE_TRAIT(stored_item, TRAIT_NODROP, IMPLANT_TRAIT)
		UnregisterSignal(stored_item, COMSIG_ITEM_DROPPED)
	stored_items = list()


/obj/item/organ/internal/cyberimp/brain/anti_drop/Remove(mob/living/carbon/implant_owner, special = 0)
	if(active)
		ui_action_click()
	..()

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/on_held_item_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	REMOVE_TRAIT(source, TRAIT_NODROP, IMPLANT_TRAIT)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)
	stored_items -= source

/obj/item/organ/internal/cyberimp/brain/anti_drop/syndicate
	name = "contraband anti-drop implant"
	organ_flags = parent_type::organ_flags | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/brain/anti_stun
	name = "CNS rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	icon_state = "brain_implant_rebooter"
	implant_overlay = null
	implant_color = null
	slot = ORGAN_SLOT_BRAIN_ANTISTUN

	var/static/list/signalCache = list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_PARALYZE,
	)

	///timer before the implant activates
	var/stun_cap_amount = 1 SECONDS
	///amount of time you are resistant to stuns and knockdowns
	var/stun_resistance_time = 6 SECONDS
	COOLDOWN_DECLARE(implant_cooldown)

/obj/item/organ/internal/cyberimp/brain/anti_stun/on_remove(mob/living/carbon/implant_owner)
	. = ..()
	UnregisterSignal(implant_owner, signalCache)
	UnregisterSignal(implant_owner, COMSIG_LIVING_STAMINA_STUN)

/obj/item/organ/internal/cyberimp/brain/anti_stun/on_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignals(receiver, signalCache, PROC_REF(on_signal))
	RegisterSignal(receiver, COMSIG_LIVING_STAMINA_STUN, PROC_REF(on_stamcrit))

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/on_signal(datum/source, amount)
	SIGNAL_HANDLER

	if(!(organ_flags & ORGAN_FAILING) && amount > 0)
		addtimer(CALLBACK(src, PROC_REF(clear_stuns)), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/on_stamcrit(datum/source)
	SIGNAL_HANDLER
	if(!(organ_flags & ORGAN_FAILING))
		addtimer(CALLBACK(src, PROC_REF(clear_stuns)), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/clear_stuns()
	if(isnull(owner) || (organ_flags & ORGAN_FAILING) || !COOLDOWN_FINISHED(src, implant_cooldown))
		return

	owner.SetAllImmobility(0)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, SetAllImmobility), 0), stun_resistance_time)

	do_sparks(5, 1, owner)

	owner.add_traits(list(TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_BATON_RESISTANCE, TRAIT_STUNIMMUNE, TRAIT_CANT_STAMCRIT), REF(src))
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_IGNOREDAMAGESLOWDOWN, REF(src)), stun_resistance_time)
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_BATON_RESISTANCE, REF(src)), stun_resistance_time)
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_STUNIMMUNE, REF(src)), stun_resistance_time)
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_CANT_STAMCRIT, REF(src)), stun_resistance_time)

	COOLDOWN_START(src, implant_cooldown, 60 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(implant_ready)),60 SECONDS)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/implant_ready()
	if(owner)
		to_chat(owner, span_purple("Your rebooter implant is ready."))

/obj/item/organ/internal/cyberimp/brain/anti_stun/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	implant_ready()

/obj/item/organ/internal/cyberimp/brain/anti_stun/syndicate
	name = "contraband CNS rebooter implant"
	organ_flags = parent_type::organ_flags | ORGAN_HIDDEN

//[[[[MOUTH]]]]
/obj/item/organ/internal/cyberimp/mouth
	zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/internal/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY
	organ_traits = list(TRAIT_ASSISTED_BREATHING)

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(60/severity))
		to_chat(owner, span_warning("Your breathing tube suddenly closes!"))
		owner.losebreath += 2

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/simple
	name = "simple breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask."
	organ_traits = list()

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implants"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"
	var/list/boxed = list(
		/obj/item/autosurgeon/syndicate/thermal_eyes,
		/obj/item/autosurgeon/syndicate/xray_eyes,
		/obj/item/storage/box/syndie_kit/anti_stun,
		/obj/item/storage/box/syndie_kit/reviver,
		/obj/item/storage/box/syndie_kit/razorwire,
		/obj/item/storage/box/syndie_kit/esword,
		/obj/item/storage/box/syndie_kit/mantis,
		/obj/item/storage/box/syndie_kit/laser_arm,
		/obj/item/storage/box/syndie_kit/deepvien,
		)
	var/amount = 5

/obj/item/storage/box/cyber_implants/PopulateContents()
	var/implant
	while(contents.len <= amount)
		implant = pick(boxed)
		new implant(src)
