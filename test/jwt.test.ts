import * as jose from "jose";

// This is an example encoded JWT (issued by Clerk)
const jwt =
  "eyJhbGciOiJSUzI1NiIsImNhdCI6ImNsX0I3ZDRQRDExMUFBQSIsImtpZCI6Imluc18yaTNvSWowV09oVHNPeWxMTjdzblNocDNKeFYiLCJ0eXAiOiJKV1QifQ.eyJhenAiOiJodHRwczovL2JldGEuY29uc29sZS50ZW5kcmVsLmlvIiwiZXhwIjoxNzM4NzIxNTEyLCJmdmEiOlsxNjkyLC0xXSwiaWF0IjoxNzM4NzIxNDUyLCJpc3MiOiJodHRwczovL2NsZXJrLnRlbmRyZWwuaW8iLCJuYmYiOjE3Mzg3MjE0NDIsInNpZCI6InNlc3NfMnNZNXRTN0ZkWkN2Rnl0VlVRYmpNYzQzb3JXIiwic3ViIjoidXNlcl8yaUFHY3RHSEo2aTh6WDExUnBGUkQ2dnBIRFcifQ.Ldn6wZfB05uKXM9Q7sP8QARiAillLGrmwsjtpWzyJuqDmjjhhbCv89VWd-e0SOBh27lyO94hVnqbE7YBCFOTZ5R-aiNEzefoIltTg8ctRysIQyOluOMI56DpdwZcFlxp1JE-0tckyMTODi6ecZJAngXUtA5ZxOz-F41syc9_tBs8KKIlvGnZQZ_UwlKcwmYAO7PSOrs8rYEjY5Evu4D6dqOgQPUTQmsaIZOx5Mg9M-fkOBaNQRjMYQqWstCpiHgvIRsjIvkLL1wvIroITgU8sF1Sfr0B-jz1Wcfa1obc1GOqKk85GtoVlBgwSwF_0wFVaamVe3Ip5bOibSQ8vBIwRg";

// We can decode the token without any additional information.
const decoded = jose.decodeJwt(jwt);
console.log("JWT decoded", decoded);

// This is where self-service comes into play. We need to know the user's IDP's
// JWKS URI. For Clerk, it is the following:
const jwksUri = new URL(`${decoded.iss}/.well-known/jwks.json`);
console.log("jwks uri", jwksUri.toString());
const jwks = jose.createRemoteJWKSet(jwksUri);

// Finally we can verify the JWT. Note that JWT verification just ensures that
// the JWT has not been tampered with. No additional information is obtained
// through verification.
const verified = await jose.jwtVerify(jwt, jwks, {
  // In practice these will not be necessary. Alas, the above JWT is expired and
  // thus verification will fail unless we essentially disregard the "nbf",
  // "exp" and "iat" claims.
  clockTolerance: "1 year",
  maxTokenAge: "1 year",
});
console.log("verified", verified);
