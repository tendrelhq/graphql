import { Link } from "@/schema/platform/resolvers/Link";
import type { GraphQLScalarType } from "graphql";
import {
  GraphQLISO8601Duration,
  GraphQLLocale,
  GraphQLTimeZone,
} from "graphql-scalars";
import { CronExpression } from "../resolvers/CronExpression";
import { Entity } from "../resolvers/Entity";

export const resolvers: Record<string, GraphQLScalarType> = {
  CronExpression: CronExpression,
  Duration: GraphQLISO8601Duration,
  Entity: Entity,
  Link: Link,
  Locale: GraphQLLocale,
  TimeZone: GraphQLTimeZone,
};

export {
  CronExpression,
  CronExpression as CronExpressionResolver,
  Entity,
  Entity as EntityResolver,
  GraphQLISO8601Duration,
  GraphQLISO8601Duration as ISO8601DurationResolver,
  GraphQLLocale,
  GraphQLLocale as LocaleResolver,
  GraphQLTimeZone,
  GraphQLTimeZone as TimeZoneResolver,
  Link,
  Link as LinkResolver,
};

export const config = {
  CronExpression: CronExpression.extensions.codegenScalarType,
  Entity: Entity.extensions.codegenScalarType,
  GraphQLISO8601Duration: GraphQLISO8601Duration.extensions.codegenScalarType,
  GraphQLLocale: GraphQLLocale.extensions.codegenScalarType,
  GraphQLTimeZone: GraphQLTimeZone.extensions.codegenScalarType,
  Link: Link.extensions.codegenScalarType,
};
