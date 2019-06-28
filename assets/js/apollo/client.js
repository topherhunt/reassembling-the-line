// Inits the Apollo client, telling it where the gql api is
// Apollo docs: https://www.apollographql.com/docs/react/essentials/queries

import ApolloClient from "apollo-boost"
import { gql } from "apollo-boost"

const client = new ApolloClient({uri: "/graphql/"})

// Run a test query to confirm that we can get data from the api
// client
//   .query({query: gql`{users {id email lastSignedInAt name}}`})
//   .then(result => console.log("Result! ", result))

export default client
