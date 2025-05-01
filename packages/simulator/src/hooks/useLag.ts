import assert from "node:assert";
import { useMemo } from "react";

/**
 * Return the last `n` elements from `arr` *excluding* the first element.
 */
export function useLag<T>(arr: readonly T[], n = 10) {
  assert(n > 0, "useLag: n > 0");
  return useMemo(() => {
    if (arr.length <= 1) return [];
    const arr2 = arr.slice(1);
    if (n >= arr2.length) return arr2;
    return arr2.slice(-n);
  }, [arr, n]);
}
