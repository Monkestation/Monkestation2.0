/**** Mechanical God ****/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list("By the inner workings of our god ...",
						"... We call upon you, in the face of adversity ...",
						"... to complete us, removing that which is undesirable ...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 1000

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("You're going to convert the one buckled on [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		if(isandroid(user))
			to_chat(user, span_warning("You've already converted yourself. To convert others, they must be buckled to [movable_reltool]."))
			return FALSE
		to_chat(user, span_warning("You're going to convert yourself with this ritual."))
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/android/holy)
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE


/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "Let your will power our forges.",
							"...Help us in our great conquest!")
	invoke_msg = "The end of flesh is near!"
	favor_cost = 2000

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/list/blessing = list( //RnD attainable implants + black market. Minus some of the more powerful ones.
		/obj/item/organ/internal/cyberimp/arm/item_set/toolset,
		/obj/item/organ/internal/cyberimp/arm/item_set/janitor,
		/obj/item/organ/internal/cyberimp/arm/item_set/atmospherics,
		/obj/item/organ/internal/cyberimp/arm/item_set/combat,
		/obj/item/organ/internal/cyberimp/arm/item_set/botany,
		/obj/item/organ/internal/cyberimp/arm/item_set/barber,
		/obj/item/organ/internal/cyberimp/arm/item_set/synth_repair,
		/obj/item/organ/internal/cyberimp/arm/item_set/gun/taser,
		/obj/item/organ/internal/cyberimp/arm/item_set/mining_drill,
		/obj/item/organ/internal/cyberimp/arm/item_set/paramedic,
		/obj/item/organ/internal/cyberimp/arm/item_set/cook,
		/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/chest/thrusters,
		/obj/item/organ/internal/cyberimp/chest/reviver,
		/obj/item/organ/internal/eyes/robotic/glow,
		/obj/item/organ/internal/eyes/robotic/shield,
		/obj/item/organ/internal/ears/cybernetic/whisper,
		/obj/item/organ/internal/ears/cybernetic/xray,
		
		/obj/item/organ/internal/cyberimp/chest/sandevistan/refurbished,
		/obj/item/organ/internal/cyberimp/chest/knockout,
		/obj/item/organ/internal/cyberimp/chest/chemvat,
		/obj/item/organ/internal/cyberimp/chest/dualwield/refurbished,
		/obj/item/organ/internal/cyberimp/arm/ammo_counter,
		/obj/item/organ/internal/cyberimp/arm/strongarm,
		/obj/item/organ/internal/cyberimp/leg/table_glider,
		/obj/item/organ/internal/cyberimp/leg/shove_resist,
		/obj/item/organ/internal/cyberimp/leg/accelerator,
		/obj/item/organ/internal/cyberimp/leg/chemplant/drugs,
		/obj/item/organ/internal/cyberimp/leg/chemplant/emergency
	)
	var/box = new /obj/item/storage/box(altar_turf)
	for(var/items in 1 to 5)
		var/item = pick(blessing)
		new item(box)

	return TRUE

/datum/religion_rites/autosurgeon
	name = "Holy Autosurgeon"
	desc = "Receive a blessed autosurgeon able to instantly perform implantation of cybernetics into an android."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "The machine is perfect.",
							"...It can be changed to adapt to anything!")
	invoke_msg = "We will survive anything!"
	favor_cost = 250

/datum/religion_rites/autosurgeon/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/item/autosurgeon/holy(altar_turf)
	return TRUE
