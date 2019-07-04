import {gql} from "apollo-boost"

// TODO: Am I ok with duplicating tag data? (each tagging has its own copy of the assoc tag)
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
              color
              count_taggings
            }
          }
        }
      }
      coder {
        id
        full_name
      }
      taggings {
        id
        starts_at
        ends_at
        tag {
          id
          text
          color
          count_taggings
        }
      }
    }
  }
`

const createTagMutation = gql`
  mutation CreateTag($projectId: ID!, $text: String!) {
    create_tag(projectId: $projectId, text: $text) {
      id
      text
      color
      count_taggings
    }
  }
`

const updateTagMutation = gql`
  mutation UpdateTag($id: ID!, $text: String!, $color: String) {
    update_tag(id: $id, text: $text, color: $color) {
      id
      text
      color
      count_taggings
    }
  }
`

const deleteTagMutation = gql`
  mutation DeleteTag($id: ID!) {
    delete_tag(id: $id) {
      id
    }
  }
`

const createTaggingMutation = gql`
  mutation CreateTagging($codingId: ID!, $tagId: ID!, $startsAt: String!, $endsAt: String!) {
    create_tagging(codingId: $codingId, tagId: $tagId, startsAt: $startsAt, endsAt: $endsAt) {
      id
      starts_at
      ends_at
      tag {
        id
        text
        color
        count_taggings
      }
    }
  }
`

const updateTaggingMutation = gql`
  mutation UpdateTagging($id: ID!, $startsAt: String!, $endsAt: String!) {
    update_tagging(id: $id, startsAt: $startsAt, endsAt: $endsAt) {
      id
      starts_at
      ends_at
      tag {
        id
        text
        color
        count_taggings
      }
    }
  }
`

const deleteTaggingMutation = gql`
  mutation DeleteTagging($id: ID!) {
    delete_tagging(id: $id) {
      id
    }
  }
`

export {
  codingPageQuery,
  createTagMutation,
  updateTagMutation,
  deleteTagMutation,
  createTaggingMutation,
  updateTaggingMutation,
  deleteTaggingMutation
}
