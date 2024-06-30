import { DiagConsoleLogger, DiagLogLevel, diag } from "@opentelemetry/api";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http";
import { DataloaderInstrumentation } from "@opentelemetry/instrumentation-dataloader";
import { ExpressInstrumentation } from "@opentelemetry/instrumentation-express";
import { GraphQLInstrumentation } from "@opentelemetry/instrumentation-graphql";
import { HttpInstrumentation } from "@opentelemetry/instrumentation-http";
import { awsEcsDetector } from "@opentelemetry/resource-detector-aws";
import { Resource } from "@opentelemetry/resources";
import { NodeSDK, resources } from "@opentelemetry/sdk-node";
import {
  SEMRESATTRS_SERVICE_NAME,
  SEMRESATTRS_SERVICE_VERSION,
} from "@opentelemetry/semantic-conventions";
import pkg from "../package.json";

// For troubleshooting, set the log level to DiagLogLevel.DEBUG
diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.INFO);

console.log("Tracing intializing...");
const sdk = new NodeSDK({
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
    new GraphQLInstrumentation({
      mergeItems: true, // foo.*.bar
    }),
    new DataloaderInstrumentation(),
  ],
  resource: new Resource({
    [SEMRESATTRS_SERVICE_NAME]: `tendrel:graphql:${process.env.STAGE}`,
    [SEMRESATTRS_SERVICE_VERSION]: pkg.version,
  }),
  resourceDetectors: [
    resources.envDetector,
    resources.processDetector,
    awsEcsDetector,
  ],
  traceExporter: new OTLPTraceExporter(),
});

console.log("Tracing starting...");
sdk.start();

// gracefully shut down the SDK on process exit
process.on("SIGTERM", () =>
  sdk
    .shutdown()
    .then(() => console.log("Tracing terminated"))
    .catch(error => console.log("Error terminating tracing", error))
    .finally(() => process.exit(0)),
);
