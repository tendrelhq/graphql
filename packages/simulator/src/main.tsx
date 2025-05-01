import { Text, render } from "ink";
import { Suspense } from "react";
import { ErrorBoundary, type FallbackProps } from "react-error-boundary";
import { RelayEnvironmentProvider } from "react-relay";
import { App } from "./components/App";
import { RexRoot } from "./hooks/useRex";
import { createEnvironment } from "./relay/environment";

// Runtime simulator v0
//
// For now there will be just a single configuration which will consist of a
// Batch + Reason Code enabled factory demo. The demo defines the canonical 5
// lines: mixing, fill, assembly, cartoning and packaging. There are also 5
// workers, one per line, in addition to 2 supervisors. The goal is to move 5
// batches through the factory. Each line can only run a single batch at a time.
// The inverse, however, does not hold: a batch can be active at multiple lines
// simultaneously.
//
// Furthermore: for this version will assume perfect harmony, i.e. no conflicts.
// Each worker will operate in perfect isolation, no stepping on each other's
// toes!
//
// Supervisors are included purely for perspective. Perhaps they are floating
// between the lines, and are therefore interested in cross-location (i.e.
// batch-level) progress. Doesn't matter. I made it up. Enjoy :)

const environment = createEnvironment();

const Fallback = (props: FallbackProps) => {
  console.error(props.error);
  return <Text color="red">{props.error?.message ?? "Unknown error"}</Text>;
};

const Main = () => {
  return (
    <ErrorBoundary FallbackComponent={Fallback}>
      <Suspense>
        <RelayEnvironmentProvider environment={environment}>
          <RexRoot>
            <App />
          </RexRoot>
        </RelayEnvironmentProvider>
      </Suspense>
    </ErrorBoundary>
  );
};

render(<Main />);
