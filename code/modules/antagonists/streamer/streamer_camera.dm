/obj/machinery/camera/proc/on_active_camera(obj/structure/tuned_in)

/obj/machinery/camera/proc/on_deactive_camera(obj/structure/tuned_out)

/obj/machinery/camera/spesstv
	name = "\improper Spess.TV camera"
	network = list("SpessTV")
	var/datum/antagonist/streamer/streamer
	var/static/suffix_tag = 0
	var/list/tuned_in_machines = list()

/obj/machinery/camera/spesstv/Initialize(mapload, obj/structure/camera_assembly/old_assembly)
	. = ..()
	suffix_tag++

/obj/machinery/camera/spesstv/proc/setup_streamer()
	if(streamer)
		RegisterSignal(streamer.owner.current, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

/obj/machinery/camera/spesstv/Destroy()
	. = ..()
	tuned_in_machines = null
	if(streamer)
		UnregisterSignal(streamer.owner.current, COMSIG_MOVABLE_HEAR)

/obj/machinery/camera/spesstv/proc/name_camera()
	var/team_name = streamer?.team
	var/basename = streamer?.owner?.name || "Unknown"
	if(team_name)
		basename = "\[[team_name]\] [basename]"
	var/nethash = english_list(network)
	name = "[nethash]_0[suffix_tag]"
	c_tag = "[name] - [streamer.owner.current.name]"

/obj/machinery/camera/spesstv/on_active_camera(obj/structure/tuned_in)
	tuned_in_machines |= tuned_in

/obj/machinery/camera/spesstv/on_deactive_camera(obj/structure/tuned_out)
	tuned_in_machines -= tuned_out

/obj/machinery/camera/spesstv/proc/handle_hearing(mob/living/owner, list/hearing_args)
	if(get_dist(owner, hearing_args[HEARING_SPEAKER]) > 5)
		return
	if(hearing_args[HEARING_SPEAKER] in tuned_in_machines)
		return
	if(status == 0)
		return

	// Recompose the message, because it's scrambled by default

	var/atom/movable/speaker = hearing_args[HEARING_SPEAKER]
	var/message = "[speaker] [speaker.say_mod(hearing_args[HEARING_RAW_MESSAGE])] [hearing_args[HEARING_RAW_MESSAGE]]"

	for(var/obj/structure/machine as anything in tuned_in_machines)
		machine.say(message)
