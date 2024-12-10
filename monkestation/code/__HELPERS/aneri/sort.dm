/proc/aneri_sort_with_proc(list/list_to_sort, cmp = GLOBAL_PROC_REF(cmp_numeric_asc)) as /list
	RETURN_TYPE(list_to_sort[_].type)
	return ANERI_CALL("sort_with_proc", list_to_sort, "[cmp]")

/proc/aneri_sort_by_number(list/list_to_sort, descending = FALSE) as /list
	RETURN_TYPE(list_to_sort[_].type)
	return ANERI_CALL("sort_by_number", list_to_sort, descending)

/proc/aneri_sort_by_number_var(list/list_to_sort, var_name, descending = FALSE) as /list
	RETURN_TYPE(list_to_sort[_].type)
	return ANERI_CALL("sort_by_number_var", list_to_sort, var_name, descending)

/proc/aneri_sort_by_string(list/list_to_sort, descending = FALSE, ignore_case = FALSE) as /list
	RETURN_TYPE(list_to_sort[_].type)
	return ANERI_CALL("sort_by_string", list_to_sort, descending, ignore_case)

/proc/aneri_sort_by_string_var(list/list_to_sort, var_name, descending = FALSE, ignore_case = FALSE) as /list
	RETURN_TYPE(list_to_sort[_].type)
	return ANERI_CALL("sort_by_string_var", list_to_sort, var_name, descending, ignore_case)
