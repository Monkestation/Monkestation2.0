/// Multipilier to the fishing weights of anything that's not a fish nor a dud
/// for the magnet hook.
#define MAGNET_HOOK_BONUS_MULTIPLIER 5
/// Multiplier for the fishing weights of fish for the rescue hook.
#define RESCUE_HOOK_FISH_MULTIPLIER 0

// Reels

/obj/item/fishing_line
	name = "fishing line reel"
	desc = "A fishing line. In spite of its simplicity, the added length will make fishing a speck easier."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "reel_blue"
	w_class = WEIGHT_CLASS_SMALL
	///A list of traits that this fishing line has, checked by fish traits and the minigame.
	var/fishing_line_traits = NONE
	/// Color of the fishing line
	var/line_color = "#808080"
	///The amount of range this fishing line adds to casting
	var/cast_range = 2

/obj/item/fishing_line/reinforced
	name = "reinforced fishing line reel"
	desc = "Essential for fishing in extreme environments."
	icon_state = "reel_green"
	fishing_line_traits = FISHING_LINE_REINFORCED
	line_color = "#2b9c2b"

/obj/item/fishing_line/cloaked
	name = "cloaked fishing line reel"
	desc = "Even harder to notice than the common variety."
	icon_state = "reel_white"
	fishing_line_traits = FISHING_LINE_CLOAKED
	line_color = "#82cfdd"

/obj/item/fishing_line/bouncy
	name = "flexible fishing line reel"
	desc = "This specialized line is much harder to snap."
	icon_state = "reel_red"
	fishing_line_traits = FISHING_LINE_BOUNCY
	line_color = "#99313f"
	cast_range = 3

/obj/item/fishing_line/sinew
	name = "fishing sinew"
	desc = "An all-natural fishing line made of stretched out sinew. A bit stiff, but usable to fish in extreme enviroments."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "reel_sinew"
	fishing_line_traits = FISHING_LINE_REINFORCED|FISHING_LINE_STIFF
	fishing_line_traits = FISHING_LINE_REINFORCED
	line_color = "#d1cca3"

// Hooks

/obj/item/fishing_hook
	name = "simple fishing hook"
	desc = "A simple fishing hook. Don't expect to hook onto anything without one."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "hook"
	w_class = WEIGHT_CLASS_TINY

	/// A list of traits that this fishing hook has, checked by fish traits and the minigame
	var/list/fishing_hook_traits
	/// icon state added to main rod icon when this hook is equipped
	var/rod_overlay_icon_state = "hook_overlay"
	/// What subtype of `/obj/item/chasm_detritus` do we fish out of chasms? Defaults to `/obj/item/chasm_detritus`.
	var/chasm_detritus_type = /datum/chasm_detritus


/**
 * Simple getter proc for hooks to implement special hook bonuses for
 * certain `fish_type` (or FISHING_DUD), additive. Is applied after
 * `get_hook_bonus_multiplicative()`.
 */
/obj/item/fishing_hook/proc/get_hook_bonus_additive(fish_type)
	return FISHING_DEFAULT_HOOK_BONUS_ADDITIVE

///Check if tha target can be caught by the hook
/obj/item/fishing_hook/proc/can_be_hooked(atom/target)
	return isitem(target)

///Any special effect when hooking a target that's not managed by the fishing rod.
/obj/item/fishing_hook/proc/hook_attached(atom/target, obj/item/fishing_rod/rod)
	return

/**
 * Simple getter proc for hooks to implement special hook bonuses for
 * certain `fish_type` (or FISHING_DUD), multiplicative. Is applied before
 * `get_hook_bonus_additive()`.
 */
/obj/item/fishing_hook/proc/get_hook_bonus_multiplicative(fish_type)
	return FISHING_DEFAULT_HOOK_BONUS_MULTIPLICATIVE

/obj/item/fishing_hook/rescue/can_be_hooked(atom/target)
	return ..() || isliving(target)

/obj/item/fishing_hook/rescue/hook_attached(atom/target, obj/item/fishing_rod/rod)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/grouped/hooked, rod.fishing_line)

/**
 * Is there a reason why this hook couldn't fish in target_fish_source?
 * If so, return the denial reason as a string, otherwise return `null`.
 *
 * Arguments:
 * * target_fish_source - The /datum/fish_source we're trying to fish in.
 */
