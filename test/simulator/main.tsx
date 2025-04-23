import type { ID } from "grats";
import { Box, Text, render, useFocus, useFocusManager, useInput } from "ink";
import TextInput from "ink-text-input";
import { Suspense, useRef, useState } from "react";
import {
  RelayEnvironmentProvider,
  useFragment,
  useLazyLoadQuery,
  useMutation,
} from "react-relay";
import {
  Environment,
  type FetchFunction,
  Network,
  Observable,
  type PayloadError,
  RecordSource,
  Store,
} from "relay-runtime";
import { Field, FieldInput } from "./Field";
import AppBatchInputNode, {
  type AppBatchInput_fragment$key,
} from "./__generated__/AppBatchInput_fragment.graphql";
import AppBatchFragment, {
  type AppBatch_fragment$key,
} from "./__generated__/AppBatch_fragment.graphql";
import AppGenerateBatchNode, {
  type AppGenerateBatchMutation,
} from "./__generated__/AppGenerateBatchMutation.graphql";
import AppRootNode, { type AppQuery } from "./__generated__/AppQuery.graphql";
import AppSimulationNode, {
  type AppSimulation_fragment$key,
} from "./__generated__/AppSimulation_fragment.graphql";
import { setup } from "./prelude";
import type { FieldInput as FieldInputSchema } from "@/schema/system/component";

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

const {
  customer,
  worker,
  factory,
  batchTemplate,
  mixingLine,
  fillLine,
  assemblyLine,
  cartoningLine,
  packagingLine,
} = await setup();

const fetchFn: FetchFunction = (params, variables) => {
  const res = fetch("http://localhost:4000", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      // TODO: OAuth.
      "X-Tendrel-User": worker,
    },
    body: JSON.stringify({
      query: params.text,
      variables,
    }),
  });
  return Observable.from(res.then(data => data.json()));
};

function createEnvironment() {
  const network = Network.create(fetchFn);
  const store = new Store(new RecordSource());
  return new Environment({ store, network });
}

const environment = createEnvironment();

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
        Hit <Text bold>{"<enter>"}</Text> to submit.
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

  useInput(input => {
    if (editing) return;
    if (input === "g") {
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
                // biome-ignore lint/suspicious/noExplicitAny: FIXME
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
        <Text color="yellow">A new Batch is brewing... please hold.</Text>
      ) : (
        <Text color="greenBright">
          Press <Text bold>g</Text> to generate a new Batch.
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

  return (
    <Box flexDirection="column">
      <GenerateBatch connectionId={data.__id} template={props.batchTemplate} />
      <Box flexDirection="column" gap={1} margin={1}>
        {data.edges.map(e => (
          <Batch key={e.node.id} queryRef={e.node} />
        ))}
      </Box>
    </Box>
  );
};

const Main = () => {
  const data = useLazyLoadQuery<AppQuery>(AppRootNode, {
    customerId: customer.id,
    batchTemplateId: batchTemplate.id,
  });

  return (
    <Box flexDirection="column">
      <Text color="yellowBright">
        {data.customer.me?.displayName} @ {data.customer.name?.value}
      </Text>
      <Simulation batches={data.batches} batchTemplate={data.batchTemplate} />
    </Box>
  );
};

const App = () => {
  return (
    <Suspense>
      <RelayEnvironmentProvider environment={environment}>
        <Main />
      </RelayEnvironmentProvider>
    </Suspense>
  );
};

render(<App />);
