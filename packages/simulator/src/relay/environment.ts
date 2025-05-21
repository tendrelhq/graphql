import { base_url } from "@/config";
import { assertNonNull, map } from "@/util";
import {
  Environment,
  type FetchFunction,
  Network,
  RecordSource,
  RelayFeatureFlags,
  type RelayFieldLogger,
} from "relay-runtime";
import RelayModernStore from "relay-runtime/lib/store/RelayModernStore";

RelayFeatureFlags.ENABLE_RELAY_RESOLVERS = true;

// TODO: OAuth.
const X_TENDREL_USER = assertNonNull(
  process.env.X_TENDREL_USER,
  "Set the X_TENDREL_USER environment variable to the workeridentityid of your choosing. This in lieu of a legitimate commandline authentication flow.",
);

// TODO: We can do better than this with simulated Time.
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

const fetchFn: FetchFunction = async (request, variables) => {
  const res = await fetch(new URL("/api/v1/query", base_url), {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Tendrel-User": X_TENDREL_USER,
    },
    body: JSON.stringify({
      query: request.text,
      variables,
    }),
  });
  const body = await res.json();
  if (!res.ok) {
    console.debug(JSON.stringify(body, null, 2));
  }
  return body;
};

const fieldLogger: RelayFieldLogger = event => {
  // console.debug(`${event.kind}: ${event.owner}.${event.fieldPath}`);
  switch (event.kind) {
    case "relay_resolver.error":
      console.debug(event.error);
      break;
  }
};

export function createEnvironment() {
  const network = Network.create(fetchFn);
  const store = new RelayModernStore(new RecordSource());
  return new Environment({
    store,
    network,
    log(event) {
      switch (event.name) {
        case "network.error":
          console.debug(`execute.error: ${event.error}`);
          break;
      }
    },
    relayFieldLogger: fieldLogger,
  });
}
