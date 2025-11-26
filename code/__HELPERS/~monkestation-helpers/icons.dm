#define TMP_UPSCALE_PATH "tmp/resize_icon.png"

/// Upscales an icon using rust-g.
/// You really shouldn't use this TOO often, as it has to copy the icon to a temporary png file,
/// resize it, fcopy_rsc the resized png, and then create a new /icon from said png.
/// Cache the output where possible.
/proc/resize_icon(icon/icon, width, height, resize_type = "nearest") as /icon
	RETURN_TYPE(/icon)
	SHOULD_BE_PURE(TRUE)

	if(!istype(icon))
		CRASH("Attempted to upscale non-icon")
	if(!IS_SAFE_NUM(width) || !IS_SAFE_NUM(height))
		CRASH("Attempted to upscale icon to non-number width/height")
	if(!fcopy(icon, TMP_UPSCALE_PATH))
		CRASH("Failed to create temporary png file to upscale")
	UNLINT(rustg_dmi_resize_png(TMP_UPSCALE_PATH, "[width]", "[height]", resize_type)) // technically impure but in practice its not
	. = icon(fcopy_rsc(TMP_UPSCALE_PATH))
	fdel(TMP_UPSCALE_PATH)

#undef TMP_UPSCALE_PATH

#ifdef PRELOAD_ICON_EXISTS_CACHE
/proc/load_icon_exists_cache()
	. = null
	if(!fexists("icon_exists_cache.json"))
		log_world("icon_exists_cache.json doesn't exist, not loading cache")
		return
	var/cache_file = rustg_file_read("icon_exists_cache.json")
	if(!rustg_json_is_valid(cache_file))
		log_world("did not load icon_exists cache: file exists but wasn't valid json")
		CRASH("did not load icon_exists cache: file exists but wasn't valid json")
	var/list/cache_data = json_decode(cache_file)
	if(!islist(cache_data))
		log_world("did not load icon_exists cache: file exists but wasn't valid json")
		CRASH("did not load icon_exists cache: file exists and is valid json, but did not decode into an object")
	var/list/icons = cache_data["icons"]
	if(!islist(icons))
		log_world("did not load icon_exists cache: 'icons' key was not a list")
		CRASH("did not load icon_exists cache: 'icons' key was not a list")
	var/cache_revision = cache_data["revision"]
	if(!isnull(cache_revision))
		var/revision = rustg_git_revparse("HEAD")
		if(cache_revision != revision)
			log_world("did not load icon_exists cache: revision ([cache_revision]) mismatched current server revision ([revision])")
			return
		log_world("loaded icon_exists cache for [revision]")
	else
		log_world("loaded icon_exists cache without verifying revision")
	return icons
#endif
