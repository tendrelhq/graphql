// https://github.com/bryc/code/blob/master/jshash/PRNGs.md#splitmix32
export function splitmix32(a: number) {
  return () => {
    // biome-ignore lint/style/noParameterAssign:
    a |= 0;
    // biome-ignore lint/style/noParameterAssign:
    a = (a + 0x9e3779b9) | 0;
    let t = a ^ (a >>> 16);
    t = Math.imul(t, 0x21f0aaad);
    t = t ^ (t >>> 15);
    t = Math.imul(t, 0x735a2d97);
    // biome-ignore lint/suspicious/noAssignInExpressions:
    return ((t = t ^ (t >>> 15)) >>> 0) / 4294967296;
  };
}
