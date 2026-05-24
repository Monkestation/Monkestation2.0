/datum/religion_sect/honk
	name = "The Clowns"
	quote = "A sect dedicated to the Honkmother"
	desc = "The Honkmother welcomes you to the party, prankster. Sacrifice bananas to power our pranks and grant you favor."
	tgui_icon = "bullhorn"
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/food/grown/banana)
	rites_list = list(/datum/religion_rites/holypie, /datum/religion_rites/honkabot, /datum/religion_rites/clownify, /datum/religion_rites/bananablessing, /datum/religion_rites/honk_mech)
	altar_icon_state = "convertaltar-red"

/datum/religion_sect/honk/on_conversion(mob/living/chap)
	. = ..()
	for(var/obj/item/to_strip in chap)
		chap.dropItemToGround(to_strip)
	chap.dress_up_as_job(SSjob.GetJobType(/datum/job/clown))

// only works on clumsy people and clowns
/datum/religion_sect/honk/sect_bless(mob/living/blessed, mob/living/user)
	if(!ishuman(blessed))
		return
	var/mob/living/carbon/human/H = blessed
	var/datum/mind/M = H.mind
	if(M.assigned_role != "Clown" || !HAS_TRAIT(user, TRAIT_CLUMSY))
		return

	var/heal_amt = 10 // should probably lessen
	if(H.getBruteLoss() > 0 || H.getFireLoss() > 0)
		H.heal_overall_damage(heal_amt, heal_amt, 0)
		H.update_damage_overlays()

	H.visible_message(span_notice("[user] heals [H] with the power of [GLOB.deity]!"))
	to_chat(H, span_boldnotice("The radiance of [GLOB.deity] heals you!"))
	playsound(user, "sound/miscitems/bikehorn.ogg", 25, TRUE, -1)
	H.add_mood_event("honk", /datum/mood_event/honk)
	return TRUE

/datum/religion_sect/honk/on_sacrifice(/obj/item/food/grown/banana/offering, mob/living/user)
	adjust_favor(25, user)
	to_chat(user, span_notice("HONK"))
	qdel(offering)
	return TRUE

/datum/religion_rites/holypie
	name = "Holy Pie"
	desc = "Creates a cream pie to throw at others"
	ritual_length = 10 SECONDS
	invoke_msg = "Oh, Honkmother, grant us the pie to cream the faces of the people."
	favor_cost = 100

/datum/religion_rites/holypie/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/item/food/pie/cream (altar_turf)
	playsound(altar_turf, 'sound/items/bikehorn.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/honkabot
	name = "Honk a Bot"
	desc = "Summons a Honkbot to bring honking to the station"
	ritual_length = 15 SECONDS
	invoke_msg = "Great Honkmother, hear my pray: HONK!"
	favor_cost = 200

/datum/religion_rites/honkabot/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /mob/living/simple_animal/bot/secbot/honkbot(altar_turf)
	return TRUE

/datum/religion_rites/clownify
	name = "Clown Conversion"
	desc = "Turn yourself or a buckle person into a clown"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"I pray to the Honkmother to hear my pleas...",
		"...Bring us the power to entertain our allies...",
		"...And merciless prank our enemies...",
	)
	invoke_msg = "Show the true power of clownkind!"
	favor_cost = 500

/datum/religion_rites/clownify/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("You're going to convert the one buckled on [movable_reltool]."))
	else if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	to_chat(user, span_warning("You're going to convert yourself with this ritual."))
	return ..()

/datum/religion_rites/clownify/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!length(movable_reltool?.buckled_mobs))
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	for(var/obj/item/to_strip in rite_target)
		rite_target.dropItemToGround(to_strip)
	rite_target.dress_up_as_job(SSjob.GetJobType(/datum/job/clown))
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE

/datum/religion_rites/bananablessing
	name = "Banana Blessing"
	desc = "Creates a piece of bananium to further the clown researches"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"I pray to the Honkmother to hear my pleas...",
		"...Bring us the power to entertain our allies...",
		"...And merciless prank our enemies...",
	)
	invoke_msg = "Show the true power of clownkind!"
	favor_cost = 1000

/datum/religion_rites/bananablessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/item/stack/sheet/mineral/bananium (altar_turf)
	playsound(altar_turf, 'sound/items/bikehorn.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/honk_mech
	name = "Summon Honkmech"
	desc = "H.O.N.K"
	ritual_length = 6.7 SECONDS
	invoke_msg = "OH THANK YOU GREAT HONK MOTHER FOR MAKING THIS POSSIBLE!!" // I don't see how you'd do this without 'honk mothers' help
	favor_cost = 10001 // Intentionally one more than the max, because I think thats really funny, you can already make a honk mech by this point if you just summon pure bananium.

/datum/religion_rites/honk_mech/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/vehicle/sealed/mecha/honker/loaded (altar_turf)
	playsound(altar_turf, 'sound/items/party_horn.ogg', 50, TRUE)
	return TRUE