/obj/item/fishing_hook/proc/reason_we_cant_fish(datum/fish_source/target_fish_source)
	return null


/obj/item/fishing_hook/magnet
	name = "magnetic hook"
	desc = "Won't make catching fish any easier, but it might help with looking for other things."
	icon_state = "treasure"
	rod_overlay_icon_state = "hook_treasure_overlay"
	chasm_detritus_type = /datum/chasm_detritus/restricted/objects


/obj/item/fishing_hook/magnet/get_hook_bonus_multiplicative(fish_type, datum/fish_source/source)
	if(fish_type == FISHING_DUD || ispath(fish_type, /obj/item/fish))
		return ..()

	// We multiply the odds by five for everything that's not a fish nor a dud
	return MAGNET_HOOK_BONUS_MULTIPLIER


/obj/item/fishing_hook/shiny
	name = "shiny lure hook"
	icon_state = "gold_shiny"
	fishing_hook_traits = FISHING_HOOK_SHINY
	rod_overlay_icon_state = "hook_shiny_overlay"

/obj/item/fishing_hook/weighted
	name = "weighted hook"
	icon_state = "weighted"
	fishing_hook_traits = FISHING_HOOK_WEIGHTED
	rod_overlay_icon_state = "hook_weighted_overlay"


/obj/item/fishing_hook/rescue
	name = "rescue hook"
	desc = "An unwieldy hook meant to help with the rescue of those that have fallen down in chasms. You can tell there's no way you'll catch any fish with this, and that it won't be of any use outside of chasms."
	icon_state = "rescue"
	rod_overlay_icon_state = "hook_rescue_overlay"
	chasm_detritus_type = /datum/chasm_detritus/restricted/bodies
	custom_premium_price = PAYCHECK_CREW * 6 //Monkestation edit

// This hook can only fish in chasms.
/obj/item/fishing_hook/rescue/reason_we_cant_fish(datum/fish_source/target_fish_source)
	if(istype(target_fish_source, /datum/fish_source/chasm))
		return ..()

	return "The hook on your fishing rod wasn't meant for traditional fishing, rendering it useless at doing so!"


/obj/item/fishing_hook/rescue/get_hook_bonus_multiplicative(fish_type, datum/fish_source/source)
	// Sorry, you won't catch fish with this.
	if(ispath(fish_type, /obj/item/fish))
		return RESCUE_HOOK_FISH_MULTIPLIER

	return ..()


/obj/item/fishing_hook/bone
	name = "bone hook"
	desc = "A simple hook carved from sharpened bone"
	icon_state = "hook_bone"

/obj/item/fishing_hook/stabilized
	name = "gyro-stabilized hook"
	desc = "A quirky hook that grants the user a better control of the tool, allowing them to move the bait both and up and down when reeling in, otherwise keeping it in place."
	icon_state = "gyro"
	fishing_hook_traits = FISHING_HOOK_BIDIRECTIONAL
	rod_overlay_icon_state = "hook_gyro_overlay"

/obj/item/fishing_hook/stabilized/examine(mob/user)
	. = ..()
	. += span_notice("While fishing, you can hold the <b>Right</b> Mouse Button to move the bait down, rather than up.")

/obj/item/fishing_hook/jaws
	name = "jawed hook"
	desc = "Despite hints of rust, this gritty beartrap-like hook hybrid manages to look even more threating than the real thing. May neptune have mercy of whatever gets caught in its jaws."
	icon_state = "jaws"
	w_class = WEIGHT_CLASS_NORMAL
	fishing_hook_traits = FISHING_HOOK_NO_ESCAPE|FISHING_HOOK_NO_ESCAPE|FISHING_HOOK_KILL
	rod_overlay_icon_state = "hook_jaws_overlay"

/obj/item/fishing_hook/jaws/can_be_hooked(atom/target)
	return ..() || isliving(target)

/obj/item/fishing_hook/jaws/hook_attached(atom/target, obj/item/fishing_rod/rod)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/grouped/hooked/jaws, rod.fishing_line)

/obj/item/storage/toolbox/fishing
	name = "fishing toolbox"
	desc = "Contains everything you need for your fishing trip."
	icon_state = "fishing"
	inhand_icon_state = "artistic_toolbox"
	material_flags = NONE

/obj/item/storage/toolbox/fishing/Initialize(mapload)
	. = ..()
	// Can hold fishing rod despite the size
	var/static/list/exception_cache = typecacheof(
		/obj/item/fishing_rod,
		/obj/item/fishing_line,
	)
	atom_storage.exception_hold = exception_cache

