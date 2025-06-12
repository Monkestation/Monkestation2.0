
/obj/item/cassette_tape
	name = "Debug Cassette Tape"
	desc = "You shouldn't be seeing this!"
	icon = 'monkestation/code/modules/cassettes/icons/walkman.dmi'
	icon_state = "cassette_flip"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	/// If the cassette is flipped, for playing second list of songs.
	var/flipped = FALSE
	/// The data for this cassette.
	var/datum/cassette/cassette_data
	/// Should we just spawn a random cassette?
	var/random = FALSE
	/// ID of the cassette to spawn in as by default.
	var/id

/obj/item/cassette_tape/Initialize(mapload, spawned_id)
	. = ..()
	spawned_id ||= id
	if(!isnull(spawned_id))
		cassette_data = SScassettes.load_cassette(spawned_id)
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

/obj/item/cassette_tape/attackby(obj/item/item, mob/living/user)
	if(!istype(item, /obj/item/pen))
		return ..()
	var/choice = tgui_input_list(user, "What would you like to change?", items = list("Cassette Name", "Cassette Description", "Cancel"))
	switch(choice)
		if("Cassette Name")
			///the name we are giving the cassette
			var/newcassettename = reject_bad_text(tgui_input_text(user, "Write a new Cassette name:", name, html_decode(name), max_length = MAX_NAME_LEN))
			if(!user.can_perform_action(src, TRUE))
				return
			if(length(newcassettename) > MAX_NAME_LEN)
				to_chat(user, span_warning("That name is too long!"))
				return
			if(!newcassettename)
				to_chat(user, span_warning("That name is invalid."))
				return
			else
				name = "[lowertext(newcassettename)]"
		if("Cassette Description")
			///the description we are giving the cassette
			var/newdesc = tgui_input_text(user, "Write a new description:", name, html_decode(desc), max_length = 180)
			if(!user.can_perform_action(src, TRUE))
				return
			if (length(newdesc) > 180)
				to_chat(user, span_warning("That description is too long!"))
				return
			if(!newdesc)
				to_chat(user, span_warning("That description is invalid."))
				return
			cassette_data.desc = newdesc
			update_appearance(UPDATE_DESC)

/obj/item/cassette_tape/blank
	id = "blank"

/obj/item/cassette_tape/friday
	id = "friday"
