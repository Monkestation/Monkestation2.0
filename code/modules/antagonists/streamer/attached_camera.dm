/obj/item/clothing/accessory/spesstv_tactical_camera
	name = "\improper Spess.TV tactical camera"
	desc = "A compact, tactical camera with built-in Spess.TV integration. Fits on uniform, armor and headgear. It features a Team Security logo."
	icon_state = "small_camera" // Credits to https://github.com/discordia-space/CEV-Eris
	var/obj/machinery/camera/spesstv/internal_camera

/obj/item/clothing/accessory/spesstv_tactical_camera/Initialize(mapload)
	. = ..()
	internal_camera = new(src)
	new /datum/action/item_action/toggle_streaming(src)


/obj/item/clothing/accessory/spesstv_tactical_camera/attack_self(mob/user)
	..()
	if(user.incapacitated())
		return
	if(!internal_camera.streamer)
		if(user.mind.has_antag_datum(/datum/antagonist/streamer))
			to_chat(user, span_warning("A camera is already linked to your Spess.TV account!") )
			return
		var/datum/antagonist/streamer/new_streamer_role = new /datum/antagonist/streamer
		if(!user.mind?.add_antag_datum(new_streamer_role))
			user.mind?.remove_antag_datum(new_streamer_role)
			to_chat(user, span_warning("Something went wrong during your registration to Spess.TV. Please try again.") )
			return
		new_streamer_role.team = "Security"
		new_streamer_role.camera = internal_camera
		new_streamer_role.set_camera(internal_camera)
	if(internal_camera.streamer.owner != user.mind)
		to_chat(user, span_warning("You are not the registered user of this camera.") )
		return
	internal_camera.streamer.toggle_streaming()

/datum/action/item_action/toggle_streaming
	name = "Toggle streaming"

/datum/action/item_action/toggle_streaming/Trigger(trigger_flags)
	var/obj/item/target_item = target
	target_item.attack_self(owner)
