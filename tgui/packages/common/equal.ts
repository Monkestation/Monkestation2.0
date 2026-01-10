export default function equal(a: unknown, b: unknown): boolean {
  if (a === b) return true;

  if (a && b && typeof a === 'object' && typeof b === 'object') {
    // constructors must match
    if ((a as any).constructor !== (b as any).constructor) return false;

    let length: number;
    let i: any;
    let keys: string[];

    // Arrays
    if (Array.isArray(a)) {
      if (!Array.isArray(b)) return false;
      length = a.length;
      if (length !== b.length) return false;
      for (i = length; i-- !== 0;) {
        if (!equal(a[i], b[i])) return false;
      }
      return true;
    }

    // Maps
    if (a instanceof Map && b instanceof Map) {
      if (a.size !== b.size) return false;
      for (const [key] of a.entries()) {
        if (!b.has(key)) return false;
      }
      for (const [key, value] of a.entries()) {
        if (!equal(value, b.get(key))) return false;
      }
      return true;
    }

    // Sets
    if (a instanceof Set && b instanceof Set) {
      if (a.size !== b.size) return false;
      for (const value of a.values()) {
        if (!b.has(value)) return false;
      }
      return true;
    }

    // Typed arrays / DataViews
    if (ArrayBuffer.isView(a) && ArrayBuffer.isView(b)) {
      const aa = a as unknown as ArrayLike<number>;
      const bb = b as unknown as ArrayLike<number>;
      length = aa.length;
      if (length !== bb.length) return false;
      for (i = length; i-- !== 0;) {
        if (aa[i] !== bb[i]) return false;
      }
      return true;
    }

    // RegExp
    if (a instanceof RegExp && b instanceof RegExp) {
      return a.source === b.source && a.flags === b.flags;
    }

    // valueOf override
    if ((a as any).valueOf !== Object.prototype.valueOf) {
      return (a as any).valueOf() === (b as any).valueOf();
    }

    // toString override
    if ((a as any).toString !== Object.prototype.toString) {
      return (a as any).toString() === (b as any).toString();
    }

    // Plain objects
    keys = Object.keys(a as object);
    length = keys.length;
    if (length !== Object.keys(b as object).length) return false;

    for (i = length; i-- !== 0;) {
      if (!Object.prototype.hasOwnProperty.call(b, keys[i])) return false;
    }

    for (i = length; i-- !== 0;) {
      const key = keys[i];

      // if (key === '_owner' && (a as any).$$typeof) continue;

      if (!equal((a as any)[key], (b as any)[key])) return false;
    }

    return true;
  }

  // NaN === NaN
  return a !== a && b !== b;
}
