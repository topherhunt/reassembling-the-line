import React from "react"
import PropTypes from "prop-types"
import {Mutation} from "react-apollo"
import {codingPageQuery, deleteTaggingMutation} from "../../apollo/queries"

class TimelineTagging extends React.Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  render() {
    let tagging = this.props.tagging
    let cssTop = ""+(this.props.index * 15 + 35)+"px"
    let cssLeft = ""+(tagging.starts_at * this.props.zoom)+"px"
    let cssWidth = ""+((tagging.ends_at - tagging.starts_at) * this.props.zoom)+"px"
    let statusClass = this.props.isSelected ? "--selected" : ""

    return <div className={"__tagging " + statusClass}
      style={{
        top: cssTop,
        left: cssLeft,
        width: cssWidth,
        backgroundColor: tagging.tag.color
      }}
      onClick={(e) => {
        e.stopPropagation()
        this.props.selectThis()
      }}
      onMouseDown={(e) => { e.stopPropagation() }}
      onMouseUp={(e) => { e.stopPropagation() }}
    >
      <div className="__taggingContent">
        <div className="__taggingLabel">{tagging.tag.text}</div>
        {this.props.isSelected ? this.renderTaggingHandles(tagging) : ""}
        {this.props.isSelected ? this.renderDeleteTaggingButton(tagging) : ""}
      </div>
    </div>
  }


  renderTaggingHandles(tagging) {
    return <div>
      <div className="__taggingDragHandle" style={{left: "-5px"}}>
        <div className="__taggingDragHandleKnob"></div>
      </div>
      <div className="__taggingDragHandle" style={{right: "-5px"}}>
        <div className="__taggingDragHandleKnob"></div>
      </div>
    </div>
  }

  renderDeleteTaggingButton(tagging) {
    return <Mutation
      mutation={deleteTaggingMutation}
      update={this.updateCacheOnDeleteTagging.bind(this)}
    >
      {(deleteTagging, {called, loading, data}) => {
        return <a href="#" className="__deleteTaggingButton text-danger"
          onClick={(e) => {
            e.preventDefault()
            if (!confirm("Really delete this tagging?")) return
            deleteTagging({variables: {id: tagging.id}})
          }}
        >
          <i className="icon">delete</i>
        </a>
      }}
    </Mutation>
  }

  updateCacheOnDeleteTagging(cache, resp) {
    let codingId = this.props.codingId
    let deletedTaggingId = resp.data.delete_tagging.id

    // Load the relevant data from the cache
    let cachedData = cache.readQuery({query: codingPageQuery, variables: {id: codingId}})

    // Update the cached response to reflect the change we just made
    // Remove this tagging from the list
    cachedData.coding.taggings =
      cachedData.coding.taggings
        .filter((tagging) => tagging.id != deletedTaggingId)
    // Decrement this tag's tagging count
    cachedData.coding.video.prompt.project.tags =
      cachedData.coding.video.prompt.project.tags.map((tag) => {
        if (tag.id == this.props.tagging.tag.id) tag.count_taggings -= 1
        return tag
      })
    // Make Apollo realize that a rerender is needed
    cachedData.touchCache = Math.random()

    // Write the transformed data back to the cache
    cache.writeQuery({query: codingPageQuery, variables: {id: codingId}, data: cachedData})
  }
}

TimelineTagging.propTypes = {
  codingId: PropTypes.number.isRequired,
  tagging: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
  selectThis: PropTypes.func.isRequired,
  isSelected: PropTypes.bool.isRequired
}

export default TimelineTagging
