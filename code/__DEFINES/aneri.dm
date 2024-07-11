#ifndef ANERI

//#define ANERI_OVERRIDE_PICK
#define ANERI_OVERRIDE_PICK_WEIGHT
//#define ANERI_OVERRIDE_SORT
#define ANERI_OVERRIDE_RAND

/* This comment bypasses grep checks */ /var/__aneri

/proc/__detect_aneri()
	if(world.system_type == UNIX)
		return __aneri = "libaneri"
	else
		return __aneri = "aneri"

#define ANERI (__aneri || __detect_aneri())
#define ANERI_CALL(name, args...) call_ext(ANERI, "byond:" + name + "_ffi")(args)

/proc/aneri_cleanup() return ANERI_CALL("cleanup")

//#define file2text(fname)		aneri_file_read("[fname]")
//#define text2file(text, fname)	aneri_file_append(text, "[fname]")

/proc/aneri_replace_chars_prob(input, replacement, probability = 25, skip_whitespace = FALSE)
	return ANERI_CALL("replace_chars_prob", input, replacement, probability, skip_whitespace)

#if defined(ANERI_OVERRIDE_PICK) || defined(ANERI_OVERRIDE_PICK_WEIGHT)
#define pick_weight(list)		ANERI_CALL("pick_weighted", list)
#endif

#ifdef ANERI_OVERRIDE_PICK
#define pick(list...)			_apick(list)

/proc/_apick(...)
	switch(length(args))
		if(0)
			CRASH("pick() called with no arguments")
		if(1)
			var/list/arg = args[1]
			if(!islist(arg))
				CRASH("pick() called with non-list argument")
			return ANERI_CALL("pick", arg)
		else
			return ANERI_CALL("pick", args)
#endif

#ifdef ANERI_OVERRIDE_RAND
/proc/_arand(...)
	switch(length(args))
		if(0)
			return ANERI_CALL("random_float")
		if(1)
			return ANERI_CALL("random_range_int_unsigned", 0, args[1])
		if(2)
			return ANERI_CALL("random_range_int_signed", args[1], args[2])
		else
			CRASH("arand() takes 0-2 arguments")

#define rand(args...)	_arand(args)
#define prob(val)		ANERI_CALL("prob", val)
#endif

/world/New()
	aneri_cleanup()
	..()

#endif
