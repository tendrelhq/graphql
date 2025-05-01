class TrieNode<T> {
  children: Map<string, TrieNode<T>>;
  endOfWord: boolean;
  value?: T;

  constructor() {
    this.children = new Map<string, TrieNode<T>>();
    this.endOfWord = false;
  }
}

interface TrieOptions {
  /** @default false */
  caseSensitive: boolean;
}

export class Trie<T = never> {
  #options: TrieOptions;
  root: TrieNode<T>;

  constructor() {
    this.#options = {
      caseSensitive: false,
    };
    this.root = new TrieNode();
  }

  insert(word: string, value?: T) {
    let current = this.root;

    for (const char of word) {
      const term = this.#options.caseSensitive ? char : char.toLowerCase();
      if (!current.children.has(term)) {
        current.children.set(term, new TrieNode());
      }
      // biome-ignore lint/style/noNonNullAssertion:
      current = current.children.get(term)!;
    }

    current.endOfWord = true;
    if (value) {
      current.value = value;
    }
  }

  search(word: string) {
    const node = this.findNode(word);
    return node?.endOfWord === true;
  }

  startsWith(prefix: string) {
    return !!this.findNode(prefix);
  }

  findNode(prefix: string): TrieNode<T> | undefined {
    let current = this.root;

    for (const char of this.#options.caseSensitive
      ? prefix
      : prefix.toLowerCase()) {
      if (!current.children.has(char)) {
        return;
      }
      // biome-ignore lint/style/noNonNullAssertion:
      current = current.children.get(char)!;
    }

    return current;
  }

  findAllWithPrefix(prefix: string) {
    const result: string[] = [];
    const node = this.findNode(prefix);
    if (node) this.collectWords(node, prefix, result);
    return result;
  }

  findAllNodesWithPrefix(prefix: string) {
    const result: TrieNode<T>[] = [];
    const node = this.findNode(prefix);
    if (node) this.collectNodes(node, prefix, result);
    return result;
  }

  private collectWords(node: TrieNode<T>, prefix: string, result: string[]) {
    if (node.endOfWord) result.push(prefix);
    for (const [char, childNode] of node.children.entries()) {
      this.collectWords(childNode, prefix + char, result);
    }
  }

  private collectNodes(
    node: TrieNode<T>,
    prefix: string,
    result: TrieNode<T>[],
  ) {
    if (node.endOfWord) result.push(node);
    for (const [char, childNode] of node.children.entries()) {
      this.collectNodes(childNode, prefix + char, result);
    }
  }

  delete(word: string) {
    return this.deleteRecursive(this.root, word, 0);
  }

  private deleteRecursive(current: TrieNode<T>, word: string, index: number) {
    if (index === word.length) {
      if (!current.endOfWord) {
        return false;
      }

      current.endOfWord = false;
      return current.children.size === 0;
    }

    const char = word[index];
    if (!current.children.has(char)) {
      return false;
    }

    const shouldDeleteCurrentNode = this.deleteRecursive(
      // biome-ignore lint/style/noNonNullAssertion:
      current.children.get(char)!,
      word,
      index + 1,
    );

    if (shouldDeleteCurrentNode) {
      current.children.delete(char);
      return current.children.size === 0 && !current.endOfWord;
    }

    return false;
  }
}
