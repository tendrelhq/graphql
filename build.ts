import pattycake from "pattycake";

await Bun.build({
  entrypoints: ["./bin/dev.ts"],
  outdir: "./out",
  target: "bun",
  plugins: [
    // pattycake: for ts-pattern
    pattycake.esbuild({ disableOptionalChaining: true }),
  ],
});
