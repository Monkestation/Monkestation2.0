
/datum/hud/bloodling/New(mob/living/owner)
	. = ..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/language_menu()
	using.icon = ui_style
	using.hud = src
	using.update_appearance()
	static_inventory += using

	using = new /atom/movable/screen/navigate
	using.screen_loc = ui_alien_navigate_menu
	using.hud = src
	static_inventory += using

	healthdoll = new /atom/movable/screen/healthdoll/living()
	healthdoll.hud = src
	infodisplay += healthdoll

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_living_pull
	static_inventory += pull_icon

	zone_select = new /atom/movable/screen/zone_sel(null, src)
	zone_select.icon = ui_style
	zone_select.update_appearance()
	static_inventory += zone_select
	bloodling_bio_display = new /atom/movable/screen/bloodling_bio_display(null, src) //Just going to use the alien plasma display because making new vars for each object is braindead.
	infodisplay += bloodling_bio_display

/atom/movable/screen/bloodling_bio_display
	icon = 'icons/hud/screen_alien.dmi'
	icon_state = "power_display"
	name = "Biomass"
	screen_loc = ui_alienplasmadisplay
