/obj/machinery/cassette/mailbox
	name = "Space Board of Music Postbox"
	desc = "Has a slit specifically to fit cassettes into it."

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "postbox"

	max_integrity = 100000 //lol
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	density = TRUE

/obj/machinery/cassette/mailbox/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	AddComponent(/datum/component/hovering_information, /datum/hover_data/mailbox)

/obj/machinery/cassette/mailbox/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/device/cassette_tape))
		return NONE
	balloon_alert(user, "cassette submissions are currently suspended!")
	return ITEM_INTERACT_SUCCESS

/datum/hover_data/mailbox
	var/obj/effect/overlay/hover/text_holder

/datum/hover_data/mailbox/Destroy(force)
	. = ..()
	QDEL_NULL(text_holder)

/datum/hover_data/mailbox/New(datum/component/hovering_information, atom/parent)
	. = ..()
	text_holder = new(null)
	text_holder.maptext = MAPTEXT("<span style='text-align:center'>Cassette submissions are currently suspended, sorry!</span>")
	text_holder.maptext_width = 96
	text_holder.maptext_y = 32
	text_holder.maptext_x = -32

/datum/hover_data/mailbox/setup_data(obj/machinery/source, mob/enterer)
	. = ..()
	var/image/new_image = new(text_holder.appearance)
	SET_PLANE_EXPLICIT(new_image, new_image.plane, source)
	new_image.loc = source
	add_client_image(new_image, enterer.client)
