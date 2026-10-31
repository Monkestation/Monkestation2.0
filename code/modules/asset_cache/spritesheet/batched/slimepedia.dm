/datum/asset/spritesheet_batched/slimepedia
	name = "slimepedia"

/datum/asset/spritesheet_batched/slimepedia/create_spritesheets()
	var/slime_icon = 'icons/mob/simple/slimes.dmi'
	var/datum/universal_icon/face = uni_icon(slime_icon, "aslime-[SLIME_MOOD_SMILE]")
	for(var/datum/slime_type/slime_type as anything in subtypesof(/datum/slime_type))
		var/prefix = slime_icon_prefix(slime_type)
		var/datum/universal_icon/body = uni_icon(slime_icon, "[prefix]-adult")
		insert_icon("slime-[prefix]", body.blend_icon(face, ICON_OVERLAY))
		var/obj/item/slime_extract/extract = slime_type::core_type
		insert_icon("extract-[prefix]", uni_icon(extract::icon, extract::icon_state))

	for(var/key in GLOB.slime_crossbreeds)
		var/obj/item/slimecross/cross_path = GLOB.slime_crossbreeds[key]
		var/datum/slime_type/slime_type = cross_path::slime_type
		var/datum/universal_icon/cross_icon = uni_icon(cross_path::icon, cross_path::icon_state)
		if(slime_type::crossbreed_color)
			cross_icon.blend_color(slime_type::crossbreed_color, ICON_MULTIPLY)
		insert_icon("cross-[cross_path::effect]-[slime_icon_prefix(slime_type)]", cross_icon)
