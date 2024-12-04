import { $ } from "bun";
import pattycake from "pattycake";

// clean
await $`rimraf lib/schema/__generated__ out`;

// codegen
await $`bun generate.ts`;

// typecheck
await $`tsc`;

// build
const out = await Bun.build({
  entrypoints: ["./bin/app.ts"],
  outdir: "./out",
  target: "bun",
  plugins: [
    // pattycake: for ts-pattern
    pattycake.esbuild({ disableOptionalChaining: true }),
    // allows for: `import contents from "./foo.gql"; => string`
    {
      name: "inline-graphql",
      setup(build) {
        build.onLoad(
          {
            filter: /\.gql$/,
          },
          async args => {
            return {
              loader: "text",
              contents: await Bun.file(args.path).text(),
            };
          },
        );
      },
    },
  ],
});

for (const line of out.logs) {
  console.log(line);
}

process.exit(out.success ? 0 : 1);
