/datum/preference/numeric/light_bloom
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "light_bloom"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 100

/datum/preference/numeric/light_bloom/create_default_value()
	return 100

/datum/preference/numeric/light_bloom/apply_to_client(client/client, value)
	for(var/atom/movable/screen/plane_master/plane_master as anything in client.mob?.hud_used?.get_true_plane_masters(LIGHTING_BLOOM_PLANE))
		plane_master.show_to(client.mob)
