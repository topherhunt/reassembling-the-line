import React from "react"
import PropTypes from "prop-types"
import {Mutation} from "react-apollo"
import {codingPageQuery, createTagMutation} from "../../apollo/queries"
import TagListRow from "./tag_list_row.jsx"

class TagManager extends React.Component {
  constructor(props) {
    super(props)
    this.state = {newTagName: ""}
  }

  componentDidUpdate(prevProps, prevState) {
    // If we just added a tag, focus back on the add tag field again
    if (this.props.tags.length > prevProps.tags.length) {
      let input = document.querySelector("#new-tag-name")
      if (!input) return
      input.focus()
      input.scrollIntoViewIfNeeded()
    }
  }

  render() {
    return <div className="b-codingPageTagManager">
      <div>
        <span className="h4">Tags</span> &nbsp;
        <a href="TODO">How does this work?</a>
      </div>

      <div className="__list">
        {this.props.tags.map((tag) => {
          return <TagListRow
            key={tag.id}
            codingId={this.props.codingId}
            tag={tag}
            timelineSelection={this.props.timelineSelection}
          />
        })}

        {this.renderAddTagForm()}
      </div>
    </div>
  }

  renderAddTagForm() {
    return <Mutation
      mutation={createTagMutation}
      update={this.updateCacheOnCreateTag.bind(this)}
    >
      {(runCreateTagMutation, {called, loading, data}) => {
        if (loading)
          return <div>Loading...</div>

        return <div className="__tag">
          <input type="text" id="new-tag-name"
            className="__newTagNameField test-add-tag-field"
            placeholder="Add a new tag"
            value={this.state.newTagName}
            onChange={(e) => this.setState({newTagName: e.target.value})}
            onKeyUp={(e) => {
              if (e.key === 'Enter') this.submitNewTag(runCreateTagMutation)
            }}
          />
          {this.renderAddTagSubmitButton(runCreateTagMutation)}
        </div>
      }}
    </Mutation>
  }

  renderAddTagSubmitButton(runCreateTagMutation) {
    if (!this.state.newTagName)
      return ""

    return <div className="__tagDetails">
      <a href="#" className="text-success test-add-tag-submit"
        onClick={(e) => {
          e.preventDefault()
          this.submitNewTag(runCreateTagMutation)
        }}
      ><i className="icon">check_circle</i></a>
    </div>
  }

  submitNewTag(runCreateTagMutation) {
    let projectId = this.props.projectId
    let name = this.state.newTagName
    runCreateTagMutation({variables: {projectId: projectId, name: name}})
    this.setState({newTagName: ""})
  }

  // Tell Apollo how to update the cache to reflect this mutation
  // See https://www.apollographql.com/docs/react/essentials/mutations#update
  updateCacheOnCreateTag(cache, resp) {
    let codingId = this.props.codingId
    let newTagData = resp.data.create_tag

    // Load the relevant data from the cache
    let cachedData = cache.readQuery({
      query: codingPageQuery,
      variables: {id: codingId}
    })

    // Update the cache with our newly added tag, then re-sort the list
    cachedData.coding.video.prompt.project.tags =
      cachedData.coding.video.prompt.project.tags
        .concat(newTagData)
        .sort((t1, t2) => t1.name < t2.name ? -1 : 1)

    cachedData.touchCache = Math.random() // help Apollo realize that a rerender is needed

    // Write the transformed data back to the cache
    cache.writeQuery({query: codingPageQuery, variables: {id: codingId}, data: cachedData})
  }
}

TagManager.propTypes = {
  // TODO: Do we really need to pass around both codingId and projectId?
  codingId: PropTypes.number.isRequired,
  projectId: PropTypes.number.isRequired,
  tags: PropTypes.array.isRequired,
  timelineSelection: PropTypes.object
}

export default TagManager
