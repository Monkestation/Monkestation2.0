SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = INIT_ORDER_ATOMS
	flags = SS_NO_FIRE

	/// A stack of list(source, desired initialized state)
	/// We read the source of init changes from the last entry, and assert that all changes will come with a reset
	var/list/initialized_state = list()
	var/base_initialized

	var/list/late_loaders = list()

	var/list/BadInitializeCalls = list()

	///initAtom() adds the atom its creating to this list iff InitializeAtoms() has been given a list to populate as an argument
	var/list/created_atoms

	#ifdef PROFILE_MAPLOAD_INIT_ATOM
	var/list/init_costs = list()
	var/list/init_counts = list()

	var/list/late_init_costs = list()
	var/list/late_init_counts = list()
	#endif

	/// Atoms that will be deleted once the subsystem is initialized
	var/list/queued_deletions = list()

	var/init_start_time

	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/Initialize()
	init_start_time = world.time
	setupGenetics() //to set the mutations' sequence

	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	initialized = INITIALIZATION_INNEW_REGULAR

	return SS_INIT_SUCCESS

/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms, list/atoms_to_return)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	// Generate a unique mapload source for this run of InitializeAtoms
	var/static/uid = 0
	uid = (uid + 1) % (SHORT_REAL_LIMIT - 1)
	var/source = "subsystem init [uid]"
	set_tracked_initalized(INITIALIZATION_INNEW_MAPLOAD, source)

	// This may look a bit odd, but if the actual atom creation runtimes for some reason, we absolutely need to set initialized BACK
	CreateAtoms(atoms, atoms_to_return, source)
	clear_tracked_initalize(source)
	SSicon_smooth.free_deferred(source)

	if(late_loaders.len)
		for(var/I in 1 to late_loaders.len)
			var/atom/A = late_loaders[I]
			//I hate that we need this
			if(QDELETED(A))
				continue

			#ifdef PROFILE_MAPLOAD_INIT_ATOM
			var/the_type = A.type
			late_init_costs |= the_type
			late_init_counts |= the_type
			var/startreal = REALTIMEOFDAY
			#endif

			A.LateInitialize()

			#ifdef PROFILE_MAPLOAD_INIT_ATOM
			late_init_costs[the_type] += REALTIMEOFDAY - startreal
			late_init_counts[the_type] += 1
			#endif

		testing("Late initialized [late_loaders.len] atoms")
		late_loaders.Cut()

	if (created_atoms)
		atoms_to_return += created_atoms
		created_atoms = null

	for (var/queued_deletion in queued_deletions)
		qdel(queued_deletion)

	testing("[queued_deletions.len] atoms were queued for deletion.")
	queued_deletions.Cut()

/// Actually creates the list of atoms. Exists soley so a runtime in the creation logic doesn't cause initalized to totally break
/datum/controller/subsystem/atoms/proc/CreateAtoms(list/atoms, list/atoms_to_return = null, mapload_source = null)
	if (atoms_to_return)
		LAZYINITLIST(created_atoms)

	#ifdef TESTING
	var/count
	#endif

	var/list/mapload_arg = list(TRUE)

	if(atoms)
		#ifdef TESTING
		count = atoms.len
		#endif

		for(var/I in 1 to atoms.len)
			var/atom/A = atoms[I]
			if(!(A.flags_1 & INITIALIZED_1))
				// Unrolled CHECK_TICK setup to let us enable/disable mapload based off source
				if(TICK_CHECK)
					clear_tracked_initalize(mapload_source)
					stoplag()
					if(mapload_source)
						set_tracked_initalized(INITIALIZATION_INNEW_MAPLOAD, mapload_source)
				InitAtom(A, TRUE, mapload_arg)
#ifndef DISABLE_DEMOS
		SSdemo.mark_multiple_new(atoms) // monkestation edit: replays
