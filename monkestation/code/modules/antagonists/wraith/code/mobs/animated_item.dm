/// Basically we slap the item into the mob, and copy its combat values
/mob/living/basic/wraith_spawn/animated_item
	name = "Rogue item"
	desc = "You shouldn't see this!"

	friendly_verb_continuous = "looks at"
	friendly_verb_simple = "look at"
	death_message = "wails as infernal energy escapes from it!"

	basic_mob_flags = DEL_ON_DEATH
	density = FALSE

	/// The item that resides within us
	var/obj/item/stored_item

/mob/living/basic/wraith_spawn/animated_item/New(loc, obj/item/item)
	stored_item = item
	item.forceMove(src)
	return ..()

/mob/living/basic/wraith_spawn/animated_item/Initialize(mapload)
	if(stored_item)
		stored_item.forceMove(src)
	else
		stored_item = new /obj/item/storage/toolbox/mechanical(src) // backup

	ADD_TRAIT(src, TRAIT_GUN_NATURAL, INNATE_TRAIT) // yes, we can shoot with GUNS
	name = "glowing [stored_item.name]"
	desc = "[stored_item.desc] This one seems to be very angry!"
	maxHealth = (stored_item.max_integrity / 4) // Why do atoms have SO MUCH INTEGRITY
	health = (stored_item.get_integrity() / 4)
	melee_attack_cooldown = stored_item.attack_speed

	icon = stored_item.icon
	icon = stored_item.icon_state
	add_overlay(stored_item)

	add_filter("haunt_glow", 2, list("type" = "outline", "color" = COLOR_DARK_PURPLE, "size" = 1))
	RegisterSignal(stored_item, COMSIG_QDELETING, PROC_REF(item_deleted))
	return ..()

/mob/living/basic/wraith_spawn/animated_item/Destroy(force)
	UnregisterSignal(stored_item, COMSIG_QDELETING)
	if(stored_item) // grenades and such can delete it before we delete ourselfes
		UnregisterSignal(stored_item, COMSIG_QDELETING)
		stored_item.forceMove(get_turf(src))
		stored_item.take_damage(maxHealth - health)
	stored_item = null
	return ..()

/mob/living/basic/wraith_spawn/animated_item/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	face_atom(target)
	changeNext_move(melee_attack_cooldown)
	if(target == src)
		stored_item.attack_self(src, modifiers)
		return TRUE

	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target, Adjacent(target), modifiers) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE

	stored_item.melee_attack_chain(src, target)

	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, TRUE)
	return TRUE

/mob/living/basic/wraith_spawn/animated_item/RangedAttack(atom/A, modifiers)
	. = ..()
	if(!. && isgun(stored_item))
		stored_item.afterattack(A, src)

// STOP STEALING MY ITEMS
/mob/living/basic/wraith_spawn/animated_item/transferItemToLoc(obj/item/I, newloc = null, force = FALSE, silent = TRUE)
	istate = ISTATE_HARM
	return FALSE

/mob/living/basic/wraith_spawn/animated_item/proc/item_deleted()
	SIGNAL_HANDLER
	qdel(src) // No point in living anymore

/// An animated item that a wraith is controlling, we dont need anything complicated
/mob/living/basic/wraith_spawn/animated_item/possessed
	var/mob/living/basic/wraith/our_wraith

/mob/living/basic/wraith_spawn/animated_item/possessed/New(loc, obj/item/item, mob/living/basic/wraith/wraith)
	our_wraith = wraith
	return ..()

/mob/living/basic/wraith_spawn/animated_item/possessed/Initialize(mapload)
	if(!our_wraith)
		new /mob/living/basic/wraith_spawn/animated_item(get_turf(src))
		message_admins("\"/mob/living/basic/wraith_spawn/animated_item/possessed\" was spawned in without a set wraith, this is most likelly an admin spawning in the wrong subtype, please spawn \"/mob/living/basic/wraith_spawn/animated_item\" instead!")
		qdel(src)
		return ..()
	our_wraith.forceMove(src)
	ckey = our_wraith.ckey
	addtimer(CALLBACK(src, PROC_REF(death)), 1 MINUTE)
	return ..()

/mob/living/basic/wraith_spawn/animated_item/possessed/Destroy(force)
	if(our_wraith)
		our_wraith.forceMove(get_turf(src))
		our_wraith.ckey = ckey
		our_wraith = null
	return ..()
