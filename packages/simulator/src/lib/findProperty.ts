export function findProperty(obj: object, name: string) {
  const path: string[] = [];
  const queue: [object, string[]][] = [[obj, []]];

  while (queue.length > 0) {
    // biome-ignore lint/style/noNonNullAssertion:
    const [current, currentPath] = queue.shift()!;

    for (const [key, value] of Object.entries(current)) {
      const newPath = [...currentPath, key];

      if (key === name) {
        return newPath;
      }

      if (value && typeof value === "object") {
        queue.push([value, newPath]);
      }
    }
  }

  return path;
}
