import { assertNonNull, map } from "@/util";
import { Text, render } from "ink";
import { Suspense } from "react";
import { ErrorBoundary, type FallbackProps } from "react-error-boundary";
import { RelayEnvironmentProvider } from "react-relay";
import {
  Environment,
  type FetchFunction,
  Network,
  Observable,
  RecordSource,
  Store,
} from "relay-runtime";
import { App } from "./components/App";
import { ModeControl } from "./components/simulator/mode";
import Loading from "./components/Loading";

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

// TODO: OAuth.
const X_TENDREL_USER = assertNonNull(
  process.env.X_TENDREL_USER,
  "Set the X_TENDREL_USER environment variable to the workeridentityid of your choosing. This in lieu of a legitimate commandline authentication flow.",
);

/**
 * Set the INJECT_LATENCY environment variable to add arbitrary latency to
 * network requests, e.g. `INJECT_LATENCY=2000 bun simulator:start` will add
 * 2000 ms of latency to every request.
 */
const injectLatency = map(process.env.INJECT_LATENCY, s => {
  const ms = Number.parseInt(s);
  if (Number.isFinite(ms)) return ms;
  return;
});

const fetchFn: FetchFunction = (params, variables) => {
  const p = new Promise(resolve => {
    if (injectLatency) {
      setTimeout(resolve, injectLatency);
      return;
    }
    resolve(undefined);
  }).then(async () => {
    const res = await fetch("http://localhost:4000", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Tendrel-User": X_TENDREL_USER,
      },
      body: JSON.stringify({
        query: params.text,
        variables,
      }),
    });
    return await res.json();
  });

  return Observable.from(p);
};

function createEnvironment() {
  const network = Network.create(fetchFn);
  const store = new Store(new RecordSource());
  return new Environment({ store, network });
}

const environment = createEnvironment();

/*
const Batch = ({ queryRef }: { queryRef: AppBatch_fragment$key }) => {
  const data = useFragment(AppBatchFragment, queryRef);

  const batchId = data.id.substring(data.id.length - 8);
  const batchState = data.state?.__typename;

  if (!data.fsm?.active) {
    return (
      <Text color="yellow">
        Batch [
        <Text color="gray" bold>
          {batchId}
        </Text>
        ]: is currently <Text bold>{batchState}</Text> but has no state machine?
      </Text>
    );
  }

  return (
    <Box flexDirection="column">
      <Text>
        #
        <Text color="blue" bold>
          {batchId}
        </Text>
        : {batchState} @ {data.parent?.name?.value}
      </Text>
      <Box flexDirection="column" marginX={2}>
        {data.fields.edges.map(e => (
          <Field key={e.node.id} queryRef={e.node} />
        ))}
      </Box>
    </Box>
  );
};

let nextBatchId = 0;

const SubmitGeneratedBatch = (props: { onSubmit: () => void }) => {
  const { isFocused } = useFocus({ autoFocus: false });
  return (
    <Box>
      <Text color={isFocused ? "green" : "gray"}>
        Press <Text underline>{"enter"}</Text> to submit.
      </Text>
      <TextInput
        focus={isFocused}
        value={""}
        onChange={() => {}}
        onSubmit={props.onSubmit}
        showCursor={false}
      />
    </Box>
  );
};

const GenerateBatch = (props: {
  connectionId: ID;
  template: AppBatchInput_fragment$key;
}) => {
  const [commit, isInFlight] =
    useMutation<AppGenerateBatchMutation>(AppGenerateBatchNode);
  const [errors, setErrors] = useState<PayloadError[] | null>(null);

  const { fields } = useFragment(AppBatchInputNode, props.template);
  const [editing, setEditing] = useState(false);
  const { focusNext } = useFocusManager();
  const ref = useRef<FieldInputSchema[]>([]);

  useInput((input, key) => {
    if (editing) {
      if (key.escape) {
        ref.current = [];
        setEditing(false);
      }
      return;
    }
    if (input === "G") {
      ref.current = [];
      setEditing(true);
    }
  });

  if (editing) {
    return (
      <Box flexDirection="column">
        {fields.edges.map((e, i) => (
          <FieldInput
            key={e.node.id}
            field={e.node}
            onSubmit={value => {
              ref.current[i] = {
                field: e.node.id,
                value: value,
                valueType: e.node.valueType as any,
              };
              focusNext();
            }}
          />
        ))}
        <SubmitGeneratedBatch
          onSubmit={() => {
            commit({
              variables: {
                batchId: (nextBatchId++).toString(),
                batchTemplateId: batchTemplate.id,
                location: factory.id,
                fields: ref.current,
                connections: [props.connectionId],
              },
              onCompleted(_, errors) {
                ref.current = [];
                setEditing(false);
                setErrors(errors);
              },
            });
          }}
        />
      </Box>
    );
  }

  return (
    <Box flexDirection="column">
      {isInFlight ? (
        <Text color="yellow">A new Batch is brewing... </Text>
      ) : (
        <Text color="gray">
          Press <Text underline>G</Text> to generate a new Batch.
        </Text>
      )}
      {errors?.length ? (
        <Box flexDirection="column" margin={2}>
          {errors.map((e, i) => (
            <Text key={`${i}-${e.message}`} color="red">
              {e.message}
            </Text>
          ))}
        </Box>
      ) : null}
    </Box>
  );
};

const Simulation = (props: {
  batches: AppSimulation_fragment$key;
  batchTemplate: AppBatchInput_fragment$key;
}) => {
  const data = useFragment(AppSimulationNode, props.batches);
  const [mode, setMode] = useState<"g" | "s">("g");

  useInput((input, key) => {
    // TODO: better input event handling.
    if (input === "s") {
      setMode("s");
    } else if (!key.upArrow && !key.downArrow) {
      setMode("g");
    }
  });

  return (
    <Box flexDirection="column" gap={1}>
      <GenerateBatch connectionId={data.__id} template={props.batchTemplate} />
      {match(mode)
        .with("g", () => (
          <Box
            flexDirection="column"
            marginLeft={2}
          >
            {data.edges.map(e => (
              <Batch key={e.node.id} queryRef={e.node} />
            ))}
          </Box>
        ))
        .with("s", () => (
          <SelectInput
            items={data.edges.map(e => ({
              key: e.node.id,
              label: e.node.id, // doesn't matter
              value: e.node,
            }))}
            // biome-ignore lint/suspicious/noExplicitAny:
            itemComponent={item => <Batch queryRef={(item as any).value} />}
          />
        ))
        .exhaustive()}
    </Box>
  );
};
*/

const Fallback = (props: FallbackProps) => {
  console.error(props.error);
  return <Text color="red">{props.error?.message ?? "Unknown error"}</Text>;
};

const Main = () => {
  return (
    <ErrorBoundary FallbackComponent={Fallback}>
      <Suspense fallback={<Loading message="Initializing environment..." />}>
        <RelayEnvironmentProvider environment={environment}>
          <ModeControl>
            <App />
          </ModeControl>
        </RelayEnvironmentProvider>
      </Suspense>
    </ErrorBoundary>
  );
};

render(<Main />);
