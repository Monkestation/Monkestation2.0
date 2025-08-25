
#define MACHINING_LATHE "lathe"
#define MACHINING_WORKSTATION "workstation"
#define MACHINING_FURNACE "furnace"
#define MACHINING_TABLESAW "tablesaw"
#define MACHINING_DROPHAMMER "drophammer"
#define MACHINING_TAILOR "tailor"
#define MACHINING_DRILLPRESS "drillpress"

#define MACHINING_DELAY_VERY_FAST 1 SECONDS
#define MACHINING_DELAY_FAST 2.5 SECONDS
#define MACHINING_DELAY_NORMAL 5 SECONDS
#define MACHINING_DELAY_SLOW 10 SECONDS
#define MACHINING_DELAY_VERY_SLOW 20 SECONDS
#define MACHINING_DELAY_EXCRUCIATINGLY_SLOW 40 SECONDS

#define TAB_GENERAL_PARTS "generalparts"
#define TAB_TYPE_PARTS "typeparts"
#define TAB_SPECIFIC_PARTS "specificparts"
#define TAB_ASSEMBLY_PARTS "assembly"
/// This includes stuff like recipe components and results.
GLOBAL_LIST_INIT(machining_recipes, init_machining_recipes())
GLOBAL_LIST_INIT(machining_recipes_atoms, init_machining_recipes_atoms())
