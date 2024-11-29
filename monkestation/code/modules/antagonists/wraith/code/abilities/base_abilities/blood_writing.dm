#define RANDOM_GRAFFITI "Random Graffiti"
#define RANDOM_LETTER "Random Letter"
#define RANDOM_PUNCTUATION "Random Punctuation"
#define RANDOM_NUMBER "Random Number"
#define RANDOM_SYMBOL "Random Symbol"
#define RANDOM_DRAWING "Random Drawing"
#define RANDOM_ANY "Random Anything"

/obj/effect/decal/cleanable/crayon/wraith
	alpha = 0

/obj/effect/decal/cleanable/crayon/wraith/Initialize(mapload)
	. = ..()
	desc = "A [name] drawn in what seems to be blood."
	animate(src, 3 SECONDS, alpha = 255)

/**
 * Allows you to draw symbols and letters on the floor.
 * Very shameless crayon copy-paste, sue me.
 */
/datum/action/cooldown/spell/pointed/wraith/blood_writing
	name = "Blood Writing"
	desc = "Allows you to write symbols on the floor using blood."
	button_icon_state = "blood_writing"

	essence_cost = 2
	cooldown_time = 1 SECOND

	unset_after_click = FALSE
	aim_assist = FALSE

	var/drawtype
	var/text_buffer = ""

	var/static/list/graffiti = list(
		"body",
		"face",
		"guy",
	)

	var/static/list/symbols = list(
		"danger",
		"heart",
		"like",
		"nay",
		"peace",
		"safe",
		"skull",
		"space",
		"trade",
	)

	var/static/list/drawings = list(
		"smallbrush",
		"brush",
		"largebrush",
		"clown",
		"ghost",
	)

	/// List of selectable random options
	var/static/list/randoms = list(
		RANDOM_ANY,
		RANDOM_DRAWING,
		RANDOM_GRAFFITI,
		RANDOM_LETTER,
		RANDOM_NUMBER,
		RANDOM_PUNCTUATION,
		RANDOM_SYMBOL,
	)

	var/static/list/all_drawables = graffiti + symbols + drawings

/datum/action/cooldown/spell/pointed/wraith/blood_writing/ui_state(mob/user)
	return GLOB.always_state

/datum/action/cooldown/spell/pointed/wraith/blood_writing/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrayonWraith", name)
		ui.open()

/datum/action/cooldown/spell/pointed/wraith/blood_writing/ui_data()
	var/static/list/blood_drawables
	if(!blood_drawables)
		blood_drawables = staticDrawables()

	. = list()
	.["drawables"] = blood_drawables
	.["selected_stencil"] = drawtype
	.["text_buffer"] = text_buffer

/datum/action/cooldown/spell/pointed/wraith/blood_writing/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_stencil")
			var/stencil = params["item"]
			if(stencil in (all_drawables + randoms))
				drawtype = stencil
				. = TRUE
				text_buffer = ""
		if("enter_text")
			var/txt = tgui_input_text(usr, "Choose what to write", "Scribbles", text_buffer)
			if(isnull(txt))
				return
			txt = crayon_text_strip(txt)
			if(text_buffer == txt)
				return // No valid changes.
			text_buffer = txt

			. = TRUE
			drawtype = "a"

/datum/action/cooldown/spell/pointed/wraith/blood_writing/proc/crayon_text_strip(text) // Yes, the proc name is intentional
	text = copytext(text, 1, MAX_MESSAGE_LEN)
	var/static/regex/crayon_regex = new /regex(@"[^\w!?,.=&%#+/\-]", "ig")
	return lowertext(crayon_regex.Replace(text, ""))

/datum/action/cooldown/spell/pointed/wraith/blood_writing/proc/staticDrawables()
	. = list()

	var/list/g_items = list()
	. += list(list("name" = "Graffiti", "items" = g_items))
	for(var/g in graffiti)
		g_items += list(list("item" = g))

	var/list/S_items = list()
	. += list(list("name" = "Symbols", "items" = S_items))
	for(var/S in symbols)
		S_items += list(list("item" = S))

	var/list/D_items = list()
	. += list(list("name" = "Drawings", "items" = D_items))
	for(var/D in drawings)
		D_items += list(list("item" = D))

/datum/action/cooldown/spell/pointed/wraith/blood_writing/on_activation(atom/cast_on)
	. = ..()
	ui_interact(owner)

/datum/action/cooldown/spell/pointed/wraith/blood_writing/before_cast(atom/cast_on)
	. = ..()
	if(!isturf(cast_on))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/blood_writing/cast(turf/cast_on)
	. = ..()
	var/static/list/punctuation = list("!","?",".",",","/","+","-","=","%","#","&")

	var/drawing = drawtype
	switch(drawtype)
		if(RANDOM_LETTER)
			drawing = ascii2text(rand(97, 122)) // a-z
		if(RANDOM_PUNCTUATION)
			drawing = pick(punctuation)
		if(RANDOM_SYMBOL)
			drawing = pick(symbols)
		if(RANDOM_DRAWING)
			drawing = pick(drawings)
		if(RANDOM_GRAFFITI)
			drawing = pick(graffiti)
		if(RANDOM_NUMBER)
			drawing = ascii2text(rand(48, 57)) // 0-9
		if(RANDOM_ANY)
			drawing = pick(all_drawables)

	var/temp = "rune"
	var/ascii = (length(drawing) == 1)
	if(ascii && is_alpha(drawing))
		temp = "letter"
	else if(ascii && is_digit(drawing))
		temp = "number"
	else if(drawing in punctuation)
		temp = "punctuation mark"
	else if(drawing in symbols)
		temp = "symbol"
	else if(drawing in drawings)
		temp = "drawing"
	else if(drawing in graffiti)
		temp = "graffiti"

	if(length(text_buffer))
		drawing = text_buffer[1]

	var/obj/effect/decal/cleanable/crayon/wraith/created_art
	created_art = new(cast_on, "#FF0000", drawing, temp)
	created_art.add_fingerprint(owner)

	if(length(text_buffer) > 1)
		text_buffer = copytext(text_buffer, length(text_buffer[1]) + 1)
		SStgui.update_uis(src)

#undef RANDOM_GRAFFITI
#undef RANDOM_LETTER
#undef RANDOM_PUNCTUATION
#undef RANDOM_SYMBOL
#undef RANDOM_DRAWING
#undef RANDOM_NUMBER
#undef RANDOM_ANY