/obj/item/storage/toolbox/fishing/PopulateContents()
	new /obj/item/bait_can/worm(src)
	new /obj/item/fishing_rod/unslotted(src)
	new /obj/item/fishing_hook(src)
	new /obj/item/fishing_line(src)

/obj/item/storage/toolbox/fishing/small
	name = "compact fishing toolbox"
	desc = "Contains everything you need for your fishing trip. Except for the bait."
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5

/obj/item/storage/toolbox/fishing/small/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL //It can still hold a fishing rod

/obj/item/storage/toolbox/fishing/small/PopulateContents()
	new /obj/item/fishing_rod/unslotted(src)
	new /obj/item/fishing_hook(src)
	new /obj/item/fishing_line(src)

/obj/item/storage/box/fishing_hooks
	name = "fishing hook set"

/obj/item/storage/box/fishing_hooks/PopulateContents()
	. = ..()
	new /obj/item/fishing_hook/magnet(src)
	new /obj/item/fishing_hook/shiny(src)
	new /obj/item/fishing_hook/weighted(src)

/obj/item/storage/box/fishing_lines
	name = "fishing line set"

/obj/item/storage/box/fishing_lines/PopulateContents()
	. = ..()
	new /obj/item/fishing_line/bouncy(src)
	new /obj/item/fishing_line/reinforced(src)
	new /obj/item/fishing_line/cloaked(src)

/**
 * A special line reel that let you skip the biting phase of the minigame, netting you a completion bonus,
 * and thrown hooked items at you, so you can rapidly catch them from afar.
 * It may also work on mobs if the right hook is attached.
 */
/obj/item/fishing_line/auto_reel
	name = "fishing line auto-reel"
	desc = "A fishing line that automatically starts reeling in fish the moment they bite. Also good for hurling things at yourself."
	icon_state = "reel_auto"
	fishing_line_traits = FISHING_LINE_AUTOREEL
	line_color = "#F88414"

/obj/item/fishing_line/auto_reel/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FISHING_EQUIPMENT_SLOTTED, PROC_REF(line_equipped))

/obj/item/fishing_line/auto_reel/proc/line_equipped(datum/source, obj/item/fishing_rod/rod)
	SIGNAL_HANDLER
	RegisterSignal(rod, COMSIG_FISHING_ROD_HOOKED_ITEM, PROC_REF(on_hooked_item))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_removed))

/obj/item/fishing_line/auto_reel/proc/on_removed(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(old_loc, COMSIG_FISHING_ROD_HOOKED_ITEM)

/obj/item/fishing_line/auto_reel/proc/on_hooked_item(obj/item/fishing_rod/source, atom/target, mob/living/user)
	SIGNAL_HANDLER
	if(!ismovable(target))
		return
	var/atom/movable/movable_target = target
	var/please_be_gentle = FALSE
	var/atom/destination
	var/datum/callback/throw_callback
	if(isliving(movable_target) || !isitem(movable_target))
		destination = get_step_towards(user, target)
		please_be_gentle = TRUE
	else
		destination = user
		throw_callback = CALLBACK(src, PROC_REF(clear_hitby_signal), movable_target)
		RegisterSignal(movable_target, COMSIG_ATOM_PREHITBY, PROC_REF(catch_it_chucklenut))

	if(!movable_target.safe_throw_at(destination, source.cast_range, 2, callback = throw_callback, gentle = please_be_gentle))
		UnregisterSignal(movable_target, COMSIG_ATOM_PREHITBY)
	else
		playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)

