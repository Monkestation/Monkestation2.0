#define VERB_ARG_CONTEXT_TARGET_KEY "__context_target__"

/**
 * Alright so like, I'm sorry, ok?
 *
 * This macro enables us to track the cost of individual verbs, and queue them up if running them would push us into overtime.
 * The reason we do this is because verbs are not tracked by byond's cpu profiling tools (world.cpu, etc) at all. They're in the profiler, and that's IT.
 * This is a problem because it means we can't account for them when scheduling work, even if we wanted to. We also have no idea if they push us into overtime or not.
 * This macro fixes that.
 * The idea is to shim all verb (or verb like, IE user input so Topic, Click, etc) calls with cost tracking and queuing code, which is what's below.
 * We define a child proc for the actual verb to call, and use macro magic to make any code after a GAME_VERB**() line actually live in that child proc.
 * The only reason this file is so messy and has so many variations is we need to shim verb attribute sets too because they have to be inline
 * with the verb/proc they actually apply to
 * Anyway the actual profiling is pretty simple, we're using the ability to shim to also detect and ignore sleeps. At that point it's just a matter of measuring
 * the usage between the start and end of the verb's call, and boom we have the cost.
 * There's some nuance here, verbs are tracked by name, if we don't want an execution time to "count" for a given verb
 * we need to "change" that name. Some places also rename verbs based off context (Topic does this), etc.
 * We need to be careful to only rename BEFORE checking if we need to queue, doing it after just creates unusable junk data (which is rarely something you want)
**/

/// This is the underlying workhorse. This macro runs the verb we want to execute and tracks its time, assuming thisi s being ran as a verb and all
#define VERB_QUEUE_OR_FIRE(proc_name, call_on, lookup_method, queue_on) \
	if(caller) { \
		proc_name(arglist(args)); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		if(queue_on && INTELIGENT_TRY_QUEUE_VERB(HELL_CALLBACK(call_on, lookup_method(proc_name),  args.Copy()), VERB_HIGH_PRIORITY_QUEUE_THRESHOLD, queue_on)) { \
			__store_cost.name_to_use = "nullified_verb"; \
			VERB_TRACKER_FINISH(__store_cost); \
			return; \
		} \
		ASYNC { \
			proc_name(arglist(args)); \
		} \
		VERB_TRACKER_FINISH(__store_cost); \
	}

#define VERB_INVOKE_QUEUE_OR_FIRE(call_on, verb_path, verb_args) \
	if(caller) { \
		INVOKE_ASYNC(SSverbs, TYPE_PROC_REF(/datum/controller/subsystem/verbs, invoke_verb), call_on, verb_path, verb_args, usr); \
	} else { \
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee); \
		if(INTELIGENT_TRY_QUEUE_VERB(VERB_CALLBACK(SSverbs, TYPE_PROC_REF(/datum/controller/subsystem/verbs, invoke_verb), call_on, verb_path, verb_args, usr), VERB_HIGH_PRIORITY_QUEUE_THRESHOLD, SSverb_manager)) { \
			__store_cost.name_to_use = "nullified_verb"; \
			VERB_TRACKER_FINISH(__store_cost); \
			return; \
		} \
		ASYNC { \
			SSverbs.invoke_verb(call_on, verb_path, verb_args, usr); \
		} \
		VERB_TRACKER_FINISH(__store_cost); \
	}

/**
 * Defines a game verb with an associated /datum/verb_metadata.
 *
 * Usage:
 *   GAME_VERB(/client, ooc, "OOC", "Send a message in OOC.", "OOC")
 *       VERB_ARG(msg, VERB_ARG_TYPE_TEXT, VERB_ARG_SOURCE_INPUT)
 *       // verb body using msg
 */

