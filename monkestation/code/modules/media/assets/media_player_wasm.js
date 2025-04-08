let wasm_bindgen;
(function() {
    const __exports = {};
    let script_src;
    if (typeof document !== 'undefined' && document.currentScript !== null) {
        script_src = new URL(document.currentScript.src, location.href).toString();
    }
    let wasm = undefined;
    const lAudioContext = (typeof AudioContext !== 'undefined' ? AudioContext : (typeof webkitAudioContext !== 'undefined' ? webkitAudioContext : undefined));

    function addToExternrefTable0(obj) {
        const idx = wasm.__externref_table_alloc();
        wasm.__wbindgen_export_2.set(idx, obj);
        return idx;
    }

    function handleError(f, args) {
        try {
            return f.apply(this, args);
        } catch (e) {
            const idx = addToExternrefTable0(e);
            wasm.__wbindgen_exn_store(idx);
        }
    }

    function isLikeNone(x) {
        return x === undefined || x === null;
    }

    const cachedTextDecoder = (typeof TextDecoder !== 'undefined' ? new TextDecoder('utf-8', { ignoreBOM: true, fatal: true }) : { decode: () => { throw Error('TextDecoder not available') } } );

    if (typeof TextDecoder !== 'undefined') { cachedTextDecoder.decode(); };

    let cachedUint8ArrayMemory0 = null;

    function getUint8ArrayMemory0() {
        if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
            cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
        }
        return cachedUint8ArrayMemory0;
    }

    function getStringFromWasm0(ptr, len) {
        ptr = ptr >>> 0;
        return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
    }

    const CLOSURE_DTORS = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(state => {
        wasm.__wbindgen_export_3.get(state.dtor)(state.a, state.b)
    });

    function makeMutClosure(arg0, arg1, dtor, f) {
        const state = { a: arg0, b: arg1, cnt: 1, dtor };
        const real = (...args) => {
            // First up with a closure we increment the internal reference
            // count. This ensures that the Rust closure environment won't
            // be deallocated while we're invoking it.
            state.cnt++;
            const a = state.a;
            state.a = 0;
            try {
                return f(a, state.b, ...args);
            } finally {
                if (--state.cnt === 0) {
                    wasm.__wbindgen_export_3.get(state.dtor)(a, state.b);
                    CLOSURE_DTORS.unregister(state);
                } else {
                    state.a = a;
                }
            }
        };
        real.original = state;
        CLOSURE_DTORS.register(real, state, state);
        return real;
    }

    function debugString(val) {
        // primitive types
        const type = typeof val;
        if (type == 'number' || type == 'boolean' || val == null) {
            return  `${val}`;
        }
        if (type == 'string') {
            return `"${val}"`;
        }
        if (type == 'symbol') {
            const description = val.description;
            if (description == null) {
                return 'Symbol';
            } else {
                return `Symbol(${description})`;
            }
        }
        if (type == 'function') {
            const name = val.name;
            if (typeof name == 'string' && name.length > 0) {
                return `Function(${name})`;
            } else {
                return 'Function';
            }
        }
        // objects
        if (Array.isArray(val)) {
            const length = val.length;
            let debug = '[';
            if (length > 0) {
                debug += debugString(val[0]);
            }
            for(let i = 1; i < length; i++) {
                debug += ', ' + debugString(val[i]);
            }
            debug += ']';
            return debug;
        }
        // Test for built-in
        const builtInMatches = /\[object ([^\]]+)\]/.exec(toString.call(val));
        let className;
        if (builtInMatches && builtInMatches.length > 1) {
            className = builtInMatches[1];
        } else {
            // Failed to match the standard '[object ClassName]'
            return toString.call(val);
        }
        if (className == 'Object') {
            // we're a user defined class or Object
            // JSON.stringify avoids problems with cycles, and is generally much
            // easier than looping through ownProperties of `val`.
            try {
                return 'Object(' + JSON.stringify(val) + ')';
            } catch (_) {
                return 'Object';
            }
        }
        // errors
        if (val instanceof Error) {
            return `${val.name}: ${val.message}\n${val.stack}`;
        }
        // TODO we could test for more things here, like `Set`s and `Map`s.
        return className;
    }

    let WASM_VECTOR_LEN = 0;

    const cachedTextEncoder = (typeof TextEncoder !== 'undefined' ? new TextEncoder('utf-8') : { encode: () => { throw Error('TextEncoder not available') } } );

    const encodeString = (typeof cachedTextEncoder.encodeInto === 'function'
        ? function (arg, view) {
        return cachedTextEncoder.encodeInto(arg, view);
    }
        : function (arg, view) {
        const buf = cachedTextEncoder.encode(arg);
        view.set(buf);
        return {
            read: arg.length,
            written: buf.length
        };
    });

    function passStringToWasm0(arg, malloc, realloc) {

        if (realloc === undefined) {
            const buf = cachedTextEncoder.encode(arg);
            const ptr = malloc(buf.length, 1) >>> 0;
            getUint8ArrayMemory0().subarray(ptr, ptr + buf.length).set(buf);
            WASM_VECTOR_LEN = buf.length;
            return ptr;
        }

        let len = arg.length;
        let ptr = malloc(len, 1) >>> 0;

        const mem = getUint8ArrayMemory0();

        let offset = 0;

        for (; offset < len; offset++) {
            const code = arg.charCodeAt(offset);
            if (code > 0x7F) break;
            mem[ptr + offset] = code;
        }

        if (offset !== len) {
            if (offset !== 0) {
                arg = arg.slice(offset);
            }
            ptr = realloc(ptr, len, len = offset + arg.length * 3, 1) >>> 0;
            const view = getUint8ArrayMemory0().subarray(ptr + offset, ptr + len);
            const ret = encodeString(arg, view);

            offset += ret.written;
            ptr = realloc(ptr, len, offset, 1) >>> 0;
        }

        WASM_VECTOR_LEN = offset;
        return ptr;
    }

    let cachedDataViewMemory0 = null;

    function getDataViewMemory0() {
        if (cachedDataViewMemory0 === null || cachedDataViewMemory0.buffer.detached === true || (cachedDataViewMemory0.buffer.detached === undefined && cachedDataViewMemory0.buffer !== wasm.memory.buffer)) {
            cachedDataViewMemory0 = new DataView(wasm.memory.buffer);
        }
        return cachedDataViewMemory0;
    }

    function takeFromExternrefTable0(idx) {
        const value = wasm.__wbindgen_export_2.get(idx);
        wasm.__externref_table_dealloc(idx);
        return value;
    }
    function __wbg_adapter_18(arg0, arg1, arg2) {
        wasm.closure18_externref_shim(arg0, arg1, arg2);
    }

    function __wbg_adapter_92(arg0, arg1, arg2, arg3) {
        wasm.closure30_externref_shim(arg0, arg1, arg2, arg3);
    }

    const __wbindgen_enum_DistanceModelType = ["linear", "inverse", "exponential"];

    const __wbindgen_enum_PanningModelType = ["equalpower", "HRTF"];

    const SpatialAudioPlayerFinalization = (typeof FinalizationRegistry === 'undefined')
        ? { register: () => {}, unregister: () => {} }
        : new FinalizationRegistry(ptr => wasm.__wbg_spatialaudioplayer_free(ptr >>> 0, 1));

    class SpatialAudioPlayer {

        __destroy_into_raw() {
            const ptr = this.__wbg_ptr;
            this.__wbg_ptr = 0;
            SpatialAudioPlayerFinalization.unregister(this);
            return ptr;
        }

        free() {
            const ptr = this.__destroy_into_raw();
            wasm.__wbg_spatialaudioplayer_free(ptr, 0);
        }
        constructor() {
            const ret = wasm.spatialaudioplayer_new();
            if (ret[2]) {
                throw takeFromExternrefTable0(ret[1]);
            }
            this.__wbg_ptr = ret[0] >>> 0;
            SpatialAudioPlayerFinalization.register(this, this.__wbg_ptr, this);
            return this;
        }
        /**
         * @param {string} url
         */
        set_url(url) {
            const ptr0 = passStringToWasm0(url, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len0 = WASM_VECTOR_LEN;
            const ret = wasm.spatialaudioplayer_set_url(this.__wbg_ptr, ptr0, len0);
            if (ret[1]) {
                throw takeFromExternrefTable0(ret[0]);
            }
        }
        /**
         * @param {number} x
         * @param {number} y
         */
        set_position(x, y) {
            const ret = wasm.spatialaudioplayer_set_position(this.__wbg_ptr, x, y);
            if (ret[1]) {
                throw takeFromExternrefTable0(ret[0]);
            }
        }
        /**
         * @param {number} time
         */
        set_time(time) {
            wasm.spatialaudioplayer_set_time(this.__wbg_ptr, time);
        }
        /**
         * @returns {Promise<void>}
         */
        play() {
            const ret = wasm.spatialaudioplayer_play(this.__wbg_ptr);
            return ret;
        }
        pause() {
            const ret = wasm.spatialaudioplayer_pause(this.__wbg_ptr);
            if (ret[1]) {
                throw takeFromExternrefTable0(ret[0]);
            }
        }
        stop() {
            const ret = wasm.spatialaudioplayer_stop(this.__wbg_ptr);
            if (ret[1]) {
                throw takeFromExternrefTable0(ret[0]);
            }
        }
    }
    __exports.SpatialAudioPlayer = SpatialAudioPlayer;

    async function __wbg_load(module, imports) {
        if (typeof Response === 'function' && module instanceof Response) {
            if (typeof WebAssembly.instantiateStreaming === 'function') {
                try {
                    return await WebAssembly.instantiateStreaming(module, imports);

                } catch (e) {
                    if (module.headers.get('Content-Type') != 'application/wasm') {
                        console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                    } else {
                        throw e;
                    }
                }
            }

            const bytes = await module.arrayBuffer();
            return await WebAssembly.instantiate(bytes, imports);

        } else {
            const instance = await WebAssembly.instantiate(module, imports);

            if (instance instanceof WebAssembly.Instance) {
                return { instance, module };

            } else {
                return instance;
            }
        }
    }

    function __wbg_get_imports() {
        const imports = {};
        imports.wbg = {};
        imports.wbg.__wbg_call_672a4d21634d4a24 = function() { return handleError(function (arg0, arg1) {
            const ret = arg0.call(arg1);
            return ret;
        }, arguments) };
        imports.wbg.__wbg_call_7cccdd69e0791ae2 = function() { return handleError(function (arg0, arg1, arg2) {
            const ret = arg0.call(arg1, arg2);
            return ret;
        }, arguments) };
        imports.wbg.__wbg_connect_b22945d106632a36 = function() { return handleError(function (arg0, arg1) {
            const ret = arg0.connect(arg1);
            return ret;
        }, arguments) };
        imports.wbg.__wbg_createMediaElementSource_a234914f1c6b1bbc = function() { return handleError(function (arg0, arg1) {
            const ret = arg0.createMediaElementSource(arg1);
            return ret;
        }, arguments) };
        imports.wbg.__wbg_createPanner_73deb9b89334e5e4 = function() { return handleError(function (arg0) {
            const ret = arg0.createPanner();
            return ret;
        }, arguments) };
        imports.wbg.__wbg_currentTime_adef4d803f58eb66 = function(arg0) {
            const ret = arg0.currentTime;
            return ret;
        };
        imports.wbg.__wbg_destination_6400091abd6f01b3 = function(arg0) {
            const ret = arg0.destination;
            return ret;
        };
        imports.wbg.__wbg_document_d249400bd7bd996d = function(arg0) {
            const ret = arg0.document;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_getElementById_f827f0d6648718a8 = function(arg0, arg1, arg2) {
            const ret = arg0.getElementById(getStringFromWasm0(arg1, arg2));
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_instanceof_HtmlAudioElement_3c635ee8f8b85c84 = function(arg0) {
            let result;
            try {
                result = arg0 instanceof HTMLAudioElement;
            } catch (_) {
                result = false;
            }
            const ret = result;
            return ret;
        };
        imports.wbg.__wbg_instanceof_Window_def73ea0955fc569 = function(arg0) {
            let result;
            try {
                result = arg0 instanceof Window;
            } catch (_) {
                result = false;
            }
            const ret = result;
            return ret;
        };
        imports.wbg.__wbg_new_23a2665fac83c611 = function(arg0, arg1) {
            try {
                var state0 = {a: arg0, b: arg1};
                var cb0 = (arg0, arg1) => {
                    const a = state0.a;
                    state0.a = 0;
                    try {
                        return __wbg_adapter_92(a, state0.b, arg0, arg1);
                    } finally {
                        state0.a = a;
                    }
                };
                const ret = new Promise(cb0);
                return ret;
            } finally {
                state0.a = state0.b = 0;
            }
        };
        imports.wbg.__wbg_new_4b3dfb29a594e831 = function() { return handleError(function () {
            const ret = new lAudioContext();
            return ret;
        }, arguments) };
        imports.wbg.__wbg_newnoargs_105ed471475aaf50 = function(arg0, arg1) {
            const ret = new Function(getStringFromWasm0(arg0, arg1));
            return ret;
        };
        imports.wbg.__wbg_pause_b74c96d69f769518 = function() { return handleError(function (arg0) {
            arg0.pause();
        }, arguments) };
        imports.wbg.__wbg_play_f6ec5fc4e84b0d26 = function() { return handleError(function (arg0) {
            const ret = arg0.play();
            return ret;
        }, arguments) };
        imports.wbg.__wbg_positionX_1b0d2c183f784f11 = function(arg0) {
            const ret = arg0.positionX;
            return ret;
        };
        imports.wbg.__wbg_positionY_471071df49efb5dd = function(arg0) {
            const ret = arg0.positionY;
            return ret;
        };
        imports.wbg.__wbg_positionZ_750a710b3705a74a = function(arg0) {
            const ret = arg0.positionZ;
            return ret;
        };
        imports.wbg.__wbg_queueMicrotask_97d92b4fcc8a61c5 = function(arg0) {
            queueMicrotask(arg0);
        };
        imports.wbg.__wbg_queueMicrotask_d3219def82552485 = function(arg0) {
            const ret = arg0.queueMicrotask;
            return ret;
        };
        imports.wbg.__wbg_resolve_4851785c9c5f573d = function(arg0) {
            const ret = Promise.resolve(arg0);
            return ret;
        };
        imports.wbg.__wbg_setValueAtTime_a5524bd9d9e529c4 = function() { return handleError(function (arg0, arg1, arg2) {
            const ret = arg0.setValueAtTime(arg1, arg2);
            return ret;
        }, arguments) };
        imports.wbg.__wbg_setconeInnerAngle_cb9f351fb7cc0de2 = function(arg0, arg1) {
            arg0.coneInnerAngle = arg1;
        };
        imports.wbg.__wbg_setconeOuterAngle_196b3182f41e879f = function(arg0, arg1) {
            arg0.coneOuterAngle = arg1;
        };
        imports.wbg.__wbg_setconeOuterGain_7ac38b735414c839 = function(arg0, arg1) {
            arg0.coneOuterGain = arg1;
        };
        imports.wbg.__wbg_setcrossOrigin_999029ac31b6f930 = function(arg0, arg1, arg2) {
            arg0.crossOrigin = arg1 === 0 ? undefined : getStringFromWasm0(arg1, arg2);
        };
        imports.wbg.__wbg_setcurrentTime_64727eddd3966512 = function(arg0, arg1) {
            arg0.currentTime = arg1;
        };
        imports.wbg.__wbg_setdistanceModel_be78d46ade19ae80 = function(arg0, arg1) {
            arg0.distanceModel = __wbindgen_enum_DistanceModelType[arg1];
        };
        imports.wbg.__wbg_setmaxDistance_8e51314a1c12e8f6 = function(arg0, arg1) {
            arg0.maxDistance = arg1;
        };
        imports.wbg.__wbg_setmuted_e93fc48340c43e67 = function(arg0, arg1) {
            arg0.muted = arg1 !== 0;
        };
        imports.wbg.__wbg_setpanningModel_7bdf9ef858c79d47 = function(arg0, arg1) {
            arg0.panningModel = __wbindgen_enum_PanningModelType[arg1];
        };
        imports.wbg.__wbg_setrefDistance_b258705999037780 = function(arg0, arg1) {
            arg0.refDistance = arg1;
        };
        imports.wbg.__wbg_setrolloffFactor_990040c7ccba9ad7 = function(arg0, arg1) {
            arg0.rolloffFactor = arg1;
        };
        imports.wbg.__wbg_setsrc_3a759736e2659904 = function(arg0, arg1, arg2) {
            arg0.src = getStringFromWasm0(arg1, arg2);
        };
        imports.wbg.__wbg_static_accessor_GLOBAL_88a902d13a557d07 = function() {
            const ret = typeof global === 'undefined' ? null : global;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_static_accessor_GLOBAL_THIS_56578be7e9f832b0 = function() {
            const ret = typeof globalThis === 'undefined' ? null : globalThis;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_static_accessor_SELF_37c5d418e4bf5819 = function() {
            const ret = typeof self === 'undefined' ? null : self;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_static_accessor_WINDOW_5de37043a91a9c40 = function() {
            const ret = typeof window === 'undefined' ? null : window;
            return isLikeNone(ret) ? 0 : addToExternrefTable0(ret);
        };
        imports.wbg.__wbg_then_44b73946d2fb3e7d = function(arg0, arg1) {
            const ret = arg0.then(arg1);
            return ret;
        };
        imports.wbg.__wbg_then_48b406749878a531 = function(arg0, arg1, arg2) {
            const ret = arg0.then(arg1, arg2);
            return ret;
        };
        imports.wbg.__wbindgen_cb_drop = function(arg0) {
            const obj = arg0.original;
            if (obj.cnt-- == 1) {
                obj.a = 0;
                return true;
            }
            const ret = false;
            return ret;
        };
        imports.wbg.__wbindgen_closure_wrapper399 = function(arg0, arg1, arg2) {
            const ret = makeMutClosure(arg0, arg1, 19, __wbg_adapter_18);
            return ret;
        };
        imports.wbg.__wbindgen_debug_string = function(arg0, arg1) {
            const ret = debugString(arg1);
            const ptr1 = passStringToWasm0(ret, wasm.__wbindgen_malloc, wasm.__wbindgen_realloc);
            const len1 = WASM_VECTOR_LEN;
            getDataViewMemory0().setInt32(arg0 + 4 * 1, len1, true);
            getDataViewMemory0().setInt32(arg0 + 4 * 0, ptr1, true);
        };
        imports.wbg.__wbindgen_init_externref_table = function() {
            const table = wasm.__wbindgen_export_2;
            const offset = table.grow(4);
            table.set(0, undefined);
            table.set(offset + 0, undefined);
            table.set(offset + 1, null);
            table.set(offset + 2, true);
            table.set(offset + 3, false);
            ;
        };
        imports.wbg.__wbindgen_is_function = function(arg0) {
            const ret = typeof(arg0) === 'function';
            return ret;
        };
        imports.wbg.__wbindgen_is_undefined = function(arg0) {
            const ret = arg0 === undefined;
            return ret;
        };
        imports.wbg.__wbindgen_throw = function(arg0, arg1) {
            throw new Error(getStringFromWasm0(arg0, arg1));
        };

        return imports;
    }

    function __wbg_init_memory(imports, memory) {

    }

    function __wbg_finalize_init(instance, module) {
        wasm = instance.exports;
        __wbg_init.__wbindgen_wasm_module = module;
        cachedDataViewMemory0 = null;
        cachedUint8ArrayMemory0 = null;


        wasm.__wbindgen_start();
        return wasm;
    }

    function initSync(module) {
        if (wasm !== undefined) return wasm;


        if (typeof module !== 'undefined') {
            if (Object.getPrototypeOf(module) === Object.prototype) {
                ({module} = module)
            } else {
                console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
            }
        }

        const imports = __wbg_get_imports();

        __wbg_init_memory(imports);

        if (!(module instanceof WebAssembly.Module)) {
            module = new WebAssembly.Module(module);
        }

        const instance = new WebAssembly.Instance(module, imports);

        return __wbg_finalize_init(instance, module);
    }

    async function __wbg_init(module_or_path) {
        if (wasm !== undefined) return wasm;


        if (typeof module_or_path !== 'undefined') {
            if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
                ({module_or_path} = module_or_path)
            } else {
                console.warn('using deprecated parameters for the initialization function; pass a single object instead')
            }
        }

        if (typeof module_or_path === 'undefined' && typeof script_src !== 'undefined') {
            module_or_path = script_src.replace(/\.js$/, '_bg.wasm');
        }
        const imports = __wbg_get_imports();

        if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
            module_or_path = fetch(module_or_path);
        }

        __wbg_init_memory(imports);

        const { instance, module } = await __wbg_load(await module_or_path, imports);

        return __wbg_finalize_init(instance, module);
    }

    wasm_bindgen = Object.assign(__wbg_init, { initSync }, __exports);

})();
