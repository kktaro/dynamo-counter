import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

const schema = a.schema({
  Count: a
    .model({
      value: a.integer(),
    })
    .authorization((allow) => [allow.publicApiKey()]),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'apiKey',
    apiKeyAuthorizationMode: { expiresInDays: 30 }
  },
});
