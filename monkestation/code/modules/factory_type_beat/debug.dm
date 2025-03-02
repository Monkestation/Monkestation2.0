/proc/count_lists()
#ifndef OPENDREAM
	var/list_count = 0
	for(var/list/list)
		list_count++
	aneri_file_write("[list_count]", "data/list_count/[GLOB.round_id].txt")
#endif

/proc/save_types()
#ifndef OPENDREAM
	var/datum/D
	var/atom/A
	var/list/counts = new
	for(A) counts[A.type] += 1
	for(D) counts[D.type] += 1

	var/total = length(counts)
	var/list/data = new(total)
	for(var/idx in 1 to total)
		var/key = counts[idx]
		var/amt = counts[key]
		data[idx] = "[key]\t[amt]"
	aneri_file_write(data.Join("\n"), "data/type_tracker/[GLOB.round_id]-stat_track.txt")
#endif

/proc/save_datums()
#ifndef OPENDREAM
	var/datum/D
	var/list/counts = new
	for(D) counts[D.type] += 1

	var/total = length(counts)
	var/list/data = new(total)
	for(var/idx in 1 to total)
		var/key = counts[idx]
		var/amt = counts[key]
		data[idx] = "[key]\t[amt]"
	aneri_file_write(data.Join("\n"), "data/type_tracker/[GLOB.round_id]-datums-[world.time].txt")
#endif