/obj/item/fishing_line/auto_reel/proc/catch_it_chucklenut(obj/item/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	var/mob/living/user = throwingdatum.initial_target.resolve()
	if(QDELETED(user) || hit_atom != user)
		return
	if(user.try_catch_item(source, skip_throw_mode_check = TRUE, try_offhand = TRUE))
		return COMSIG_HIT_PREVENTED

/obj/item/fishing_line/auto_reel/proc/clear_hitby_signal(obj/item/item)
	UnregisterSignal(item, COMSIG_ATOM_PREHITBY)

/obj/item/storage/box/fish_debug
	name = "box full of fish"

/obj/item/storage/box/fish_debug/PopulateContents()
	for(var/fish_type in subtypesof(/obj/item/fish))
		new fish_type(src)

#undef MAGNET_HOOK_BONUS_MULTIPLIER
#undef RESCUE_HOOK_FISH_MULTIPLIER

///An item that allows the user to add and remove traits from a fish at their own discretion.
/obj/item/fish_genegun
	name = "fish gene-gun"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fish_gun"
	base_icon_state = "fish_gun"
	inhand_icon_state = "gun" //Oh, the laziness
	worn_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	desc = "A device designed to inject or extract traits to and from fish. It takes an empty syringe, which is converted into a fish gene injector once the trait is extracted. Repeated applications may kill the fish."
	w_class = WEIGHT_CLASS_SMALL
	force = 7
	throwforce = 5
	attack_verb_continuous = list("pricked", "stabbed", "poked")
	attack_verb_simple = list("prick", "stab", "poke")
	hitsound = 'sound/items/hypospray.ogg'
	//This can be an empty syringe or a gene injector
	var/obj/item/loaded_injector

/obj/item/fish_genegun/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)

/obj/item/fish_genegun/examine(mob/user)
	. = ..()

	if(!loaded_injector)
		. += span_info("It's currently unloaded. Insert a syringe or fish gene injector.")
		return
	var/info =  span_info("It's currently loaded with [loaded_injector]. Use it to ")
	if(istype(loaded_injector, /obj/item/reagent_containers/syringe))
		info += span_info("[EXAMINE_HINT("extract")] a gene from a fish or aquatic lifeform.")
	else
		info += span_info("[EXAMINE_HINT("inject")] the gene in a fish or aquatic lifeform.")
	. += info

/obj/item/fish_genegun/update_icon_state()
	. = ..()
	icon_state = base_icon_state
	if(!loaded_injector)
		return
	icon_state += istype(loaded_injector, /obj/item/reagent_containers/syringe) ? "_extract" : "_inject"

/obj/item/fish_genegun/attack_self(mob/user)
	if(!loaded_injector)
		balloon_alert(user, "gene-gun is empty!")
		return
	var/obj/item/loaded = loaded_injector
	loaded.forceMove(drop_location()) //this will unset the loaded_injector variable
	if(IsReachableBy(user)) //check that the user can actually reach the loaded injector (telekinesis yadda yadda)
		user.put_in_hands(loaded)
	balloon_alert(user, "gene-gun unloaded")
	playsound(src, 'sound/weapons/gun/general/magazine_remove_full.ogg', 30, TRUE)

/obj/item/fish_genegun/Exited(atom/movable/gone)
	. = ..()
	if(gone == loaded_injector)
		loaded_injector = null
		update_appearance(UPDATE_ICON)

