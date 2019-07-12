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
    let isSelected = this.props.isSelected
    let drag = this.props.currentDrag

    let tagging = this.props.tagging
    let startsAt = tagging.starts_at
    let endsAt = tagging.ends_at
    let statusClass = isSelected ? "--selected" : ""

    // If user is currently dragging this tagging boundary, preview its tentative state
    if (isSelected && drag && drag.intentional && drag.type == "resizeTagging") {
      statusClass += " --dragging"
      if (drag.side == "left") {
        startsAt = drag.to
      } else {
        endsAt = drag.to
      }
    }

    let cssTop = ""+(this.props.index * 15 + 35)+"px"
    let cssLeft = ""+(startsAt * this.props.zoom)+"px"
    let cssWidth = ""+((endsAt - startsAt) * this.props.zoom)+"px"

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
    >
      <div className="__taggingContent">
        <div className="__taggingLabel">{tagging.tag.text}</div>
        {this.props.isSelected ? this.renderHandles() : ""}
        {this.props.isSelected ? this.renderButtons() : ""}
      </div>
    </div>
  }

  renderHandles() {
    return <div>
      <div className="__taggingDragHandle"
        style={{left: "-5px"}}
        onMouseDown={(e) => { this.props.startDrag(e, "left") }}
      >
        <div className="__taggingDragHandleKnob"></div>
      </div>
      <div className="__taggingDragHandle"
        style={{right: "-5px"}}
        onMouseDown={(e) => { this.props.startDrag(e, "right") }}
      >
        <div className="__taggingDragHandleKnob"></div>
      </div>
    </div>
  }

  renderButtons() {
    return <div className="__taggingButtons">
      {this.renderPreviewButton()}
      {this.renderDeleteButton()}
    </div>
  }

  renderPreviewButton() {
    return <a href="#"
      onClick={(e) => {
        e.preventDefault()
        this.props.previewThis()
      }}
    >
      <i className="icon">play_arrow</i>
    </a>
  }

  renderDeleteButton() {
    return <Mutation
      mutation={deleteTaggingMutation}
      update={this.updateCacheOnDeleteTagging.bind(this)}
    >
      {(deleteTagging, {called, loading, data}) => {
        return <a href="#" className="text-danger"
          onClick={(e) => {
            e.preventDefault()
            if (!confirm("Really delete this tagging?")) return
            deleteTagging({variables: {id: this.props.tagging.id}})
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
  isSelected: PropTypes.bool.isRequired,
  currentDrag: PropTypes.object,
  selectThis: PropTypes.func.isRequired,
  previewThis: PropTypes.func.isRequired,
  startDrag: PropTypes.func.isRequired
}

export default TimelineTagging