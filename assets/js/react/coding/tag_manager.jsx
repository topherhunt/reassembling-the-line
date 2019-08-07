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

  componentDidUpdate(prevProps, prevState) {
    // If we just added a tag, focus back on the add tag field again
    if (this.props.tags.length > prevProps.tags.length) {
      let input = document.querySelector("#new-tag-text")
      input.focus()
      input.scrollIntoViewIfNeeded()
    }
  }

  render() {
    return this.renderCreateTagMutationWrapper()
  }

  renderCreateTagMutationWrapper() {
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

  renderMainContent(mutations) {
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

        {this.renderAddTagForm(mutations)}
      </div>
    </div>
  }

  renderAddTagForm(mutations) {
    return <div className="__tag">
      <input type="text" id="new-tag-text" className="__newTagTextField test-add-tag-field"
        placeholder="Add a new tag"
        value={this.state.newTagText}
        onChange={(e) => this.setState({newTagText: e.target.value})}
        onKeyUp={(e) => {
          if (e.key === 'Enter') this.submitNewTag(mutations)
        }}
      />
      {this.renderAddTagSubmitButton(mutations)}
    </div>
  }

  renderAddTagSubmitButton(mutations) {
    if (!!this.state.newTagText) {
      return <div className="__tagDetails">
        <a href="#" className="text-success test-add-tag-submit"
          onClick={(e) => {
            e.preventDefault()
            this.submitNewTag(mutations)
          }}
        ><i className="icon">check_circle</i></a>
      </div>
    } else {
      return null
    }
  }

  submitNewTag({runCreateTagMutation}) {
    let projectId = this.props.projectId
    let text = this.state.newTagText
    // document.querySelector("#new-tag-text").value
    runCreateTagMutation({variables: {projectId: projectId, text: text}})
    this.setState({newTagText: ""})
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
        .sort((t1, t2) => t1.text < t2.text ? -1 : 1)

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
