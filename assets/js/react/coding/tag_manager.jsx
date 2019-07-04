import React from "react"
import PropTypes from "prop-types"
import {Mutation} from "react-apollo"
import {codingPageQuery, createTagMutation} from "../../apollo/queries"
import TagListRow from "./tag_list_row.jsx"

class TagManager extends React.Component {
  constructor(props) {
    super(props)
    this.state = {newTagText: ""}
  }

  render() {
    return this.wrapInCreateTagQuery()
  }

  wrapInCreateTagQuery() {
    return <Mutation
      mutation={createTagMutation}
      update={this.updateCacheOnCreateTag.bind(this)}
    >
      {(runCreateTagMutation, {called, loading, data}) => {
        // TODO: Would an array of children work here, instead of this intervening div?
        return <div>
          {loading ? <div>Loading...</div> : ""}
          {this.renderMainContent({runCreateTagMutation})}
        </div>
      }}
    </Mutation>
  }

  renderMainContent({runCreateTagMutation}) {
    return <div className="b-codingPageTagManager">
      <div>
        <span className="h4">Tags</span> &nbsp;
        <a href="TODO">How does this work?</a>
      </div>

      <div className="__list">
        {this.props.tags.map((tag) => {
          return <TagListRow key={tag.id} tag={tag} codingId={this.props.codingId} />
        })}

        <div className="__tag">
          <input type="text" id="new-tag-text" className="__newTagTextField"
            placeholder="Add a new tag"
            value={this.state.newTagText}
            onChange={(e) => this.setState({newTagText: e.target.value})}
          />
          {this.renderNewTagSubmitButtons({runCreateTagMutation})}
        </div>
      </div>
    </div>
  }

  renderNewTagSubmitButtons({runCreateTagMutation}) {
    if (!!this.state.newTagText) {
      return <div className="__tagDetails">
        <a href="#" className="text-success"
          onClick={(e) => {
            e.preventDefault()
            let projectId = this.props.projectId
            let text = this.state.newTagText
            // document.querySelector("#new-tag-text").value
            runCreateTagMutation({variables: {projectId: projectId, text: text}})
            this.setState({newTagText: ""})
          }}
        ><i className="icon">check_circle</i></a>
      </div>
    } else {
      return null
    }
  }

  // Tell Apollo how to update the cache to reflect this mutation
  // See https://www.apollographql.com/docs/react/essentials/mutations#update
  updateCacheOnCreateTag(cache, resp) {
    let codingId = parseInt(this.props.codingId) // needs to be an integer to match!
    let newTag = resp.data.create_tag // grab the newly-created tag data
    console.log("Updating the cache with the new tag: ", newTag)

    // Load the relevant data from the cache
    let cachedData = cache.readQuery({query: codingPageQuery, variables: {id: codingId}})

    // Update the cached response to reflect the change we just made
    cachedData.coding.video.prompt.project.tags =
      cachedData.coding.video.prompt.project.tags.concat(newTag)

    // Write the transformed data back to the cache
    console.log("The cachedData being written: ", cachedData)
    cache.writeQuery({query: codingPageQuery, variables: {id: codingId}, data: cachedData})
  }
}

TagManager.propTypes = {
  tags: PropTypes.array.isRequired,
  // TODO: Do we really need to pass around both codingId and projectId?
  codingId: PropTypes.number.isRequired,
  projectId: PropTypes.number.isRequired
}

export default TagManager