/obj/item/fish_genegun/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	var/is_syringe = istype(item, /obj/item/reagent_containers/syringe)
	if(!is_syringe && istype(item, /obj/item/fish_gene))
		return NONE
	if(loaded_injector)
		to_chat(user, span_warning("[src] already has [loaded_injector] loaded in it."))
		return ITEM_INTERACT_BLOCKING
	if(is_syringe && item.reagents.total_volume)
		to_chat(user, span_warning("[src] cannot accept a syringe that isn't empty. Empty it first."))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(item, src))
		to_chat(user, span_warning("[item] is stuck to your hands."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_info("You load [item] into [src]."))
	loaded_injector = item
	update_appearance(UPDATE_ICON)
	playsound(src, 'sound/weapons/gun/general/magazine_insert_full.ogg', 30, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/fish_genegun/interact_with_atom(obj/interacting_with, mob/living/user, list/modifiers)
	if(!isfish(interacting_with))
		return NONE
	if(!loaded_injector)
		balloon_alert(user, "gene-gun is empty!")
		return ITEM_INTERACT_BLOCKING
	if(interacting_with.flags_1 & HOLOGRAM_1)
		to_chat(user, span_warning("[interacting_with] is incompatible with [src]"))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/fish/fish = interacting_with
	var/is_syringe = istype(loaded_injector, /obj/item/reagent_containers/syringe)
	if(fish.status == FISH_DEAD)
		to_chat(user, span_warning("[src] cannot [is_syringe ? "extract traits from" : "inject traits into"] the deceased [fish.name]."))
		return ITEM_INTERACT_BLOCKING
	if(!is_syringe)
		var/obj/item/fish_gene/injector = loaded_injector
		return injector.inject_into_fish(fish, user, src)

	if(!length(fish.fish_traits))
		to_chat(user, span_warning("[fish] has no traits that can be extracted from!"))
		return ITEM_INTERACT_BLOCKING

	var/list/choices = list()
	for(var/datum/fish_trait/trait_type as anything in fish.fish_traits)
		choices[trait_type::name] = trait_type
	var/choice = tgui_input_list(user, "Choose a trait to extract", "Fish Trait Extraction", choices)
	if(!choice || QDELETED(fish) || !user.is_holding(src) || !fish.IsReachableBy(user))
		return ITEM_INTERACT_BLOCKING

	if(!istype(loaded_injector, /obj/item/reagent_containers/syringe)) //The syringe was taken out
		to_chat(user, span_warning("[src] is not loaded with an syringe to extract fish traits with."))
		return ITEM_INTERACT_BLOCKING
	if(fish.status == FISH_DEAD)
		to_chat(user, span_warning("[src] cannot extract traits from the deceased [fish.name]."))
		return ITEM_INTERACT_BLOCKING
	if(!(choices[choice] in fish.fish_traits))
		to_chat(user, span_warning("[fish] doesn't seem to have the \"[choice]\" trait anymore."))
		return ITEM_INTERACT_BLOCKING

	QDEL_NULL(loaded_injector)
	var/datum/fish_trait/trait_type = choices[choice]
	var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
	trait.remove_from_fish(fish)
	loaded_injector = new /obj/item/fish_gene(src, trait_type)

	user.visible_message(span_notice("[user] injects [fish] with [src]."), span_notice("You extract the \"[trait_type::name]\" trait into [fish]."))
	if(HAS_TRAIT(fish, TRAIT_FISH_GENEGUNNED))
		fish.set_status(FISH_DEAD)
	ADD_TRAIT(fish, TRAIT_FISH_GENEGUNNED, TRAIT_GENERIC)
	playsound(fish, 'sound/items/hypospray.ogg', 30, TRUE)
	update_appearance(UPDATE_ICON)
	return ITEM_INTERACT_SUCCESS

///The injector for the fish trait. Can be used on its own without a fish gene-gun as well.
/obj/item/fish_gene
	name = "fish trait injector"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "fish_trait_injector"
	desc = "A single-use injector containing a specific trait that can be used on any (living) fish compatible with it."
	w_class = WEIGHT_CLASS_TINY
	inhand_icon_state = "dnainjector"
	worn_icon_state = "pen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	var/datum/fish_trait/trait_type

/obj/item/fish_gene/Initialize(mapload, datum/fish_trait/trait_type)
	. = ..()
	if(trait_type)
		src.trait_type = trait_type
	if(src.trait_type)
		update_appearance(UPDATE_NAME)

/obj/item/fish_gene/update_name()
	. = ..()
	name = "fish trait injector ([trait_type::name])"

/obj/item/fish_gene/interact_with_atom(obj/interacting_with, mob/living/user, list/modifiers)
	if(!isfish(interacting_with))
		return NONE
	if(interacting_with.flags_1 & HOLOGRAM_1)
		to_chat(user, span_warning("[interacting_with] is incompatible with [src]"))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/fish/fish = interacting_with
	if(fish.status == FISH_DEAD)
		to_chat(user, span_warning("[src] cannot inject traits into the deceased [fish.name]."))
		return ITEM_INTERACT_BLOCKING
	return inject_into_fish(fish, user, src)

/obj/item/fish_gene/proc/inject_into_fish(obj/item/fish/fish, mob/living/user, obj/item/tool = src)
	var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
	if(!trait.apply_to_fish(fish))
		to_chat(user, span_warning("You can't inject the \"[trait_type::name]\" trait into [fish]. [fish.p_they(TRUE)] either [fish.p_have()] it or [fish.p_are()] incompatible with it."))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] injects [fish] with [tool]."), span_notice("You inject the \"[trait_type::name]\" trait into [fish]."))
	qdel(src)
	if(HAS_TRAIT(fish, TRAIT_FISH_GENEGUNNED))
		fish.set_status(FISH_DEAD)
	ADD_TRAIT(fish, TRAIT_FISH_GENEGUNNED, TRAIT_GENERIC)
	playsound(fish, 'sound/items/hypospray.ogg', 25, TRUE)
	return ITEM_INTERACT_SUCCESS
