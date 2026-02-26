///Set weakref_var to null if it fails to give a resolve() value, resolver should be set to the var looking to resolve the weakref
#define WEAKREF_NULL_IF_UNRESOLVED(weakref_var, resolver) weakref_var?.resolve();\
	if(!##resolver) { \
		##weakref_var = null;\
	}
