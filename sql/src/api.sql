CREATE SCHEMA api;
COMMENT ON SCHEMA api IS '
# Tendrel REST API

## Authentication and authorization

Most of the public api requires two tokens to be present in every request:

1. An application token, in JWT format via the X-Tendrel-App header.
2. An authorization token, in JWT format via the Authorization header.

The application token is essentially an OAuth 2.0 client secret, where the
"application" (e.g. a mobile app) is the OAuth 2.0 client. Application tokens
are required for all api calls.

The authorization token is a Tendrel issued JWT that uniquely identifies the
user making the request. Most api calls require a valid authorization token.
A client may exchange an IDP-issued security token for a Tendrel-issued token by
calling the /token api, which is implemented as an [OAuth 2.0 Token
Exchange](https://datatracker.ietf.org/doc/html/rfc8693).

### The "anonymous" role

The anonymous (`anon`) role can only be used to perform a select few operations
that do not require an authorization token. In particular, the `anon` role can
be used to signup for a Tendrel account as well as in various "introspection"
related operations, e.g. introspecting the OpenAPI schema. This role is the
default role for HTTP requests which do not include an authorization token.

## Localization

Tendrel is not a content management system. It does, however, provide mechanisms
that allow for content to be dynamically localized according to user preference.

Dynamic localization can be customized using various HTTP headers:

- `Accept-Language: en` specifies the locale.
- `Prefer: timezone=America/Denver` specifies the timezone.
';

