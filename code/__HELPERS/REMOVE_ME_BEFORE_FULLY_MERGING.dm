// temporary things for profiling purposes
#ifdef UNIT_TESTS
#warn remove these profiling wrappers before full merging
#endif

/proc/_json_encode(stuff)
	return json_encode(stuff)

/proc/_rustg_file_write(text, fname)
	return rustg_file_write(text, fname)

/proc/DREAMLUAU_CLEAR_REF_USERDATA(object)
	DREAMLUAU_CALL(clear_ref_userdata)(object)
