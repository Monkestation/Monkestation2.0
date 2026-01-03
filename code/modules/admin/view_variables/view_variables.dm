#define ICON_STATE_CHECKED 1 /// this dmi is checked. We don't check this one anymore.
#define ICON_STATE_NULL 2 /// this dmi has null-named icon_state, allowing it to show a sprite on vv editor.

ADMIN_VERB_AND_CONTEXT_MENU(debug_variables, R_NONE, FALSE, "View Variables", "View the variables of a datum.", ADMIN_CATEGORY_DEBUG, datum/thing in world)
	user.debug_variables(thing)

// This is kept as a seperate proc because admins are able to show VV to non-admins
/client/proc/debug_variables(datum/thing in world)
	set category = "Debug"
	set name = "View Variables"
	//set src in world
	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!usr.client || !usr.client.holder) //This is usr because admins can call the proc on other clients, even if they're not admins, to show them VVs.
		to_chat(usr, span_danger("You need to be an administrator to access this."), confidential = TRUE)
		return

	if(!thing)
		return

	var/datum/asset/asset_cache_datum = get_asset_datum(/datum/asset/simple/vv)
	asset_cache_datum.send(usr)

	if(isappearance(thing))
		thing = get_vv_appearance(thing) // this is /mutable_appearance/our_bs_subtype
	var/islist = islist(thing) || (!isdatum(thing) && hascall(thing, "Cut")) // Some special lists dont count as lists, but can be detected by if they have list procs
	if(!islist && !isdatum(thing))
		return

	var/title = ""
	var/refid = REF(thing)
	var/icon/sprite
	var/hash

	var/type = islist ? /list : thing.type
	var/no_icon = FALSE

	if(isatom(thing))
		sprite = getFlatIcon(thing)
		if(!sprite)
			no_icon = TRUE

	else if(isimage(thing))
		// icon_state=null shows first image even if dmi has no icon_state for null name.
		// This list remembers which dmi has null icon_state, to determine if icon_state=null should display a sprite
		// (NOTE: icon_state="" is correct, but saying null is obvious)
		var/static/list/dmi_nullstate_checklist = list()
		var/image/image_object = thing
		var/icon_filename_text = "[image_object.icon]" // "icon(null)" type can exist. textifying filters it.
		if(icon_filename_text)
			if(image_object.icon_state)
				sprite = icon(image_object.icon, image_object.icon_state)

			else // it means: icon_state=""
				if(!dmi_nullstate_checklist[icon_filename_text])
					dmi_nullstate_checklist[icon_filename_text] = ICON_STATE_CHECKED
					if("" in icon_states(image_object.icon))
						// this dmi has nullstate. We'll allow "icon_state=null" to show image.
						dmi_nullstate_checklist[icon_filename_text] = ICON_STATE_NULL

				if(dmi_nullstate_checklist[icon_filename_text] == ICON_STATE_NULL)
					sprite = icon(image_object.icon, image_object.icon_state)

	var/sprite_text
	if(sprite)
		hash = md5(sprite)
		src << browse_rsc(sprite, "vv[hash].png")
		sprite_text = no_icon ? "\[NO ICON\]" : "<img src='vv[hash].png'></td><td>"

	title = "[thing] ([REF(thing)]) = [type]"
	var/formatted_type = replacetext("[type]", "/", "<wbr>/")

	var/list/header = islist ? list("<b>/list</b>") : thing.vv_get_header()

	var/ref_line = "@[copytext(refid, 2, -1)]" // get rid of the brackets, add a @ prefix for copy pasting in asay

	var/marked_line
	if(holder && holder.marked_datum && holder.marked_datum == thing)
		marked_line = VV_MSG_MARKED
	var/tagged_line
	if(holder && LAZYFIND(holder.tagged_datums, thing))
		var/tag_index = LAZYFIND(holder.tagged_datums, thing)
		tagged_line = VV_MSG_TAGGED(tag_index)
	var/varedited_line
	if(!islist && (thing.datum_flags & DF_VAR_EDITED))
		varedited_line = VV_MSG_EDITED
	var/deleted_line
	if(!islist && thing.gc_destroyed)
		deleted_line = VV_MSG_DELETED

	var/list/dropdownoptions
	if (islist)
		dropdownoptions = list(
			"---",
			"Add Item" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ADD),
			"Remove Nulls" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_NULLS),
			"Remove Dupes" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_DUPES),
			"Set len" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SET_LENGTH),
			"Shuffle" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SHUFFLE),
			"Show VV To Player" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_EXPOSE),
			"---"
			)
		for(var/i in 1 to length(dropdownoptions))
			var/name = dropdownoptions[i]
			var/link = dropdownoptions[name]
			dropdownoptions[i] = "<option value[link? "='[link]'":""]>[name]</option>"
	else
		dropdownoptions = thing.vv_get_dropdown()

	var/list/names = list()
	if(!islist)
		for(var/varname in thing.vars)
			names += varname

	sleep(1 TICKS)

	var/ui_scale = prefs?.read_preference(/datum/preference/toggle/ui_scale)

	var/list/variable_html = list()
	if(islist)
		var/list/list_value = thing
		for(var/i in 1 to list_value.len)
			var/key = list_value[i]
			var/value
			if(IS_NORMAL_LIST(list_value) && IS_VALID_ASSOC_KEY(key))
				value = list_value[key]
			variable_html += debug_variable(i, value, 0, list_value)
	else
		names = sort_list(names)
		for(var/varname in names)
			if(thing.can_vv_get(varname))
				variable_html += thing.vv_get_var(varname)

	var/html = {"
<html>
	<head>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<title>[title]</title>
		<link rel="stylesheet" type="text/css" href="[SSassets.transport.get_asset_url("view_variables.css")]">
		[!ui_scale && window_scaling ? "<style>body {zoom: [100 / window_scaling]%;}</style>" : ""]
	</head>
	<body onload='selectTextField()'>
		<script type="text/javascript">
			// this code used to be dogshit, and i broke it 5 times in the process of writing it because writing
			// javascript code in dreammaker is actually awful. - chen
			let varsOl = null;
			let indexedList = [];
			let lastFilter = "";

			function getCookie(cname) {
				const name = cname + "=";
				const ca = document.cookie.split(";");
				for (let c of ca) {
					c = c.trim();
					if (c.startsWith(name)) return c.substring(name.length);
				}
				return "";
			}

			function selectTextField() {
				const filterInput = document.getElementById("filter");
				if (!filterInput) return;

				filterInput.focus();
				filterInput.select();

				const lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filterInput.value = lastsearch;
					updateSearch();
				}
			}

			function updateSearch() {
				if (!varsOl) return;

				const filterInput = document.getElementById("filter");
				if (!filterInput) return;

				const filter = filterInput.value.toLowerCase();
				if (filter === lastFilter) return;

				const isRefinement = filter.startsWith(lastFilter);
				const fragment = document.createDocumentFragment();

				if (isRefinement) {
					for (const li of Array.from(varsOl.children)) {
						if (!li.textContent.toLowerCase().includes(filter)) {
							varsOl.removeChild(li);
						}
					}
				} else {
					varsOl.textContent = "";
					for (const item of indexedList) {
						if (!filter || item.text.includes(filter)) {
							fragment.appendChild(item.li);
						}
					}
					varsOl.appendChild(fragment);
				}

				lastFilter = filter;
				document.cookie = `[refid][cookieoffset]search=${encodeURIComponent(filter)}`;
			}

			function debounce(fn, delay) {
				let t;
				return function (...args) {
					clearTimeout(t);
					t = setTimeout(() => fn.apply(this, args), delay);
				};
			}

			const debouncedUpdateSearch = debounce(updateSearch, 50);

			function handle_keydown(e) {
				if (e.key === "F5") {
					document.getElementById("refresh_link")?.click();
					e.preventDefault();
					return false;
				}
				return true;
			}

			function handle_keyup() {
				debouncedUpdateSearch();
			}

			function handle_dropdown(list) {
				const value = list.value;
				if (value) location.href = value;
				list.selectedIndex = 0;
				document.getElementById("filter")?.focus();
			}

			function replace_span(what) {
				const idx = what.indexOf(":");
				if (idx === -1) return;
				const el = document.getElementById(what.slice(0, idx));
				if (el) el.innerHTML = what.slice(idx + 1);
			}

			document.addEventListener("DOMContentLoaded", () => {
				varsOl = document.getElementById("vars");
				if (!varsOl) return;

				indexedList = Array.from(varsOl.children).map(li => ({
					li,
					text: li.textContent.toLowerCase(),
				}));

				document.addEventListener("keydown", handle_keydown);
				document.addEventListener("keyup", handle_keyup);

				selectTextField();
			});
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[header.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							<br><b><font size='1'>[ref_line]</font></b>
							<span id='marked'>[marked_line]</span>
							<span id='tagged'>[tagged_line]</span>
							<span id='varedited'>[varedited_line]</span>
							<span id='deleted'>[deleted_line]</span>
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='byond://?_src_=vars;
datumrefresh=[refid];[HrefToken()]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="handle_dropdown(this)"
									onmouseclick="this.focus()">
									<option value selected>Select option</option>
									[dropdownoptions.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
	</body>
</html>
"}
	var/size_string = "size=475x650";
	if(ui_scale && window_scaling)
		size_string = "size=[475 * window_scaling]x[650 * window_scaling]"

	src << browse(html, "window=variables[refid];[size_string]")

/client/proc/vv_update_display(datum/thing, span, content)
	src << output("[span]:[content]", "variables[REF(thing)].browser:replace_span")

#undef ICON_STATE_CHECKED
#undef ICON_STATE_NULL