#endif
	else
		#ifdef TESTING
		count = 0
		#endif

		var/list/atoms_to_mark = list() // monkestation edit: replays
		for(var/atom/A as anything in world)
			if(!(A.flags_1 & INITIALIZED_1))
				InitAtom(A, FALSE, mapload_arg)
				atoms_to_mark += A // monkestation edit: replays
				#ifdef TESTING
				++count
				#endif
				if(TICK_CHECK)
					clear_tracked_initalize(mapload_source)
					stoplag()
					if(mapload_source)
						set_tracked_initalized(INITIALIZATION_INNEW_MAPLOAD, mapload_source)
#ifndef DISABLE_DEMOS
		SSdemo.mark_multiple_new(atoms_to_mark) // monkestation edit: replays
#endif

	testing("Initialized [count] atoms")

/// Init this specific atom
/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, from_template = FALSE, list/arguments)
	var/the_type = A.type

	if(QDELING(A))
		// Check init_start_time to not worry about atoms created before the atoms SS that are cleaned up before this
		if (A.gc_destroyed > init_start_time)
			BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	#ifdef PROFILE_MAPLOAD_INIT_ATOM
	init_costs |= A.type
	init_counts |= A.type

	var/startreal = REALTIMEOFDAY
	#endif

	// This is handled and battle tested by dreamchecker. Limit to UNIT_TESTS just in case that ever fails.
	#ifdef UNIT_TESTS
	var/start_tick = world.time
	#endif

	var/result = A.Initialize(arglist(arguments))

	#ifdef UNIT_TESTS
	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT
	#endif

	var/qdeleted = FALSE

	switch(result)
		if (INITIALIZE_HINT_NORMAL)
			EMPTY_BLOCK_GUARD // Pass
		if(INITIALIZE_HINT_LATELOAD)
			if(arguments[1]) //mapload
				late_loaders += A
			else
				#ifdef PROFILE_MAPLOAD_INIT_ATOM
				late_init_costs |= the_type
				late_init_counts |= the_type
				var/late_startreal = REALTIMEOFDAY
				#endif
				A.LateInitialize(arguments)
				#ifdef PROFILE_MAPLOAD_INIT_ATOM
				late_init_costs[the_type] += REALTIMEOFDAY - late_startreal
				late_init_counts[the_type] += 1
				#endif
		if(INITIALIZE_HINT_QDEL)
			qdel(A)
			qdeleted = TRUE
		else
			BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A) //possible harddel
		qdeleted = TRUE
	else if(!(A.flags_1 & INITIALIZED_1))
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT
	else
		SEND_SIGNAL(A, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ATOM_AFTER_POST_INIT, A)
		var/atom/location = A.loc
		if(location)
			/// Sends a signal that the new atom `src`, has been created at `loc`
			SEND_SIGNAL(location, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, A, arguments[1])
		if(created_atoms && from_template && ispath(the_type, /atom/movable))//we only want to populate the list with movables
			created_atoms += A.get_all_contents()

	#ifdef PROFILE_MAPLOAD_INIT_ATOM
	init_costs[A.type] += REALTIMEOFDAY - startreal
	init_counts[A.type] += 1
	#endif

	return qdeleted || QDELING(A)

/datum/controller/subsystem/atoms/proc/map_loader_begin(source)
	set_tracked_initalized(INITIALIZATION_INSSATOMS, source)

/datum/controller/subsystem/atoms/proc/map_loader_stop(source)
	clear_tracked_initalize(source)

/// Returns the source currently modifying SSatom's init behavior
/datum/controller/subsystem/atoms/proc/get_initialized_source()
	var/state_length = length(initialized_state)
	if(!state_length)
		return null
	return initialized_state[state_length][1]

/// Use this to set initialized to prevent error states where the old initialized is overriden, and we end up losing all context
/// Accepts a state and a source, the most recent state is used, sources exist to prevent overriding old values accidentially
/datum/controller/subsystem/atoms/proc/set_tracked_initalized(state, source)
	if(!length(initialized_state))
		base_initialized = initialized
	initialized_state += list(list(source, state))
	initialized = state

