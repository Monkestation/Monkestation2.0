/**
 * Creates a mutable appearance with the material color applied for its insertion animation into an autolathe or techfab
 * Arguments
 *
 * * material - the material used to generate the overlay
 */
/proc/material_insertion_animation(datum/material/material)
	RETURN_TYPE(/mutable_appearance)

	var/static/list/mutable_appearance/apps = list()

	var/mutable_appearance/cached_app = apps[material]
	if(isnull(cached_app))
		cached_app = mutable_appearance('icons/obj/machines/research.dmi', "material_insertion")
		cached_app.color = material.color
		cached_app.alpha = material.alpha

		apps[material] = cached_app
	return cached_app

//Same thing, but uses different icon
/proc/lathe_material_insertion_animation(color)
	RETURN_TYPE(/mutable_appearance)

	var/static/list/mutable_appearance/apps = list()

	var/mutable_appearance/cached_app = apps[color]
	if(isnull(cached_app))
		var/icon/modified_icon = icon('icons/obj/machines/research.dmi', "material_insertion")

		//assuming most of the icon is white we find what ratio to scale the intensity of each part roughly
		var/list/rgb_list = rgb2num(color)
		modified_icon.SetIntensity(rgb_list[1] / 255, rgb_list[2] / 255, rgb_list[3] / 255)
		cached_app = mutable_appearance(modified_icon, "material_insertion")

		apps[color] = cached_app
	return cached_app
