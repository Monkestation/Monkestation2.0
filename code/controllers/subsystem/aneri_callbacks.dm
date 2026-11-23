/// Runs callbacks for finished aneri requests on the MC's tick budget, since aneri itself hands results back outside of it.
SUBSYSTEM_DEF(aneri_callbacks)
	name = "Aneri Callbacks"
	flags = SS_TICKER | SS_NO_INIT | SS_HIBERNATE
	wait = 1
	init_stage = INITSTAGE_FIRST
	runlevels = ALL

	/// list(callback, result) pairs waiting for their turn.
	var/list/queue = list()

/datum/controller/subsystem/aneri_callbacks/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, queue),
	)

/datum/controller/subsystem/aneri_callbacks/Recover()
	queue = SSaneri_callbacks.queue

/datum/controller/subsystem/aneri_callbacks/stat_entry(msg)
	msg = "Q:[length(queue)]"
	return ..()

// prevents callback workarounds
/datum/controller/subsystem/aneri_callbacks/can_vv_get(var_name)
	if(var_name == NAMEOF(src, queue))
		return FALSE
	return ..()

/datum/controller/subsystem/aneri_callbacks/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, queue))
		return FALSE
	return ..()

/datum/controller/subsystem/aneri_callbacks/fire(resumed)
	while(length(queue))
		var/list/entry = popleft(queue)
		var/datum/callback/callback = entry[1]
		if(callback.object == GLOBAL_PROC || !QDELETED(callback.object))
			callback.InvokeAsync(entry[2])
		if(MC_TICK_CHECK)
			return

/// aneri callback target: queues this callback to be invoked with the result on SSaneri_callbacks' next fire.
/datum/callback/proc/queue_aneri_result(result)
	SSaneri_callbacks.queue += list(list(src, result))

/// Like send(), but on_done gets invoked with the response from SSaneri_callbacks instead of right when aneri hands it back.
/datum/http_request/proc/send_queued(datum/callback/on_done) as /datum/http_request
	return send(on_done, TYPE_PROC_REF(/datum/callback, queue_aneri_result))