/datum/controller/subsystem/atoms/proc/clear_tracked_initalize(source)
	if(!length(initialized_state))
		return
	for(var/i in length(initialized_state) to 1 step -1)
		if(initialized_state[i][1] == source)
			initialized_state.Cut(i, i+1)
			break

	if(!length(initialized_state))
		initialized = base_initialized
		base_initialized = INITIALIZATION_INNEW_REGULAR
		return
	initialized = initialized_state[length(initialized_state)][2]

/// Returns TRUE if anything is currently being initialized
/datum/controller/subsystem/atoms/proc/initializing_something()
	return length(initialized_state) > 1

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	initialized_state = SSatoms.initialized_state
	BadInitializeCalls = SSatoms.BadInitializeCalls

/datum/controller/subsystem/atoms/proc/setupGenetics()
	var/list/mutations = subtypesof(/datum/mutation)
	shuffle_inplace(mutations)
	for(var/A in subtypesof(/datum/generecipe))
		var/datum/generecipe/GR = A
		GLOB.mutation_recipes[initial(GR.required)] = initial(GR.result)
	for(var/i in 1 to LAZYLEN(mutations))
		var/path = mutations[i] //byond gets pissy when we do it in one line
		var/datum/mutation/B = new path ()
		B.alias = "Mutation [i]"
		GLOB.all_mutations[B.type] = B
		GLOB.full_sequences[B.type] = generate_gene_sequence(B.blocks)
		GLOB.alias_mutations[B.alias] = B.type
		if(B.locked)
			continue
		if(B.quality == POSITIVE)
			GLOB.good_mutations |= B
		else if(B.quality == NEGATIVE)
			GLOB.bad_mutations |= B
		else if(B.quality == MINOR_NEGATIVE)
			GLOB.not_good_mutations |= B
		CHECK_TICK

/datum/controller/subsystem/atoms/proc/InitLog()
	. = ""
	for(var/path in BadInitializeCalls)
		. += "Path : [path] \n"
		var/fails = BadInitializeCalls[path]
		if(fails & BAD_INIT_DIDNT_INIT)
			. += "- Didn't call atom/Initialize(mapload)\n"
		if(fails & BAD_INIT_NO_HINT)
			. += "- Didn't return an Initialize hint\n"
		if(fails & BAD_INIT_QDEL_BEFORE)
			. += "- Qdel'd in New()\n"
		if(fails & BAD_INIT_SLEPT)
			. += "- Slept during Initialize()\n"

/// Prepares an atom to be deleted once the atoms SS is initialized.
/datum/controller/subsystem/atoms/proc/prepare_deletion(atom/target)
	if (initialized == INITIALIZATION_INNEW_REGULAR)
		// Atoms SS has already completed, just kill it now.
		qdel(target)
	else
		queued_deletions += WEAKREF(target)

/datum/controller/subsystem/atoms/Shutdown()
	var/initlog = InitLog()
	if(initlog)
		text2file(initlog, "[GLOB.log_directory]/initialize.log")