#define _GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden, is_instant) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name() \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(popup_menu, ##show_in_context_menu); \
	VERBLIKE_SET(category, ##verb_category); \
	VERBLIKE_SET(instant, ##is_instant); \
	VERB_INVOKE_QUEUE_OR_FIRE(src, ##owner_type/verb/##verb_path_name, args.Copy()); \
}; \
##owner_type/proc/__gvb_##verb_path_name(list/structured_args)

#define GAME_VERB(owner_type, verb_path_name, verb_name, verb_category) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE, FALSE)

#define GAME_VERB_DESC(owner_type, verb_path_name, verb_name, verb_desc, verb_category) \
_GAME_VERB(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE, FALSE)

#define _GAME_VERB_CONTEXT(owner_type, verb_path_name, verb_name, verb_desc, verb_category, context_type) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(var##context_type/__context_target in world) \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, FALSE); \
	VERBLIKE_SET(popup_menu, TRUE); \
	VERBLIKE_SET(category, ##verb_category); \
	var/list/__args = args.Copy(); \
	if(__context_target) { __args += list(VERB_ARG_CONTEXT_TARGET_KEY = __context_target); }; \
	VERB_INVOKE_QUEUE_OR_FIRE(src, ##owner_type/verb/##verb_path_name, __args); \
}; \
##owner_type/proc/__gvb_##verb_path_name(list/structured_args)

#define GAME_VERB_CONTEXT(owner_type, verb_path_name, verb_name, verb_desc, verb_category, context_type) \
_GAME_VERB_CONTEXT(owner_type, verb_path_name, verb_name, verb_desc, verb_category, context_type)

#define GAME_VERB_HIDDEN(owner_type, verb_path_name, verb_name) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", null, FALSE, TRUE, FALSE)

#define GAME_VERB_HIDDEN_INSTANT(owner_type, verb_path_name, verb_name) \
_GAME_VERB(owner_type, verb_path_name, verb_name, "", null, FALSE, TRUE, TRUE)

/// For where you still need native args, ie, when called directly from the skin or some BYOND function
#define _GAME_VERB_NATIVE(owner_type, verb_path_name, verb_name, verb_category, is_instant, queue_on, verb_args...) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name(##verb_args) \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(hidden, TRUE); \
	VERBLIKE_SET(instant, ##is_instant); \
	VERB_QUEUE_OR_FIRE(__gvb_##verb_path_name, src, PROC_REF, queue_on); \
}; \
##owner_type/proc/__gvb_##verb_path_name(##verb_args)

#define GAME_VERB_NATIVE(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
_GAME_VERB_NATIVE(owner_type, verb_path_name, verb_name, verb_category, FALSE, SSverb_manager, ##verb_args)

#define GAME_VERB_NATIVE_INSTANT(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
_GAME_VERB_NATIVE(owner_type, verb_path_name, verb_name, verb_category, TRUE, SSverb_manager, ##verb_args)

/// Tracked like the rest but never queued, for verbs that measure timing (ping) and would read wrong if delayed a tick
#define GAME_VERB_NATIVE_INSTANT_NO_QUEUE(owner_type, verb_path_name, verb_name, verb_category, verb_args...) \
_GAME_VERB_NATIVE(owner_type, verb_path_name, verb_name, verb_category, TRUE, null, ##verb_args)

#define _GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/proc/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/proc/##verb_path_name() \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(popup_menu, ##show_in_context_menu); \
	VERBLIKE_SET(category, ##verb_category); \
	VERB_INVOKE_QUEUE_OR_FIRE(src, ##owner_type/proc/##verb_path_name, args.Copy()); \
}; \
##owner_type/proc/__gvb_##verb_path_name(list/structured_args)

#define GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_category) \
_GAME_VERB_PROC(owner_type, verb_path_name, verb_name, "", verb_category, TRUE, FALSE)

#define GAME_VERB_PROC_DESC(owner_type, verb_path_name, verb_name, verb_desc, verb_category) \
_GAME_VERB_PROC(owner_type, verb_path_name, verb_name, verb_desc, verb_category, TRUE, FALSE)

#define _GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, show_in_context_menu, is_hidden) \
/datum/verb_metadata##owner_type/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = ##owner_type/verb/##verb_path_name; \
	body_path = ##owner_type/proc/__gvb_##verb_path_name; \
}; \
##owner_type/verb/##verb_path_name() \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(popup_menu, ##show_in_context_menu); \
	VERBLIKE_SET(category, ##verb_category); \
	set src in src_value; \
	VERB_INVOKE_QUEUE_OR_FIRE(src, ##owner_type/verb/##verb_path_name, args.Copy()); \
}; \
##owner_type/proc/__gvb_##verb_path_name(list/structured_args)

#define GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_category) \
_GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, "", verb_category, TRUE, FALSE)

#define GAME_VERB_SRC_DESC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category) \
_GAME_VERB_SRC(owner_type, verb_path_name, src_value, verb_name, verb_desc, verb_category, TRUE, FALSE)

#define _GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, is_hidden) \
/datum/verb_metadata/##verb_path_name \
{ \
	name = ##verb_name; \
	description = ##verb_desc; \
	category = ##verb_category; \
	verb_path = /proc/##verb_path_name; \
	body_path = /proc/__gvb_##verb_path_name; \
}; \
/proc/##verb_path_name() \
{ \
	VERBLIKE_SET(name, ##verb_name); \
	VERBLIKE_SET(desc, ##verb_desc); \
	VERBLIKE_SET(hidden, ##is_hidden); \
	VERBLIKE_SET(category, ##verb_category); \
	VERB_INVOKE_QUEUE_OR_FIRE(usr, /proc/##verb_path_name, args.Copy()); \
}; \
/proc/__gvb_##verb_path_name(list/structured_args)

#define GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category) \
_GAME_VERB_GLOBAL_PROC(verb_path_name, verb_name, verb_desc, verb_category, FALSE)

#define INVOKE_GAME_VERB(target, caller, owner_type, verb_path_name, args...) SSverbs.invoke(target, /datum/verb_metadata##owner_type/##verb_path_name, caller, alist(##args))
#define ASSIGN_GAME_VERB(target, owner_type, verb_path_name) SSverbs.assign_verb(target, /datum/verb_metadata##owner_type/##verb_path_name)
#define UNASSIGN_GAME_VERB(target, owner_type, verb_path_name) SSverbs.unassign_verb(target, /datum/verb_metadata##owner_type/##verb_path_name)

/// Self-registers argument metadata at world init and extracts value from structured_args at runtime.
/// For primitive args: VERB_ARG(count, VERB_ARG_TYPE_NUM, VERB_ARG_SOURCE_INPUT)
/// For typed args: VERB_ARG_TYPED(target, VERB_ARG_TYPE_MOB, VERB_ARG_SOURCE_WORLD, /mob/living)
#define VERB_ARG(name, arg_type, source) \
	var/static/____reg_##name = ____register_verb_arg(__TYPE__, __PROC__, #name, arg_type, null, source); \
	var/##name = structured_args[#name]

#define VERB_ARG_TYPED(name, arg_type, source, type_path) \
	var/static/____reg_##name = ____register_verb_arg(__TYPE__, __PROC__, #name, arg_type, type_path, source); \
	var##type_path/##name = structured_args[#name]

#define VERB_ARG_TYPE_TEXT (1<<0)
#define VERB_ARG_TYPE_NUM (1<<1)
#define VERB_ARG_TYPE_MESSAGE (1<<2)
#define VERB_ARG_TYPE_SOUND (1<<3)
#define VERB_ARG_TYPE_ICON (1<<4)
#define VERB_ARG_TYPE_MOB (1<<5)
#define VERB_ARG_TYPE_OBJ (1<<6)
#define VERB_ARG_TYPE_TURF (1<<7)
#define VERB_ARG_TYPE_AREA (1<<8)
#define VERB_ARG_TYPE_DATUM (1<<9)
#define VERB_ARG_TYPE_ATOM (1<<10)
#define VERB_ARG_TYPE_TYPEPATH (1<<11)

#define VERB_ARG_TYPE_ENTITY (VERB_ARG_TYPE_MOB | VERB_ARG_TYPE_OBJ | VERB_ARG_TYPE_TURF | VERB_ARG_TYPE_AREA | VERB_ARG_TYPE_DATUM | VERB_ARG_TYPE_ATOM)

/// Picks from a fixed list of options. Use with VERB_ARG_LIST.
#define VERB_ARG_LIST(name, options_list) \
	var/static/____reg_##name = ____register_verb_arg_list(__TYPE__, __PROC__, #name, options_list); \
	var/##name = structured_args[#name]

// Argument source constants
#define VERB_ARG_SOURCE_INPUT "input"
#define VERB_ARG_SOURCE_WORLD "world"
#define VERB_ARG_SOURCE_VIEW "view"
#define VERB_ARG_SOURCE_LIST "list"
