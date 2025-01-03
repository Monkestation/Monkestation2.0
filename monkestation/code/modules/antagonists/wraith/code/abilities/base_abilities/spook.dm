#define spooky_icons 'monkestation/code/modules/antagonists/wraith/icons/radial_menu_icons.dmi'
/datum/action/cooldown/spell/wraith/spook
	name = "Spook"
	desc = "Allows you to make some spooky things happen, free of charge!."
	button_icon_state = "spook"

	essence_cost = 0 // ???
	cooldown_time = 20 SECONDS

	var/list/spooky_stuffs = list(
		"Flip light switches" = icon(spooky_icons, "flip_light_switches"),
		"Break lightbulbs" = icon(spooky_icons, "break_lightbulbs"),
		"Create smoke" = icon(spooky_icons, "create_smoke"),
		"Create ectoplasm" = icon(spooky_icons, "create_ectoplasm"),
		"Sap APC" = icon(spooky_icons, "sap_apc"),
		"Haunt PDA's" = icon(spooky_icons, "haunt_pdas"),
		"Open locks" = icon(spooky_icons, "open_locks"),
		"Random" = icon(spooky_icons, "random"),
	)
	var/list/spooky_messages = list(
		"boo",
		"there's a skeleton inside of you, let it out, LET IT OUT, RIP IT OUT!!!",
		"THERES BUGS IN YOUR SKIN, TAKE THEM OUT, TAKE OFF YOUR SKIN!",
		"4999 credits successfully sent to john doe", // SHIT THEY GOT MY CREDIT CARD
		"i can see you, can you see me? can you hear me? can you feel me?",
		"I am inside your walls.",
		"Do you ever hear the voice scraping at the back of your skull any remaining bits of sanity?",
		"You've been CURSED, you have to forward this to 5 people or you will DIE",

		"We've been trying to reach you concerning your soul's extended warranty. \
		You should've received a notice in the mail about your soul's extended warranty eligibility. \
		Since we've not gotten a response, we're giving you a final courtesy call before we close out your file. \
		Press 2 to be removed and placed on our do-not-call list. \
		To speak to someone about possibly extending or reinstating your vehicle's warranty, \
		press 1 to speak with a warranty specialist",
	)

/datum/action/cooldown/spell/wraith/spook/cast(mob/living/cast_on)
	. = ..()
	var/area/current_area = get_area(owner)
	if(current_area.outdoors)
		to_chat(owner, span_revenwarning("Cannot use this ability in space!")) // Yeah no, lets not do this
		reset_spell_cooldown()
		return

	var/choice = show_radial_menu(owner, owner, spooky_stuffs, radius = 60, tooltips = TRUE)
	if(choice == "Random")
		choice = pick(spooky_stuffs - "Random")

	current_area = get_area(owner) // I love radial menu's
	if(current_area.outdoors)
		to_chat(owner, span_revenwarning("Cannot use this ability in space!"))
		reset_spell_cooldown()
		return

	switch(choice)
		if("Flip light switches")
			for(var/obj/machinery/light_switch/light_switch as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light_switch))
				if(light_switch.area == current_area)
					light_switch.set_lights(!current_area.lightswitch)
					return

			to_chat(owner, span_revenwarning("There are no light switches in this area!")) // Great work mappers!
			reset_spell_cooldown()

		if("Break lightbulbs")
			for(var/turf/area_turf as anything in current_area.turfs_by_zlevel[owner.z])
				for(var/obj/machinery/light/breaked_light in area_turf)
					if(!breaked_light.on)
						continue

					breaked_light.break_light_tube()
					if(prob(50))
						return

		if("Create smoke")
			var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
			smoke.set_up(4, holder = owner, location = owner)
			smoke.start()
			qdel(smoke) //And deleted again. Sad really.

		if("Create ectoplasm")
			for(var/i in 1 to rand(5, 9))
				new /obj/effect/decal/cleanable/greenglow/ecto(pick(current_area.turfs_by_zlevel[owner.z]))

		if("Sap APC")
			if(isnull(current_area.apc?.cell))
				to_chat(owner, span_revenwarning("There is no power to sap!")) // Great work engineers!
				reset_spell_cooldown()
				return

			var/obj/item/stock_parts/cell/cell = current_area.apc.cell
			var/power_to_sap = 500 // Big sippy

			var/mob/living/basic/wraith/true_owner = owner
			if(istype(true_owner))
				power_to_sap *= true_owner.essence_gain

			cell.use(min(cell.charge, power_to_sap))

		if("Haunt PDA's")
			var/list/datum/computer_file/program/messenger/messengers = list()
			var/list/local_messengers_list = GLOB.pda_messengers.Copy()
			for(var/index as anything in local_messengers_list)
				var/datum/computer_file/program/messenger/messenger = local_messengers_list[index]
				if(get_area(messenger.computer) != current_area)
					continue
				messengers += messenger

			if(!length(messengers))
				to_chat(owner, span_revenwarning("There are no PDA's to message!")) // Great work wraith!
				reset_spell_cooldown()

			var/datum/signal/subspace/messaging/tablet_message/signal = new(null, list(
				"fakename" = "",
				"fakejob" = "",
				"message" = pick(spooky_messages),
				"targets" = messengers,
				"ref" = null,
				"everyone" = FALSE,
				"rigged" = FALSE,
				"automated" = FALSE,
			))

			signal.broadcast()

		if("Open locks")
			for(var/list/zlevel_turfs as anything in current_area.get_zlevel_turf_lists()) // ???
				for(var/turf/area_turf as anything in zlevel_turfs) // ??????????
					for(var/obj/machinery/door/airlock/airlock in area_turf)
						airlock.unbolt()
						if(airlock.density)
							airlock.open()
						else
							airlock.close()

						if(prob(60))
							break

					for(var/obj/structure/closet/locker in area_turf)
						if(locker.density)
							locker.open(owner, TRUE)
						else
							locker.close(owner, TRUE)

						if(prob(60))
							break
		else
			reset_spell_cooldown()

#undef spooky_icons
