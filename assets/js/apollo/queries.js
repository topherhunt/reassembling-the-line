import {gql} from "apollo-boost"

const codingPageQuery = gql`
  query Coding($id: ID!) {
    coding(id: $id) {
      id
      completed_at
      video {
        id
        speaker_name
        permission_show_name
        thumbnail_url
        recording_url
        prompt {
          id
          sanitized_text
          project {
            id
            name
            tags {
              id
              text
              countTaggings
            }
          }
        }
      }
      coder {
        id
        full_name
      }
    }
  }
`

export {
  codingPageQuery
}
