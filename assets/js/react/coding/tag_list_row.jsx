import React from "react"
import PropTypes from "prop-types"
import {Mutation} from "react-apollo"
import {codingPageQuery, updateTagMutation, deleteTagMutation} from "../../apollo/queries"

class TagListRow extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isHovering: false,
      isEditing: false,
      editedText: props.tag.text
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

  renderDeleteTagMutationWrapper() {
    return <Mutation
      mutation={deleteTagMutation}
      update={this.updateCacheOnDeleteTag.bind(this)}
    >
      {(runDeleteTagMutation, {called, loading, data}) => {
        // TODO: Display loading status somehow, maybe a semi-transparent overlay
        return this.renderUpdateTagMutationWrapper({runDeleteTagMutation})
      }}
    </Mutation>
  }

  renderUpdateTagMutationWrapper({runDeleteTagMutation}) {
    // Apollo should know how to update the cache; we don't need a custom updater
    return <Mutation mutation={updateTagMutation}>
      {(runUpdateTagMutation, {called, loading, data}) => {
        // TODO: Display loading status somehow, maybe a semi-transparent overlay
        return this.renderTagContainer({runDeleteTagMutation, runUpdateTagMutation})
      }}
    </Mutation>
  }

  renderTagContainer({runDeleteTagMutation, runUpdateTagMutation}) {
    return <div
      className="__tag"
      onMouseOver={() => this.setState({isHovering: true})}
      onMouseLeave={() => this.setState({isHovering: false})}
    >
      <div className="__tagColor" style={{backgroundColor: this.props.tag.color}}></div>
      {this.renderContent({runDeleteTagMutation, runUpdateTagMutation})}
    </div>
  }

  renderContent({runDeleteTagMutation, runUpdateTagMutation}) {
    if (this.state.isEditing) {
      return this.renderEditing({runUpdateTagMutation})
    } else if (this.state.isHovering) {
      return this.renderHovering({runDeleteTagMutation})
    } else {
      return this.renderInert()
    }
  }

  renderEditing({runUpdateTagMutation}) {
    return <div>
      <input type="text"
        id={"tag-editor-"+this.props.tag.id}
        className="__tagTextEditField"
        value={this.state.editedText}
        onChange={(e) => this.setState({editedText: e.target.value})}
        onKeyUp={(e) => {
          if (e.key === 'Enter') this.submitTagRename({runUpdateTagMutation})
        }}
      />
      <div className="__tagDetails">
        <a href="#" className="text-success"
          onClick={(e) => {
            e.preventDefault()
            this.submitTagRename({runUpdateTagMutation})
          }}
        ><i className="icon">check_circle</i></a>
        &nbsp;
        <a href="#" className="text-danger"
          onClick={(e) => {
            e.preventDefault()
            this.setState({isEditing: false})
          }}
        ><i className="icon">cancel</i></a>
      </div>
    </div>
  }

  renderHovering({runDeleteTagMutation}) {
    return <div>
      <div className="__text">{this.props.tag.text}</div>
      <div className="__tagDetails">
        <a href="#" className=""
          onClick={(e) => {
            e.preventDefault()
            TODO()
          }}
        >apply</a>
        &nbsp; &nbsp;
        <a href="#" className="text-warning"
          onClick={(e) => {
            e.preventDefault()
            this.setState({isEditing: true})
          }}
        ><i className="icon">edit</i></a>
        &nbsp;
        <a href="#" className="text-danger"
          onClick={(e) => {
            e.preventDefault()
            runDeleteTagMutation({variables: {id: this.props.tag.id}})
          }}
        ><i className="icon">delete</i></a>
      </div>
    </div>
  }

  renderInert() {
    return <div>
      <div className="__text">{this.props.tag.text}</div>
      <div className="__tagDetails">{this.props.tag.count_taggings}</div>
    </div>
  }

  submitTagRename({runUpdateTagMutation}) {
    runUpdateTagMutation({variables: {id: this.props.tag.id, text: this.state.editedText}})
    this.setState({isEditing: false})
  }

  // Tell Apollo how to update the cache to reflect this mutation
  // See https://www.apollographql.com/docs/react/essentials/mutations#update
  updateCacheOnDeleteTag(cache, resp) {
    let codingId = this.props.codingId
    let deletedTagId = this.props.tag.id

    // Load the relevant data from the cache
    let cachedData = cache.readQuery({query: codingPageQuery, variables: {id: codingId}})

    // Update the cached response to reflect the change we just made
    cachedData.coding.video.prompt.project.tags =
     cachedData.coding.video.prompt.project.tags
      .filter((tag) => tag.id != deletedTagId)

    cachedData.coding.taggings =
      cachedData.coding.taggings
        .filter((tagging) => tagging.tag.id != deletedTagId)

    cachedData.touchCache = Math.random() // help Apollo realize that a rerender is needed

    // Write the transformed data back to the cache
    cache.writeQuery({query: codingPageQuery, variables: {id: codingId}, data: cachedData})
  }
}

TagListRow.propTypes = {
  tag: PropTypes.object.isRequired,
  codingId: PropTypes.number.isRequired // needed when updating the cache
}

export default TagListRow
