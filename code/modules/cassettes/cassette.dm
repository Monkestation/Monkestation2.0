
/obj/item/cassette_tape
	name = "Debug Cassette Tape"
	desc = "You shouldn't be seeing this!"
	icon = 'icons/obj/cassettes/walkman.dmi'
	icon_state = "cassette_flip"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	hitsound = SFX_CASSETTE_ASMR
	drop_sound = SFX_CASSETTE_ASMR
	pickup_sound = SFX_CASSETTE_ASMR
	usesound = SFX_CASSETTE_ASMR
	mob_throw_hit_sound = SFX_CASSETTE_DUMP
	block_sound = SFX_CASSETTE_DUMP
	equip_sound = SFX_CASSETTE_ASMR

	/// If the cassette is flipped, for playing second list of songs.
	var/flipped = FALSE
	/// The data for this cassette.
	var/datum/cassette/cassette_data
	/// Should we just spawn a random cassette?
	var/random = FALSE
	/// ID of the cassette to spawn in as by default.
	var/id

/obj/item/cassette_tape/Initialize(mapload, spawned_id)
	..()
	if(spawned_id)
		id = spawned_id
	return INITIALIZE_HINT_LATELOAD

/obj/item/cassette_tape/LateInitialize()
	if(id)
		cassette_data = SScassettes.load_cassette(id)
	else if(random)
		var/list/random_cassette = SScassettes.unique_random_cassettes(amount = 1, status = CASSETTE_STATUS_APPROVED)
		if(length(random_cassette))
			cassette_data = random_cassette[1]
	cassette_data ||= new
	update_appearance(UPDATE_DESC | UPDATE_ICON_STATE)

/obj/item/cassette_tape/Destroy(force)
	cassette_data = null
	return ..()

/obj/item/cassette_tape/attack_self(mob/user)
	. = ..()
	flipped = !flipped
	to_chat(user, span_notice("You flip [src]."))
	playsound(src, SFX_CASSETTE_ASMR, 50, FALSE)

	update_appearance(UPDATE_ICON_STATE)

/obj/item/cassette_tape/update_desc(updates)
	desc = cassette_data.desc || "A generic cassette."
	return ..()

/obj/item/cassette_tape/update_icon_state()
	icon_state = cassette_data.get_side(!flipped)?.design || src::icon_state
	return ..()

/obj/item/cassette_tape/examine(mob/user)
	. = ..()
	switch(cassette_data.status)
		if(CASSETTE_STATUS_UNAPPROVED)
			. += span_warning("It appears to be a bootleg tape, quality is not a guarantee!")
			. += span_notice("In order to play this tape for the whole station, it must be submitted to the Space Board of Music and approved.")
		if(CASSETTE_STATUS_REVIEWING)
			. += span_warning("It seems this tape is still being reviewed by the Space Board of Music.")
		if(CASSETTE_STATUS_APPROVED)
			. += span_info("This cassette has been approved by the Space Board of Music, and can be played for the whole station with the Cassette Player.")
		else
			stack_trace("Unknown status [cassette_data.status] for cassette [cassette_data.name] ([cassette_data.id])")

	if(cassette_data.author.name)
		. += span_info("Mixed by [span_name(cassette_data.author.name)]")

/obj/item/cassette_tape/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/pen))
		return NONE
	var/choice = tgui_input_list(user, "What would you like to change?", items = list("Cassette Name", "Cassette Description", "Cancel"))
	switch(choice)
		if("Cassette Name")
			///the name we are giving the cassette
			var/newcassettename = reject_bad_text(tgui_input_text(user, "Write a new Cassette name:", name, html_decode(name), max_length = MAX_NAME_LEN))
			if(!user.can_perform_action(src, TRUE))
				return ITEM_INTERACT_BLOCKING
			if(length_char(newcassettename) > MAX_NAME_LEN)
				to_chat(user, span_warning("That name is too long!"))
				return ITEM_INTERACT_BLOCKING
			if(!newcassettename)
				to_chat(user, span_warning("That name is invalid."))
				return ITEM_INTERACT_BLOCKING
			name = "[lowertext(newcassettename)]"
			return ITEM_INTERACT_SUCCESS
		if("Cassette Description")
			///the description we are giving the cassette
			var/newdesc = tgui_input_text(user, "Write a new description:", name, html_decode(desc), max_length = 180)
			if(!user.can_perform_action(src, TRUE))
				return ITEM_INTERACT_BLOCKING
			if (length_char(newdesc) > 180)
				to_chat(user, span_warning("That description is too long!"))
				return ITEM_INTERACT_BLOCKING
			if(!newdesc)
				to_chat(user, span_warning("That description is invalid."))
				return ITEM_INTERACT_BLOCKING
			cassette_data.desc = newdesc
			update_appearance(UPDATE_DESC)
			return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING


/obj/item/cassette_tape/blank
//	id = "blank"

/obj/item/cassette_tape/friday
	id = "friday"
