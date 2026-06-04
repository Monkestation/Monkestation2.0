/datum/quirk/stowaway
	name = "Stowaway"
	desc = "You wake up inside a random locker with only a crude fake for an ID card."
	value = -2
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_HIDE_FROM_SCAN
	icon = FA_ICON_SUITCASE

/datum/quirk/stowaway/add_unique()
	var/mob/living/carbon/human/stowaway = quirk_holder
	if(prob(20))
		stowaway.adjust_drunk_effect(50) //What did I DO last night?
	var/obj/structure/closet/selected_closet = get_unlocked_closed_locker() //Find your new home
	if(selected_closet)
		stowaway.forceMove(selected_closet) //Move in
		stowaway.Sleeping(5 SECONDS)

/datum/quirk/stowaway/post_add()
	var/mob/living/carbon/human/stowaway = quirk_holder
	stowaway.delete_equipment()
	stowaway.equip_outfit_and_loadout(/datum/outfit/job/stowaway, stowaway.client.prefs, FALSE, /datum/job/stowaway) //Loadout items and stowaway gear

	var/obj/item/card/id/realid = stowaway.get_item_by_slot(ITEM_SLOT_ID) //No ID
	qdel(realid)

	var/obj/item/card/id/fake_card/card = new(quirk_holder.drop_location()) //a fake ID with two uses for maint doors
	quirk_holder.equip_to_slot_if_possible(card, ITEM_SLOT_ID)
	card.register_name(quirk_holder)
	to_chat(quirk_holder, span_boldnotice("You've awoken to find yourself inside [GLOB.station_name] without real identification!"))
	force_stowaway_unassigned_role(quirk_holder, quirk_holder.client)
	return_stowaway_heirloom(quirk_holder)

/obj/item/card/id/fake_card //not a proper ID but still shares a lot of functions
	name = "\"ID Card\""
	desc = "Definitely a legitimate ID card and not a piece of notebook paper with a magnetic strip drawn on it. You'd have to stuff this in a card reader by hand for it to work."
	icon = 'icons/obj/card.dmi'
	icon_state = "counterfeit"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	resistance_flags = FIRE_PROOF | ACID_PROOF
	registered_account = null
	create_bank_on_init = FALSE
	accepts_accounts = FALSE
	registered_name = "Nobody"
	access = list(ACCESS_MAINT_TUNNELS)
	///How many doors the fake card can open before it becomes completely torn up.
	var/uses = 2

/obj/item/card/id/fake_card/proc/register_name(mob/living/carbon/human/quirk_holder)
	registered_name = quirk_holder.real_name
	name = "[quirk_holder.real_name]'s \"ID Card\""
	assignment = "Stowaway"

/obj/item/card/id/fake_card/proc/used()
	uses--
	switch(uses)
		if(0)
			icon_state = "counterfeit_torn2"
		if(1)
			icon_state = "counterfeit_torn"
		else
			icon_state = "counterfeit" //in case you somehow repair it to 3+

//No access to give, airlocks use snowflake check to work otherwise.
/obj/item/card/id/fake_card/retrieve_access(datum/source, list/player_access)
	return

/obj/item/card/id/fake_card/click_alt(mob/living/user)
	return CLICK_ACTION_BLOCKING //no accounts on fake cards

/obj/item/card/id/fake_card/examine(mob/user)
	. = ..()
	switch(uses)
		if(0)
			. += "It's too shredded to fit in a scanner!"
		if(1)
			. += "It's falling apart!"
		else
			. += "It looks frail!"
//OCULIS PORT START: Removes job assignment and handles latejoin stowaways
/proc/is_stowaway(mob/living/carbon/human/person, client/person_client)
	if(!person)
		return FALSE

	var/client/target_client = person_client || person.client
	var/list/all_quirks = target_client?.prefs.all_quirks

	return person.has_quirk(/datum/quirk/stowaway) || (all_quirks && ("Stowaway" in all_quirks))

/proc/force_stowaway_unassigned_role(mob/living/carbon/human/person, client/person_client)
	if(!person?.mind || is_unassigned_job(person.mind.assigned_role))
		return

	var/datum/job/previous_role = person.mind.assigned_role
	if(previous_role?.title)
		SSjob.FreeRole(previous_role.title)

	person.mind.set_assigned_role(SSjob.GetJobType(/datum/job/stowaway))
	person.job = JOB_STOWAWAY

/proc/process_stowaway_latejoin(mob/living/carbon/human/person, datum/job/current_job, client/person_client)
	if(!person?.mind || !is_stowaway(person, person_client))
		return

	if((current_job?.job_flags & JOB_ASSIGN_QUIRKS) && CONFIG_GET(flag/roundstart_traits))
		SSquirks.AssignQuirks(person, person_client)

	force_stowaway_unassigned_role(person, person_client)

//OCULIS PORT END

/proc/return_stowaway_heirloom(mob/living/carbon/human/stowaway) //reset family heirloom real quick so it respawns
	if(!stowaway.has_quirk(/datum/quirk/item_quirk/family_heirloom))
		return
	stowaway.remove_quirk(/datum/quirk/item_quirk/family_heirloom)
	stowaway.add_quirk(/datum/quirk/item_quirk/family_heirloom)


