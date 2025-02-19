import type { GraphQLScalarType } from "graphql";
import {
  // GraphQLDuration,
  GraphQLLocale,
  GraphQLTimeZone,
} from "graphql-scalars";
import { CronExpression } from "../resolvers/CronExpression";
import { Duration } from "../resolvers/Duration";
import { Entity } from "../resolvers/Entity";

export const resolvers: Record<string, GraphQLScalarType> = {
  CronExpression: CronExpression,
  // Duration: GraphQLDuration,
  Duration: Duration,
  Entity: Entity,
  Locale: GraphQLLocale,
  TimeZone: GraphQLTimeZone,
};

export {
  CronExpression,
  CronExpression as CronExpressionResolver,
  Entity,
  Entity as EntityResolver,
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
  Entity: Entity.extensions.codegenScalarType,
  Locale: GraphQLLocale.extensions.codegenScalarType,
  TimeZone: GraphQLTimeZone.extensions.codegenScalarType,
};
