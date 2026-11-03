/obj/effect/spawner
	name = "object spawner"

// Brief explanation:
// Rather then setting up and then deleting spawners, we block all atomlike setup
// and do the absolute bare minimum
// This is with the intent of optimizing mapload
/obj/effect/spawner/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/Destroy(force)
	SHOULD_CALL_PARENT(FALSE)
	moveToNullspace()
	return QDEL_HINT_QUEUE

/obj/effect/spawner/forceMove(atom/destination)
	if(destination && QDELETED(src)) // throw a warning if we try to forceMove a qdeleted spawner to somewhere other than nullspace
		stack_trace("Warning: something tried to forceMove() a qdeleted [src]([type]) to non-null destination [destination]([destination.type])!")
	return ..()
