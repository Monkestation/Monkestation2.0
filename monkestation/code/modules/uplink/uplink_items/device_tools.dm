/datum/uplink_item/device_tools/tram_remote
	surplus = 40

/datum/uplink_item/device_tools/rad_laser
	surplus = 40

/datum/uplink_item/device_tools/hacked_linked_surgery
	name = "Syndicate Surgery Implant"
	desc = "A powerful brain implant, capable of uploading perfect, forbidden surgical knowledge to its users mind, \
		allowing them to do just about any surgery, anywhere, without making any (unintentional) mistakes. \
		Comes with a syndicate autosurgeon for immediate self-application."
	cost = 12
	item = /obj/item/autosurgeon/syndicate/hacked_linked_surgery
	surplus = 50

/datum/uplink_item/device_tools/compressionkit
	name = "Bluespace Compression Kit"
	desc = "A modified version of a BSRPED that can be used to reduce the size of most items while retaining their original functions! \
			Does not work on storage items. \
			Recharge using bluespace crystals. \
			Comes with 5 charges."
	item = /obj/item/compression_kit
	cost = 4

/datum/uplink_item/device_tools/polyglot_voicebox
	name = "Syndicate Polyglot Voicebox"
	desc = "A polyglot voicebox which, after replacing the user's tongue will allow them to emulate \
			the tongue of any species. \
			WARNING: The polyglot voicebox does not allow you to speak additional languages"
	cost = 2
	item = /obj/item/autosurgeon/syndicate/polyglot_voicebox
	surplus = 25

/datum/uplink_item/device_tools/autosurgeon
	name = "Syndicate Autosurgeon"
	desc = "A multi-use autosurgeon for implanting whatever you want into yourself. Rip that station apart and make it part of you."
	item = /obj/item/autosurgeon/syndicate
	cost = 5

/datum/uplink_item/device_tools/clonekit
	name = "Clone Army Kit"
	desc = "Everything you need for a clone army, armaments not included."
	progression_minimum = 5 MINUTES
	cost = 20
	item = /obj/item/storage/box/clonearmy

///I know this probably isn't the right place to put it, but I don't know where I should put it, and I can move it later.
/obj/item/disk/clonearmy
	name = "DNA data disk" //Cunning disguise.
	var/objective = ""
	icon_state = "datadisk0"

/obj/item/disk/clonearmy/Initialize(mapload)
	. = ..()
	icon_state = "datadisk[rand(0,7)]"
	add_overlay("datadisk_gene")

/obj/item/disk/clonearmy/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter a directive for the evil clones.", "Clone Directive Entry", objective, CONFIG_GET(number/max_law_len), TRUE)
	if(!targName)
		return
	if(is_ic_filtered(targName))
		to_chat(user, span_warning("Error: Directive contains invalid text."))
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(targName)
	if(soft_filter_result)
		if(tgui_alert(user,"Your directive contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for a clone directive. Directive: \"[html_encode(targName)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for a clone directive. Directive: \"[targName]\"")
	objective = targName
	..()

/obj/item/disk/clonearmy/attack()
	return

/obj/item/disk/clonearmy/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!istype(A, /obj/machinery/clonepod/experimental))
		return
	to_chat(user, "You upload the directive to the experimental cloner.")
	var/obj/machinery/clonepod/experimental/pod = target
	pod.custom_objective = objective
	pod.RefreshParts()
	pod.locked = TRUE // The pod shouldn't be eligible for cloner event.
