//procs related to blob tile creation go in here

/obj/structure/blob/proc/consume_tile(mob/eye/blob/consuming)
	for(var/atom/thing in loc)
		if(!thing.can_blob_attack())
			continue
		if(isliving(thing) && blob_team && !HAS_TRAIT(thing, TRAIT_BLOB_ALLY)) // Make sure to inject strain-reagents with automatic attacks when needed.
			blob_team.blobstrain.attack_living(thing, attacker = consuming) //THIS MIGHT CAUSE ATTACK TO BE CALLED TWICE
			continue // Don't smack them twice though
		thing.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/blob/proc/blob_attack_animation(atom/attacked) //visually attacks an atom
	var/obj/effect/temp_visual/blob/attack_visual = new /obj/effect/temp_visual/blob(src.loc)
	attack_visual.setDir(dir)
	var/area/my_area = get_area(src)
	if(blob_team)
		attack_visual.color = blob_team.blobstrain.color
		if(!(my_area.area_flags & BLOBS_ALLOWED))
			attack_visual.color = BlendRGB(attack_visual.color, COLOR_WHITE, 0.5) //lighten it to indicate an off-station blob
		attack_visual.alpha = 200
	if(attacked)
		attack_visual.do_attack_animation(attacked) //visually attack the whatever
	return attack_visual //just in case you want to do something to the animation.

/obj/structure/blob/proc/expand(turf/target, mob/controller = null, expand_reaction = TRUE, datum/team/blob/owner)
	if(!target) //refactor this handling
		var/list/dirs = GLOB.cardinals.Copy()
		for(var/i = 1 to 4)
			target = get_step(src, pick_n_take(dirs))
			if(!(locate(/obj/structure/blob) in target)) //might want to cache what tiles have blobs on them for general handling
				break
			else
				target = null
	if(!target)
		return
	var/make_blob = TRUE //can we make a blob?

	if(isspaceturf(target) && !(locate(/obj/structure/lattice) in target) && prob(80))
		make_blob = FALSE
		playsound(src.loc, 'sound/effects/splat.ogg', 50, TRUE) //Let's give some feedback that we DID try to spawn in space, since players are used to it

	consume_tile(controller) //hit the tile we're in, making sure there are no border objects blocking us
	if(!target.CanPass(src, get_dir(target, src))) //is the target turf impassable
		make_blob = FALSE
		target.blob_act(src) //hit the turf if it is
	for(var/atom/inside in target)
		if(!inside.CanPass(src, get_dir(target, src))) //is anything in the turf impassable
			make_blob = FALSE
		if(!inside.can_blob_attack())
			continue
		if(isliving(inside) && blob_team && !controller) // Make sure to inject strain-reagents with automatic attacks when needed.
			blob_team.blobstrain.attack_living(inside, attacker = controller)
			continue // Don't smack them twice though
		inside.blob_act(src) //also hit everything in the turf

	if(make_blob) //well, can we?
		var/obj/structure/blob/new_tile = new /obj/structure/blob/normal(src.loc, (controller || blob_team)) //MAYBE CHANGE THIS TO JUST SPAWN ON THE TARGET
		new_tile.set_density(TRUE)
		if(target.Enter(new_tile)) //NOW we can attempt to move into the tile
			new_tile.set_density(initial(new_tile.density))
			new_tile.forceMove(target)
			if(astype(get_step(new_tile, 0)?.loc, /area).area_flags & BLOBS_ALLOWED) //Is this area allowed for winning as blob?
				blob_team.blobs_legit++
				new_tile.legit = TRUE
			else if(controller)
				new_tile.balloon_alert(controller, "off-station, won't count!")
			new_tile.update_appearance()
			if(new_tile.blob_team && expand_reaction)
				blob_team.blobstrain.expand_reaction(src, new_tile, target, controller)
			return new_tile
		else
			blob_attack_animation(target, controller)
			target.blob_act(src) //if we can't move in hit the turf again
			qdel(new_tile) //we should never get to this point, since we checked before moving in. destroy the blob so we don't have two blobs on one tile
			return
	else
		blob_attack_animation(target, controller) //if we can't, animate that we attacked
	return

/obj/structure/blob/proc/creation_action() //When it's created by the overmind, do this.
	return
