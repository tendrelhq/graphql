import { Link } from "@/schema/platform/resolvers/Link";
import type { GraphQLScalarType } from "graphql";
import {
  GraphQLDuration,
  GraphQLLocale,
  GraphQLTimeZone,
} from "graphql-scalars";
import { CronExpression } from "../resolvers/CronExpression";
import { Entity } from "../resolvers/Entity";

export const resolvers: Record<string, GraphQLScalarType> = {
  CronExpression: CronExpression,
  Duration: GraphQLDuration,
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
  GraphQLDuration as Duration,
  GraphQLDuration as DurationResolver,
  GraphQLLocale as Locale,
  GraphQLLocale as LocaleResolver,
  GraphQLTimeZone as TimeZone,
  GraphQLTimeZone as TimeZoneResolver,
  Link,
  Link as LinkResolver,
};

export const config = {
  CronExpression: CronExpression.extensions.codegenScalarType,
  Duration: GraphQLDuration.extensions.codegenScalarType,
  Entity: Entity.extensions.codegenScalarType,
  Link: Link.extensions.codegenScalarType,
  Locale: GraphQLLocale.extensions.codegenScalarType,
  TimeZone: GraphQLTimeZone.extensions.codegenScalarType,
};
