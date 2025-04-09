import type { GraphQLScalarType } from "graphql";
import {
  // GraphQLDuration,
  GraphQLLocale,
  GraphQLTimeZone,
} from "graphql-scalars";
import { CronExpression } from "../resolvers/CronExpression";
import { Duration } from "../resolvers/Duration";

export const resolvers: Record<string, GraphQLScalarType> = {
  CronExpression: CronExpression,
  // Duration: GraphQLDuration,
  Duration: Duration,
  Locale: GraphQLLocale,
  TimeZone: GraphQLTimeZone,
};

export {
  CronExpression,
  CronExpression as CronExpressionResolver,
  Duration,
  Duration as DurationResolver,
  // GraphQLDuration as Duration,
  // GraphQLDuration as DurationResolver,
  GraphQLLocale as Locale,
  GraphQLLocale as LocaleResolver,
  GraphQLTimeZone as TimeZone,
  GraphQLTimeZone as TimeZoneResolver,
};

export const config = {
  CronExpression: CronExpression.extensions.codegenScalarType,
  // Duration: GraphQLDuration.extensions.codegenScalarType,
  Duration: Duration.extensions.codegenScalarType,
  Locale: GraphQLLocale.extensions.codegenScalarType,
  TimeZone: GraphQLTimeZone.extensions.codegenScalarType,
};
