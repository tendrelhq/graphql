import { beforeEach, describe, expect, test } from "bun:test";
import { Trie } from "./Trie";

describe("Trie", () => {
  let trie: Trie<{
    term: string;
    type: string;
    popularity: number;
  }>;

  beforeEach(() => {
    trie = new Trie();

    const terms = [
      "javascript",
      "typescript",
      "java",
      "python",
      "react",
      "redux",
      "angular",
      "vue",
      "node",
      "npm",
      "next.js",
      "express",
      "nestjs",
      "nuxt",
      "component",
      "context",
      "container",
      "function",
      "functional",
      "hook",
      "hooks",
      "state",
      "store",
      "props",
      "properties",
    ];

    for (const term of terms) {
      trie.insert(term, {
        term,
        type: term.length > 6 ? "language" : "concept",
        popularity: Math.floor(Math.random() * 100) + 1,
      });
    }
  });

  test("basic prefix search", () => {
    const results = trie.findAllWithPrefix("ja");
    expect(results).toContain("javascript");
    expect(results).toContain("java");
    expect(results).not.toContain("typescript");
  });

  test("with empty input", () => {
    const results = trie.findAllWithPrefix("");
    // Should return all terms
    expect(results.length).toBe(25);
  });

  test("with no matches", () => {
    const results = trie.findAllWithPrefix("kotlin");
    expect(results.length).toBe(0);
  });

  test("autocomplete", () => {
    const mockInput = {
      value: "",
      suggestions: [] as string[],
      selectedIndex: -1,

      updateInput(text: string) {
        this.value = text;
        this.updateSuggestions();
        return this;
      },

      updateSuggestions() {
        this.suggestions = trie.findAllWithPrefix(this.value);
        this.selectedIndex = this.suggestions.length > 0 ? 0 : -1;
        return this;
      },

      moveSelection(direction: "up" | "down") {
        if (this.suggestions.length === 0) return this;

        if (direction === "down") {
          this.selectedIndex =
            (this.selectedIndex + 1) % this.suggestions.length;
        } else {
          this.selectedIndex =
            this.selectedIndex <= 0
              ? this.suggestions.length - 1
              : this.selectedIndex - 1;
        }
        return this;
      },

      selectSuggestion() {
        if (this.selectedIndex >= 0 && this.suggestions.length > 0) {
          this.value = this.suggestions[this.selectedIndex];
          this.suggestions = [];
          this.selectedIndex = -1;
        }
        return this;
      },
    };

    mockInput.updateInput("re");
    expect(mockInput.suggestions).toContain("react");
    expect(mockInput.suggestions).toContain("redux");
    expect(mockInput.suggestions.length).toBe(2);
    expect(mockInput.selectedIndex).toBe(0);

    mockInput.moveSelection("down");
    expect(mockInput.selectedIndex).toBe(1);

    mockInput.selectSuggestion();
    expect(mockInput.value).toBe("redux");
    expect(mockInput.suggestions.length).toBe(0);

    mockInput.updateInput("n");
    expect(mockInput.suggestions).toContain("node");
    expect(mockInput.suggestions).toContain("npm");
    expect(mockInput.suggestions).toContain("next.js");
    expect(mockInput.suggestions).toContain("nestjs");
    expect(mockInput.suggestions).toContain("nuxt");
    expect(mockInput.suggestions.length).toBe(5);

    mockInput.updateInput("ne");
    expect(mockInput.suggestions).toContain("next.js");
    expect(mockInput.suggestions).toContain("nestjs");
    expect(mockInput.suggestions.length).toBe(2);
  });

  test("autocomplete with metadata", () => {
    const reactNode = trie.findNode("react");
    expect(reactNode).toBeTruthy();
    expect(reactNode?.value?.term).toBe("react");
    expect(reactNode?.value?.type).toBe("concept");
    expect(typeof reactNode?.value?.popularity).toBe("number");

    function getSmartSuggestions(
      prefix: string,
      limit = 5,
    ): Array<{ term: string; score: number }> {
      const matches = trie.findAllWithPrefix(prefix);

      const matchesWithMeta = matches.map(match => {
        const node = trie.findNode(match);
        return {
          term: match,
          score:
            (node?.value?.popularity || 0) *
            (match.startsWith(prefix) ? 2 : 1) * // Boost exact prefix matches
            (1 / Math.max(1, match.length - prefix.length)), // Shorter completions score higher
        };
      });

      return matchesWithMeta.sort((a, b) => b.score - a.score).slice(0, limit);
    }

    const smartSuggestions = getSmartSuggestions("c");
    expect(smartSuggestions.length).toBeGreaterThan(0);
    expect(smartSuggestions.length).toBeLessThanOrEqual(5);

    expect(smartSuggestions[0].term).toBeDefined();
    expect(typeof smartSuggestions[0].score).toBe("number");

    for (let i = 1; i < smartSuggestions.length; i++) {
      expect(smartSuggestions[i - 1].score).toBeGreaterThanOrEqual(
        smartSuggestions[i].score,
      );
    }
  });
});
