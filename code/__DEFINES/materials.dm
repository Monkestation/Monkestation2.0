/// Is the material from an ore? currently unused but exists atm for categorizations sake
#define MAT_CATEGORY_ORE "ore capable"

/// Makes sure only integer values are used when consuming, removing & checking for mats
#define OPTIMAL_COST(cost)(max(1, round(cost)))

/// Wrapper for fetching material references. Exists exclusively so that people don't need to wrap everything in a list every time.
#define GET_MATERIAL_REF(arguments...) SSmaterials._GetMaterialRef(list(##arguments))

#define MATERIAL_SOURCE(mat) "[mat.name]_material"
