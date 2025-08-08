// Let's you pick up and throw structures
/datum/component/throwable_structure
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // Only one of the component can exist on an object
	var/held_lh = 'icons/mob/inhands/structure_held_lh.dmi' //Left hand icon
	var/held_rh = 'icons/mob/inhands/structure_held_rh.dmi' //Right hand icon
	var/held_state = "" //Icon state of inhand
	var/held_force = 0 //Held attack damage
	var/throw_force = 0 //Throw damage
	var/throw_knockdown = 0 //Throw knockdown
	var/held_slowdown = 0 //Slowdonw while held
	var/impact_sound = 'sound/effects/bang.ogg' //Impact Sound

/datum/component/throwable_structure/Initialize(held_state="", held_force=0, throw_force=0, throw_knockdown=0, held_slowdown=0, impact_sound='sound/effects/bang.ogg')
	if(!istype(parent, /obj/structure) && !istype(parent, /obj/machinery))
		return COMPONENT_INCOMPATIBLE

	src.held_state = held_state
	src.held_force = held_force
	src.throw_force = throw_force
	src.throw_knockdown = throw_knockdown
	src.held_slowdown = held_slowdown
	src.impact_sound = impact_sound

// Inherit the new values passed to the component
/datum/component/throwable_structure/InheritComponent(datum/component/throwable_structure/new_comp, original, \
											held_state, held_force, throw_force, throw_knockdown, held_slowdown, impact_sound)
	if(!original)
		return
	if(held_state)
		src.held_state = held_state
	if(held_force)
		src.held_force = held_force
	if(throw_force)
		src.throw_force = throw_force
	if(throw_knockdown)
		src.throw_knockdown = throw_knockdown
	if(held_slowdown)
		src.held_slowdown = held_slowdown
	if(impact_sound)
		src.impact_sound = impact_sound

// register signals with the parent item
/datum/component/throwable_structure/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	RegisterSignal(parent, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mouse_drop))

/datum/component/throwable_structure/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOUSEDROP_ONTO))

/datum/component/throwable_structure/proc/on_throw_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(isliving(hit_atom))
		var/mob/living/living_target = hit_atom
		var/blocked = living_target.run_armor_check(attack_flag = MELEE)
		if(iscarbon(living_target))
			var/mob/living/carbon/carbon_target = living_target
			carbon_target.take_bodypart_damage(throw_force, 0, check_armor = TRUE, wound_bonus = 5)
		else
			living_target.apply_damage(throw_force, BRUTE, blocked = blocked, forced = FALSE, attack_direction = get_dir(get_turf(parent), living_target))
		if(throw_knockdown)
			living_target.Knockdown(throw_knockdown)
		playsound(parent, impact_sound, 40)
	else
		playsound(hit_atom, 'sound/weapons/genhit.ogg',80 , TRUE, -1)

/datum/component/throwable_structure/proc/on_mouse_drop(datum/source, atom/dropping, mob/user)
	SIGNAL_HANDLER
	var/obj/structure_interact = parent
	if(dropping == user && structure_interact.Adjacent(user))
		if(structure_interact.anchored || (structure_interact.flags_1 & NODECONSTRUCT_1))
			return
		if(!user.can_perform_action(structure_interact, NEED_DEXTERITY|NEED_HANDS))
			return
		INVOKE_ASYNC(src, PROC_REF(structure_try_pickup), user)

/datum/component/throwable_structure/proc/structure_try_pickup(mob/living/user)
	var/obj/structure_interact = parent
	if(user.get_num_held_items())
		to_chat(user, span_warning("Your hands are full!"))
		return FALSE
	user.visible_message(span_notice("[user] starts picking up [parent]!"), span_notice("You start picking up [parent]..."))
	if(!do_after(user, 3 SECONDS, target = parent))
		return FALSE
	if(structure_interact.anchored || !structure_interact.Adjacent(user) || user.get_num_held_items())
		return FALSE
	structure_pickup(user)
	return TRUE

/datum/component/throwable_structure/proc/structure_pickup(mob/living/user)
	var/obj/item/structure_holder/holder = new(get_turf(parent), parent, held_state, held_lh, held_rh, held_force, throw_force, held_slowdown)
	user.visible_message(span_warning("[user] picks up [parent]!"), span_warning("You pick up [parent]!"))
	user.put_in_hands(holder)
	playsound(holder, SFX_RUSTLE, 50, TRUE, -5)

// Holder so we can pick it up
/obj/item/structure_holder
	name = "bugged structure holder"
	desc = "Yell at coders."
	icon = null
	icon_state = ""
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
	attack_verb_simple = list("smack", "strike", "crack", "beat")
	slowdown = 1
	item_flags = SLOWS_WHILE_IN_HAND
	var/obj/held_structure
	var/destroying = FALSE
	var/datum/component/two_handed/two_handed_component

/obj/item/structure_holder/Initialize(mapload, obj/target_structure, held_state, lh_icon, rh_icon, held_force, held_throwforce, held_slowdown)
	if(held_state)
		inhand_icon_state = held_state
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)
		righthand_file = rh_icon
	if(held_force)
		force = held_force
	if(held_throwforce)
		throwforce = held_throwforce
	if(held_slowdown)
		slowdown = held_slowdown
	deposit(target_structure)
	two_handed_component = AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = force, force_wielded = force)
	. = ..()

/obj/item/structure_holder/Destroy()
	if(held_structure)
		release(FALSE)
	return ..()

/obj/item/structure_holder/proc/deposit(obj/deposited_structure)
	if(!istype(deposited_structure))
		return FALSE
	deposited_structure.setDir(SOUTH)
	appearance = deposited_structure.appearance
	held_structure = deposited_structure
	deposited_structure.forceMove(src)
	name = deposited_structure.name
	desc = deposited_structure.desc
	return TRUE

/obj/item/structure_holder/on_thrown(mob/living/carbon/user, atom/target)
	if((item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return

	two_handed_component?.unwield(user, FALSE, FALSE)

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You set [src] down gently on the ground."))
		release()
		return

	var/obj/throw_structure = held_structure
	release()
	return throw_structure

/obj/item/structure_holder/dropped(mob/living/user)
	..()
	if(held_structure && isturf(loc))
		release()

/obj/item/structure_holder/proc/release(del_on_release = TRUE)
	if(!held_structure)
		if(del_on_release && !QDELING(src))
			qdel(src)
		return FALSE
	var/obj/released_structure = held_structure
	held_structure = null // stops the held structure from being release()'d twice.
	if(isliving(loc) && !QDELING(src))
		var/mob/living/structure_carrier = loc
		structure_carrier.dropItemToGround(src)
	if(!QDELING(released_structure))
		released_structure.forceMove(drop_location())
		released_structure.setDir(SOUTH)
	if(del_on_release && !QDELING(src))
		qdel(src)
	return TRUE

/obj/item/structure_holder/Exited(atom/movable/gone, direction)
	. = ..()
	if(held_structure && held_structure == gone)
		release()
