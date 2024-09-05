/turf/open/misc/asteroid/airless/tospace
	explodable = TRUE
	baseturfs = /turf/baseturf_bottom
	turf_type = /turf/open/misc/asteroid/airless/tospace


/obj/effect/forcefield/asteroid_magnet
	name = "magnetic field"
	desc = "This looks dangerous."
	icon = 'goon/icons/obj/effects.dmi'
	icon_state = "forcefield"

	initial_duration = 0
	opacity = TRUE


/proc/button_element(trg, text, action, class, style)
	return "<a href='?src=\ref[trg];[action]'[class ? "class='[class]'" : ""][style ? "style='[style]'" : ""]>[text]</a>"

/proc/color_button_element(trg, color, action)
	return "<a href='?src=\ref[trg];[action]' class='box' style='background-color: [color]'></a>"

/// Inline script for an animated ellipsis
/proc/ellipsis(number_of_dots = 3, millisecond_delay = 500)
	var/static/unique_id = 0
	unique_id++
	return {"<span id='[unique_id]' style='display: inline-block'></span>
			<script>
			var count = 0;
			document.addEventListener("DOMContentLoaded", function() {
				setInterval(function(){
					count++;
					document.getElementById('[unique_id]').innerHTML = new Array(count % [number_of_dots + 2]).join('.');
				}, [millisecond_delay]);
			});
			</script>
	"}

/// Breaks down to an asteroid floor that breaks down to space
/turf/closed/mineral/random/asteroid/tospace
	baseturfs = /turf/open/misc/asteroid/airless/tospace

/turf/closed/mineral/random/asteroid/tospace/mineral_chances()
	return list(
		/obj/item/stack/ore/diamond = 2,
		/obj/item/stack/ore/gold = 4,
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/silver = 2,
		/obj/item/stack/ore/titanium = 2,
		/obj/item/stack/ore/uranium = 2,
		/turf/closed/mineral/artifact = 25,
		/turf/closed/mineral/mineral_sample = 25,
	)
/// Cleanup our currently loaded mining template
/proc/CleanupAsteroidMagnet(turf/center, size)
	var/list/turfs_to_destroy = ReserveTurfsForAsteroidGeneration(center, size, baseturf_only = FALSE)
	for(var/turf/T as anything in turfs_to_destroy)
		CHECK_TICK

		for(var/atom/movable/AM as anything in T)
			CHECK_TICK
			if(isdead(AM) || iscameramob(AM) || iseffect(AM) || iseminence(AM) || ismob(AM))
				continue
			qdel(AM)

		T.ChangeTurf(/turf/baseturf_bottom)

/// Sanitizes a block of turfs to prevent writing over undesired locations
/proc/ReserveTurfsForAsteroidGeneration(turf/center, size, baseturf_only = TRUE)
	. = list()

	var/list/turfs = RANGE_TURFS(size, center)
	for(var/turf/T as anything in turfs)
		if(baseturf_only && !islevelbaseturf(T))
			continue
		if(!(istype(T.loc, /area/station/cargo/mining/asteroid_magnet)))
			continue
		. += T
		CHECK_TICK
