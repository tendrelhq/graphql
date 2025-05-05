import { assert, mapOrElse } from "@/util";
import { Faker, en } from "@faker-js/faker";
import { Box, Text, useInput } from "ink";
import { Suspense, useMemo, useState } from "react";
import { P, match } from "ts-pattern";
import type { User_fragment$key } from "../../__generated__/User_fragment.graphql";
import Loading from "../Loading";
import Configure from "./Configure";
import Run from "./Run";
import Setup from "./Setup";

type States = {
  // biome-ignore lint/complexity/noBannedTypes:
  "%unset%": {};
  setup: {
    seed: number;
    faker: Faker;
  };
  configure: {
    seed: number;
    faker: Faker;
    customerId: string;
  };
  run: {
    seed: number;
    faker: Faker;
    customerId: string;
    templateId: string;
  };
};

type Entries<T> = {
  [K in keyof T]: [K, T[K]];
}[keyof T];

type State = Entries<States>;

export function Simulator(props: { user: User_fragment$key }) {
  const [active, setActive] = useState<State>(["%unset%", {}]);

  const seed = useMemo(() => {
    return mapOrElse(
      process.env.SEED,
      seed => {
        const s = Number.parseInt(seed);
        assert(Number.isFinite(s), "invalid seed");
        return s;
      },
      Date.now(),
    );
  }, []);
  const faker = useMemo(() => {
    return new Faker({ locale: [en], seed });
  }, [seed]);

  useInput((input, key) => {
    if (active[0] === "%unset%" && input === " ") {
      setActive(["setup", { faker, seed }]);
      return;
    }
  });

  return (
    <Box flexDirection="column">
      <Text color="gray">Seed: {seed}</Text>
      {match(active)
        .with(["%unset%", P._], () => (
          <>
            <Text color="blue">Welcome to the Simulator!</Text>
            <Text>Press {"<space>"} to start a new simulation.</Text>
          </>
        ))
        .with(["setup", P.select()], opts => (
          <Suspense fallback={<Loading />}>
            <Setup
              {...opts}
              user={props.user}
              onSelect={customerId =>
                setActive(["configure", { ...opts, customerId }])
              }
            />
          </Suspense>
        ))
        .with(["configure", P.select()], opts => (
          <Suspense fallback={<Loading />}>
            <Configure
              {...opts}
              onSelect={templateId =>
                setActive(["run", { ...opts, templateId }])
              }
            />
          </Suspense>
        ))
        .with(["run", P.select()], opts => (
          <Suspense fallback={<Loading />}>
            <Run {...opts} />
          </Suspense>
        ))
        .exhaustive()}
    </Box>
  );
}