#ifdef PROFILE_MAPLOAD_INIT_ATOM
/datum/controller/subsystem/atoms/proc/InitCostLog()
	var/list/init_data = list()
	for(var/path in init_costs)
		init_data[path] = list(
			"cost" = init_costs[path],
			"count" = init_counts[path]
		)

	var/list/late_data = list()
	for(var/path in late_init_costs)
		late_data[path] = list(
			"cost" = late_init_costs[path],
			"count" = late_init_counts[path]
		)

	var/list/payload = list(
		"init" = init_data,
		"late" = late_data
	)

	var/json_payload = json_encode(payload)

	. = {"
<style>
body { font-family: monospace; }
.tree-node { margin-left: 20px; }
.tree-item:hover { background: #2d2d30; }
#tree_root { background-color: #171717; border: solid 1px #202020; font-family: "Courier New"; padding: 10px; }
.cost-high { color: #f48771; font-weight: bold; }
.cost-med { color: #dcdcaa; }
.cost-low { color: #4ec9b0; }
.expander { display: inline-block; width: 15px; }
.percentage { color: #858585; font-size: 0.9em; }
.count { color: #9cdcfe; font-size: 0.9em; }
.avg { color: #ce9178; font-size: 0.9em; }
.summary { background: #252526; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
.controls { background: #252526; border-radius: 5px; }
.tab-group { display: inline-block; }
</style>

<a href="#" onclick='exportJSON()'>Export JSON</a>
<script>
function exportJSON() {
	const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(window.DATA));
	const dlAnchorElem = document.createElement('a');
	dlAnchorElem.setAttribute("href", dataStr);
	dlAnchorElem.setAttribute("download", `init_costs_${Math.floor(Date.now())}.json`);
	document.body.appendChild(dlAnchorElem);
	dlAnchorElem.click();
	dlAnchorElem.remove();
}
</script>
<a
	onclick="window.location.href = 'byond://?action=openLink&link=' + encodeURIComponent('https://monkestation.github.io/ss13-init-cost-viewer/');"
	target="_blank"
	href="#"
>Website version (More Features)</a>
<div class='controls'>
<div class='tab-group'>
<a id='btn_init' class='active' onclick='setMode(\"init\")'>Initialize()</a>
<a id='btn_late' onclick='setMode(\"late\")'>LateInitialize()</a>
</div> |
<div class='tab-group'>
<a id='btn_total' class='active' onclick='setSort(\"total\")'>Sort by Total Time</a>
<a id='btn_avg' onclick='setSort(\"avg\")'>Sort by Average Time</a>
</div>
</div>


<div id='summary' class='statusDisplay'></div>
<div id='tree_root'></div>

<script>
window.DATA = [json_payload];
</script>
<script>
let MODE = 'init'; // 'init' or 'late'
let SORT = 'total'; // 'total' or 'avg'

function buildTree(flat) {
	const root = {};
	for(const path in flat) {
		const entry = flat\[path\];
		const parts = path.split('/').filter(Boolean);
		let node = root;
		let built = '';
		for(let i=0;i<parts.length;i++) {
			const part = parts\[i\];
			built += (built ? '/' : '') + part;
			if(!node\[part\]) {
				node\[part\] = { cost: 0, count: 0, direct_cost: 0, direct_count: 0, children: {}, path: built, is_leaf: i === parts.length - 1 };
			}
			if(i === parts.length - 1) {
				node\[part\].direct_cost = entry.cost || 0;
				node\[part\].direct_count = entry.count || 0;
			}
			node\[part\].cost += entry.cost || 0;
			node\[part\].count += entry.count || 0;
			node = node\[part\].children;
		}
	}
	return root;
}

function formatNumber(n) { return Math.round(n * 1000) / 1000; }
function clearChildren(el) { while(el.firstChild) el.removeChild(el.firstChild); }

function sortedKeys(tree, sortByAvg, totalCost) {
	const keys = Object.keys(tree);
	keys.sort((a,b)=>{
		const n1 = tree\[a\], n2 = tree\[b\];
		const v1 = sortByAvg ? (n1.cost / Math.max(n1.count,1)) : n1.cost;
		const v2 = sortByAvg ? (n2.cost / Math.max(n2.count,1)) : n2.cost;
		return v2 - v1; // descending
	});
	return keys;
}

let idCounter = 0;
function renderTree(tree, container, totalCost, sortByAvg) {
	const keys = sortedKeys(tree, sortByAvg, totalCost);
	for(const key of keys) {
		const node = tree\[key\];
		const cost = node.cost;
		const count = node.count;
		const direct_cost = node.direct_cost;
		const direct_count = node.direct_count;
		const avg_cost = formatNumber(cost / Math.max(count,1));
		const percentage = totalCost > 0 ? formatNumber((cost / totalCost) * 100) : 0;
		idCounter++;
		const myId = 'node' + idCounter;
		const hasChildren = Object.keys(node.children).length > 0;
		let costClass = 'cost-low';
		if(percentage >= 10) costClass = 'cost-high';
		else if(percentage >= 1) costClass = 'cost-med';

		const item = document.createElement('div');
		item.className = 'tree-item';

		const exp = document.createElement('span');
		exp.className = 'expander';
		exp.id = 'exp_' + myId;
		exp.textContent = hasChildren ? '▼' : '\\u00A0';
		if(hasChildren) exp.style.cursor = 'pointer';
		item.appendChild(exp);

		const nameSpan = document.createElement('span');
		nameSpan.className = costClass;
		nameSpan.textContent = key;
		item.appendChild(nameSpan);

		const info = document.createElement('span');
		info.innerHTML = ' - <b>' + cost + 'ds</b> <span class=\"count\">(' + count + 'x)</span> <span class=\"avg\">' + avg_cost + 'ds avg</span>';
		if(direct_cost > 0 && hasChildren) {
			const directAvg = formatNumber(direct_cost / Math.max(direct_count,1));
			info.innerHTML += ' (direct: ' + direct_cost + 'ds, ' + direct_count + 'x, ' + directAvg + 'ds avg) ';
		}
		info.innerHTML += ' <span class=\"percentage\">(' + percentage + '%)</span>';
		item.appendChild(info);

		container.appendChild(item);

		if(hasChildren) {
			const childContainer = document.createElement('div');
			childContainer.className = 'tree-node';
			childContainer.id = myId;
			container.appendChild(childContainer);
			// by default children are visible; toggle handler
			exp.addEventListener('click', ()=>{
				if(childContainer.style.display === 'none') { childContainer.style.display = 'block'; exp.textContent = '▼'; }
				else { childContainer.style.display = 'none'; exp.textContent = '▶'; }
			});
			renderTree(node.children, childContainer, totalCost, sortByAvg);
		}
	}
}

function renderAll() {
	const flat = (MODE === 'init') ? DATA.init : DATA.late;
	const tree = buildTree(flat);
	// compute totals
	let totalCost = 0, totalCount = 0, types = 0;
	for(const k in flat) { totalCost += (flat\[k\].cost || 0); totalCount += (flat\[k\].count || 0); types++; }

	const summary = document.getElementById('summary');
	summary.innerHTML = '<h2>' + (MODE === 'late' ? 'Late ' : '') + 'Initialization Cost Analysis</h2>' +
		'<b>Total ' + (MODE === 'late' ? 'Late ' : '') + 'Init Time:</b> ' + totalCost + ' ds (' + (formatNumber(totalCost/10)) + 's)<br>' +
		'<b>Total Instances:</b> ' + totalCount + '<br>' +
		'<b>Total Types:</b> ' + types + '<br>' +
		'<b>Average Cost:</b> ' + (formatNumber(totalCost / Math.max(totalCount,1))) + ' ds per instance<br>' +
		'<b>Sorting by:</b> ' + (SORT === 'avg' ? 'Average time per instance' : 'Total time');

	const root = document.getElementById('tree_root');
	clearChildren(root);
	idCounter = 0;
	renderTree(tree, root, totalCost, SORT === 'avg');
	// update buttons classes
	document.getElementById('btn_init').className = (MODE === 'init') ? 'active' : '';
	document.getElementById('btn_late').className = (MODE === 'late') ? 'active' : '';
	document.getElementById('btn_total').className = (SORT === 'total') ? 'active' : '';
	document.getElementById('btn_avg').className = (SORT === 'avg') ? 'active' : '';
}

function setMode(m) { if(MODE === m) return; MODE = m; renderAll(); }
function setSort(s) { if(SORT === s) return; SORT = s; renderAll(); }

renderAll();
</script>
"}


ADMIN_VERB(cmd_display_init_costs, R_DEBUG, FALSE, "Display Init Costs", "Displays initialization costs in a tree format", ADMIN_CATEGORY_DEBUG)
	if(alert(user, "Are you sure you want to view the initialization costs? This may take more than a minute to load.", "Confirm", "Yes", "No") != "Yes")
		return
	if(!LAZYLEN(SSatoms.init_costs))
		to_chat(user, span_notice("Init costs list is empty."))
	else
		var/datum/browser/panel = new(user, "initcosts", "Initialization Costs", 900, 600)
		panel.set_content(HTML_SKELETON(SSatoms.InitCostLog()))
		panel.open()

#endif
