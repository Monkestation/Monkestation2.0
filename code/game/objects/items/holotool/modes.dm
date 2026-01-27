/datum/holotool_mode
	var/name = ""
	var/sound
	var/behavior
	var/sharpness
	var/speed = 1.2 // 20% worse than regular tools by default
	var/requires_emag = FALSE

/datum/holotool_mode/proc/on_set(obj/item/holotool/holotool)
	holotool.usesound = sound ? sound : 'sound/items/pshoom.ogg'
	holotool.toolspeed = speed ? speed : 1
	holotool.tool_behaviour = behavior ? behavior : null
	holotool.sharpness = sharpness ? sharpness : NONE

/datum/holotool_mode/proc/on_unset(obj/item/holotool/holotool)
	holotool.usesound = initial(holotool.usesound)
	holotool.toolspeed = initial(holotool.toolspeed)
	holotool.tool_behaviour = initial(holotool.tool_behaviour)
	holotool.sharpness = initial(holotool.sharpness)

////////////////////////////////////////////////

// NAME USED FOR OVERLAYS, MAKE SURE IT MATCHES
/datum/holotool_mode/off
	name = "off"
	sound = 'sound/items/holotool.ogg'

/datum/holotool_mode/screwdriver
	name = "holo-screwdriver"
	sound = 'sound/items/holotool.ogg'
	behavior = TOOL_SCREWDRIVER
	sharpness = SHARP_POINTY

/datum/holotool_mode/crowbar
	name = "holo-crowbar"
	sound = 'sound/items/holotool.ogg'
	behavior = TOOL_CROWBAR

/datum/holotool_mode/multitool
	name = "holo-multitool"
	sound = 'sound/items/holotool.ogg'
	behavior = TOOL_MULTITOOL

/datum/holotool_mode/wrench
	name = "holo-wrench"
	sound = 'sound/items/holotool.ogg'
	behavior = TOOL_WRENCH

/datum/holotool_mode/wirecutters
	name = "holo-wirecutters"
	sound = 'sound/items/holotool.ogg'
	behavior = TOOL_WIRECUTTER

/datum/holotool_mode/welder
	name = "holo-welder"
	sound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')//so it actually gives the expected feedback from welding
	behavior = TOOL_WELDER

/datum/holotool_mode/welder/on_set(obj/item/holotool/holotool)
	..()
	holotool.AddElement(/datum/element/tool_flash, holotool.light_outer_range)

/datum/holotool_mode/welder/on_unset(obj/item/holotool/holotool)
	..()
	holotool.RemoveElement(/datum/element/tool_flash, holotool.light_outer_range)

////////////////////////////////////////////////

/datum/holotool_mode/knife
	name = "holo-knife"
	sound = 'sound/weapons/blade1.ogg'
	sharpness = SHARP_EDGED
	requires_emag = TRUE

/datum/holotool_mode/knife/on_set(obj/item/holotool/holotool)
	..()
	holotool.force = 17
	holotool.attack_verb_continuous = list("sliced", "torn", "cut")
	holotool.armour_penetration = 45
	holotool.embedding = list("embed_chance" = 40, "embedded_fall_chance" = 0, "embedded_pain_multiplier" = 5)
	holotool.hitsound = 'sound/weapons/blade1.ogg'

/datum/holotool_mode/knife/on_unset(obj/item/holotool/holotool)
	..()
	holotool.force = initial(holotool.force)
	holotool.attack_verb_continuous = initial(holotool.attack_verb_continuous)
	holotool.armour_penetration = initial(holotool.armour_penetration)
	holotool.embedding = initial(holotool.embedding)
	holotool.hitsound = initial(holotool.hitsound)
