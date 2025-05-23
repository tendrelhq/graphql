# IAM

## Api keys

v0 will introduce "api keys" to the system by implementing the OAuth 2.0 Client
Credentials Flow. This flow is relatively straightforward: the client exchanges
a `client_id` and `client_secret` for an `access_token`. This is best suited for
machine-to-machine communication, or integration into backend software
applications where the client is **trusted**.[^1]

To summarize, v0 will:

- implement the `"client_credentials"` `grant_type`
- provide apis for issuing and revoking[^2] client credentials
- require that all applications include client credentials in api requests, in
  addition to an (optional) identity access token[^3]
- permit limited access control through the `scope` and `res` claims, e.g. the
  `scope` could indicate Admin/Supervisor/Worker.

v1 will introduce a few new features, namely the Device Flow. The device flow
works like this:

1. the client makes a POST request to /auth/device with a single piece of
   information: it's `client_id`
2. the server responds with some json containing the verification url and
   user code
3. the client displays the code to the user and subsequently polls the /token
   endpoint with a grant type of `device_code`
4. the server response with an error of `authorization_pending` until the user
   successfully logs in, or the token expires.
5. upon completion of the login flow, the client will receive the usual JWT
   access token

The device flow allows a "public" client to join the system without requiring a
priori secrets or even an interactive environment.[^4]

[^1]: I wonder if passkeys have any role to play here?

[^2]:
    Expired keys remain in the system for a short period of time during which
    we can assist the user in ensuring all existing clients are updated.

[^3]:
    Client credentials will effectively impersonate the user that created the
    credentials in the first place vis-a-vis (legacy) modifiedby.

[^4]:
    The canonical example of this is the Apple TV: rather than inputting your
    password, the device gives you a code and a url (which is usually a qr code)
    and the user can authenticate however they please.
