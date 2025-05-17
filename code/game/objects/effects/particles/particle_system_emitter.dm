

/atom
	var/list/particle_systems = list()

//-----------------------------------------------
/atom/proc/add_to_vis(stuff)
	return

/turf/add_to_vis(stuff)
	vis_contents += stuff

/atom/movable/add_to_vis(stuff)
	vis_contents += stuff

//-----------------------------------------------
/atom/proc/remove_from_vis(stuff)
	return

/turf/remove_from_vis(stuff)
	vis_contents -= stuff

/atom/movable/remove_from_vis(stuff)
	vis_contents -= stuff

//-----------------------------------------------
/atom/proc/add_particles(particle_string)
	if (!particle_string)
		return
	if (particle_string in particle_systems)
		return

	var/particle_type = GLOB.particle_string_to_type[particle_string]
	var/obj/effect/abstract/particle_holder/new_holder = new(src)
	new_holder.main_holder = src
	new_holder.particles = new particle_type
	new_holder.special_setup()
	particle_systems[particle_string] = new_holder
	add_to_vis(particle_systems[particle_string])

//-----------------------------------------------
/atom/proc/remove_particles(particle_string)
	if (!particle_string) //If we don't specify which particle we want to remove, just remove all of them
		for (var/string in particle_systems)
			remove_particles(string)
		return
	if (!(particle_string in particle_systems))
		return

	remove_from_vis(particle_systems[particle_string])
	var/obj/effect/abstract/particle_holder/holder = particle_systems[particle_string]
	if (holder.main_holder == src)
		qdel(holder)
	particle_systems -= particle_string

//-----------------------------------------------
/atom/proc/stop_particles(particle_string)
	if (!particle_string) //If we don't specify which particle we want to stop, just stop all of them
		for (var/string in particle_systems)
			stop_particles(string)
	if (!(particle_string in particle_systems))
		return

	var/obj/effect/abstract/particle_holder/holder = particle_systems[particle_string]
	holder.particles.spawning = 0

//-----------------------------------------------
/atom/proc/transfer_particles(atom/target, particle_string)
	if (!target)
		return
	if (!particle_string) //If we don't specify which particle we want to move, just move all of them
		for (var/string in particle_systems)
			transfer_particles(target, string)
		return
	if (!(particle_string in particle_systems))
		return

	var/obj/effect/abstract/particle_holder/holder = particle_systems[particle_string]
	if (particle_string in target.particle_systems)
		target.remove_particles(particle_string)
	target.particle_systems[particle_string] = holder
	target.add_to_vis(holder)
	holder.main_holder = target
	particle_systems -= particle_string
	remove_from_vis(holder)

//-----------------------------------------------
/atom/proc/link_particles(atom/target, particle_string) //Similar to transfer_particles but doesn't change the main holder, instead just adding the vis_contents
	if (!target)
		return
	if (!particle_string) //If we don't specify which particle we want to link, just link all of them
		for (var/string in particle_systems)
			link_particles(target, string)
		return
	if (!(particle_string in particle_systems))
		return

	var/obj/effect/abstract/particle_holder/holder = particle_systems[particle_string]
	if (particle_string in target.particle_systems)
		if (target.particle_systems[particle_string] == holder)//particle is already linked
			return
		target.remove_particles(particle_string)
	target.particle_systems[particle_string] = holder
	target.add_to_vis(holder)

//-----------------------------------------------
/atom/proc/adjust_particles(adjustment, new_value, particle_string)
	if (!particle_string) //If we don't specify which particle we want to shift, just shift all of them
		for (var/string in particle_systems)
			adjust_particles(adjustment ,new_value, string)
		return
	if (!(particle_string in particle_systems))
		return

	var/obj/effect/abstract/particle_holder/holder = particle_systems[particle_string]

	switch(adjustment)
		if (PVAR_SPAWNING)
			holder.particles.spawning = new_value
		if (PVAR_POSITION)
			holder.particles.position = new_value
		if (PVAR_VELOCITY)
			holder.particles.velocity = new_value
		if (PVAR_ICON_STATE)
			holder.particles.icon_state = new_value
		if (PVAR_COLOR)
			holder.particles.color = new_value
		if (PVAR_SCALE)
			holder.particles.scale = new_value
		if (PVAR_LIFESPAN)
			holder.particles.lifespan = new_value
		if (PVAR_FADE)
			holder.particles.fade = new_value
		if (PVAR_PLANE)
			holder.plane = new_value
		if (PVAR_LAYER)
			holder.layer = new_value
		if (PVAR_PIXEL_X)
			holder.pixel_x = new_value
		if (PVAR_PIXEL_Y)
			holder.pixel_y = new_value
		//add more as needed


/obj/effect/abstract/particle_holder/proc/special_setup(particle_string)
	if (particles.plane)
		plane = particles.plane
	if (particles.appearance_flags)
		appearance_flags = particles.appearance_flags
	if (particles.blend_mode)
		blend_mode = particles.blend_mode
	layer = particles.layer
	pixel_x = particles.pixel_x
	pixel_y = particles.pixel_y
