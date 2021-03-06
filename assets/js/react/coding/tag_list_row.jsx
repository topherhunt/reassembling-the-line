import React from "react"
import PropTypes from "prop-types"
import {Mutation} from "react-apollo"
import {
  codingPageQuery,
  updateTagMutation,
  deleteTagMutation,
  createTaggingMutation
} from "../../apollo/queries"

class TagListRow extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isHovering: false,
      isEditing: false,
      editedName: props.tag.name
    }
  }

  componentDidUpdate(prevProps, prevState) {
    // If we just started editing, select the element
    if (this.state.isEditing && !prevState.isEditing) {
      let input = document.querySelector("#tag-editor-"+this.props.tag.id)
      input.select()
    }
  }

  render() {
    return this.renderDeleteTagMutationWrapper()
  }

  // TODO: Move this wrapper down closer to the delete link
  renderDeleteTagMutationWrapper() {
    return <Mutation
      mutation={deleteTagMutation}
      update={this.updateCacheOnDeleteTag.bind(this)}
    >
      {(deleteTag, {called, loading, data}) => {
        // TODO: Display loading status somehow, maybe a semi-transparent overlay
        let mutationFuncs = {deleteTag}
        return this.renderUpdateTagMutationWrapper(mutationFuncs)
      }}
    </Mutation>
  }

  renderUpdateTagMutationWrapper(mutationFuncs) {
    // Apollo should know how to update the cache; we don't need a custom updater
    return <Mutation mutation={updateTagMutation}>
      {(updateTag, {called, loading, data}) => {
        // TODO: Display loading status somehow, maybe a semi-transparent overlay
        mutationFuncs.updateTag = updateTag
        return this.renderCreateTaggingMutationWrapper(mutationFuncs)
        // return this.renderTagContainer(mutationFuncs)
      }}
    </Mutation>
  }

  renderCreateTaggingMutationWrapper(mutationFuncs) {
    return <Mutation
      mutation={createTaggingMutation}
      update={this.updateCacheOnCreateTagging.bind(this)}
    >
      {(createTagging, {called, loading, data}) => {
        mutationFuncs.createTagging = createTagging
        return this.renderTagContainer(mutationFuncs)
      }}
    </Mutation>
  }

  renderTagContainer(mutationFuncs) {
    return <div
      className={`__tag test-tag-row-${this.props.tag.id}`}
      onMouseOver={() => this.setState({isHovering: true})}
      onMouseLeave={() => this.setState({isHovering: false})}
    >
      <div className="__tagColor" style={{backgroundColor: this.props.tag.color}}></div>
      {this.renderContent(mutationFuncs)}
    </div>
  }

  renderContent(mutationFuncs) {
    if (this.state.isEditing) {
      return this.renderEditing(mutationFuncs)
    } else if (this.state.isHovering) {
      return this.renderHovering(mutationFuncs)
    } else {
      return this.renderInert()
    }
  }

  renderInert() {
    return <div>
      <div className="__name">{this.props.tag.name}</div>
      <div className="__tagDetails">{this.props.tag.count_taggings}</div>
    </div>
  }

  renderHovering(mutationFuncs) {
    return <div>
      <div className="__name">{this.props.tag.name}</div>
      <div className="__tagDetails">
        <a href="#"
          className="test-tag-apply-link"
          onClick={(e) => { e.preventDefault(); this.applyTag(mutationFuncs) }}
        >{gettext("apply")}</a>
        &nbsp; &nbsp;
        <a href="#"
          className="text-warning test-tag-edit-link"
          onClick={(e) => {
            e.preventDefault()
            this.setState({isEditing: true})
          }}
        ><i className="icon">edit</i></a>
        &nbsp;
        <a href="#"
          className="text-danger test-tag-delete-link"
          onClick={(e) => {
            e.preventDefault()
            if (!confirm(gettext("Really delete this tag?"))) return
            mutationFuncs.deleteTag({variables: {id: this.props.tag.id}})
          }}
        ><i className="icon">delete</i></a>
      </div>
    </div>
  }

  renderEditing(mutationFuncs) {
    return <div>
      <input type="text"
        id={"tag-editor-"+this.props.tag.id}
        className="__tagTextEditField test-tag-edit-field"
        value={this.state.editedName}
        onChange={(e) => this.setState({editedName: e.target.value})}
        onKeyUp={(e) => { if (e.key === 'Enter') this.submitTagRename(e, mutationFuncs) }}
      />
      <div className="__tagDetails">
        <a href="#" className="text-success test-tag-edit-submit"
          onClick={(e) => this.submitTagRename(e, mutationFuncs)}
        ><i className="icon">check_circle</i></a>
        &nbsp;
        <a href="#" className="text-danger" onClick={this.cancelTagRename}>
          <i className="icon">cancel</i>
        </a>
      </div>
    </div>
  }

  cancelTagRename(e) {
    e.preventDefault()
    this.setState({isEditing: false})
  }

  submitTagRename(e, mutationFuncs) {
    e.preventDefault()
    let tagId = this.props.tag.id
    let name = this.state.editedName
    mutationFuncs.updateTag({variables: {id: tagId, name: name}})
    this.setState({isEditing: false})
  }

  applyTag(mutationFuncs) {
    if (!this.props.timelineSelection) {
      alert(gettext("Make a selection in the timeline first."))
      return
    }

    let params = {
      coding_id: this.props.codingId,
      tag_id: this.props.tag.id,
      starts_at: this.props.timelineSelection.left,
      ends_at: this.props.timelineSelection.right
    }
    mutationFuncs.createTagging({variables: params})
  }

  // Tell Apollo how to update the cache to reflect this mutation
  // See https://www.apollographql.com/docs/react/essentials/mutations#update
  updateCacheOnDeleteTag(cache, resp) {
    let codingId = this.props.codingId
    let deletedTagId = resp.data.delete_tag.id

    // Load the relevant data from the cache
    let cachedData = cache.readQuery({query: codingPageQuery, variables: {id: codingId}})

    // Update the cached response to reflect the change we just made
    // Remove this tag from the tags list
    cachedData.coding.video.prompt.project.tags =
     cachedData.coding.video.prompt.project.tags
      .filter((tag) => tag.id != deletedTagId)
    // Remove all taggings for this tag from the video
    cachedData.coding.taggings =
      cachedData.coding.taggings
        .filter((tagging) => tagging.tag.id != deletedTagId)
    // Make Apollo realize that a rerender is needed
    cachedData.touchCache = Math.random()

    // Write the transformed data back to the cache
    cache.writeQuery({query: codingPageQuery, variables: {id: codingId}, data: cachedData})
  }

  // Tell Apollo how to update the cache to reflect this mutation
  // See https://www.apollographql.com/docs/react/essentials/mutations#update
  updateCacheOnCreateTagging(cache, resp) {
    let codingId = this.props.codingId
    let newTagging = resp.data.create_tagging

    // Load the relevant data from the cache
    let cachedData = cache.readQuery({query: codingPageQuery, variables: {id: codingId}})

    // Update the cached response to reflect the change we just made
    // Append the new tagging to this video's taggings list
    cachedData.coding.taggings = cachedData.coding.taggings.concat(newTagging)
    // Update this tag's taggings count
    cachedData.coding.video.prompt.project.tags =
      cachedData.coding.video.prompt.project.tags.map((tag) => {
        if (tag.id == newTagging.tag.id) tag.count_taggings += 1
        return tag
      })
    // Make Apollo realize that a rerender is needed
    cachedData.touchCache = Math.random()

    // Write the transformed data back to the cache
    cache.writeQuery({query: codingPageQuery, variables: {id: codingId}, data: cachedData})
  }
}

TagListRow.propTypes = {
  codingId: PropTypes.number.isRequired, // needed when updating the cache
  tag: PropTypes.object.isRequired,
  timelineSelection: PropTypes.object
}

export default TagListRow
