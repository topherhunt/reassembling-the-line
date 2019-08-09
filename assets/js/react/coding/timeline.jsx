import React from "react"
import PropTypes from "prop-types"
import {Mutation} from "react-apollo"
import {updateTaggingMutation} from "../../apollo/queries"
import TimelineTagging from "./timeline_tagging.jsx"
import TimelineTickmarks from "./timeline_tickmarks.jsx"

const raise = (message) => { console.error(message); abort() }

// TODO: This component is too complex. Too many ui layers are interwoven here.
// Think through how to factor out some of the complexity.
// Note: I wonder if re-inlining the TimelineTagging component (or finding a different
// boundary with that subcomponent) might simplify things here.
class Timeline extends React.Component {
  constructor(props) {
    super(props)

    // All timeline positions are in terms of seconds (decimal).
    this.state = {
      zoom: 20, // px width per second
      selectedTaggingId: null,
      hoveringAt: null, // (seconds)
      currentDrag: null // If populated, an object with {from:, to:, intentional:, etc.}
    }
  }

  componentDidUpdate(prevProps, prevState) {
    // If the seek position has changed, ensure the seek cursor is visible.
    if (this.props.videoSeekPos != prevProps.videoSeekPos) {
      document.querySelector("#timelinePrimaryCursor").scrollIntoViewIfNeeded()
    }

    // If zoomed in, double the scroll amount to compensate.
    if (this.state.zoom > prevState.zoom) {
      let div = document.querySelector(".b-codingPageTimeline .__scrollContainer")
      // TODO: This "anchors" zoom to the left-hand side of the screen, but we can do
      // better: we can adjust the scroll so that tickmarks that were in the middle of
      // the view, stay in the middle of the view.
      div.scrollLeft = div.scrollLeft * 2
    }

    // If zoomed out, halve the scroll to compensate.
    if (this.state.zoom < prevState.zoom) {
      let div = document.querySelector(".b-codingPageTimeline .__scrollContainer")
      div.scrollLeft = div.scrollLeft / 2
    }
  }

  //
  // Rendering
  //

  render() {
    return this.renderResizeTaggingMutation()
  }

  renderResizeTaggingMutation() {
    // No manual updater needed, I think
    return <Mutation mutation={updateTaggingMutation}>
      {(updateTagging, {called, loading, data}) => {
        let mutations = {updateTagging}
        return this.renderMainContent({mutations})
      }}
    </Mutation>
  }

  renderMainContent({mutations}) {
    return <div className="b-codingPageTimeline">
      <div className="__scrollContainer">
        <div className="__timeline" style={{width: this.timelineWidth()}}
          onClick={() => this.setState({selectedTaggingId: null})}
          onMouseDown={this.mouseDownOnTimeline.bind(this)}
          onMouseUp={(e) => this.handleMouseUp(e, mutations)}
          onMouseMove={this.handleMouseMove.bind(this)}
          onMouseLeave={() => this.setState({hoveringAt: null})}
        >
          <TimelineTickmarks
            videoDuration={this.props.videoDuration}
            zoom={this.state.zoom}
          />
          {this.renderTaggings()}
          {this.renderSelection()}
          {this.renderPrimaryCursor()}
          {this.renderHoverCursor()}
        </div>
      </div>
      <div className="__zoomControls">
        <i className="icon" onClick={this.handleZoomInClicked.bind(this)}>zoom_in</i>
        <i className="icon" onClick={this.handleZoomOutClicked.bind(this)}>zoom_out</i>
      </div>
    </div>
  }

  renderTaggings() {
    let taggingIndex = 0
    return <div className="__taggingsContainer">
      {this.props.taggings.map((tagging) => {
        if (taggingIndex >= 11) taggingIndex = 0
        return <TimelineTagging key={tagging.id}
          index={taggingIndex++}
          codingId={this.props.codingId}
          tagging={tagging}
          zoom={this.state.zoom}
          isSelected={this.state.selectedTaggingId == tagging.id}
          currentDrag={this.state.currentDrag}
          startDrag={this.mouseDownOnTaggingHandle.bind(this)}
          onClick={() => this.setState({selectedTaggingId: tagging.id})}
          previewThis={(e) => {
            let start = tagging.starts_at
            let end = tagging.ends_at
            this.props.setVideoSeekPos(start, {play: true, pauseAt: end})
          }}
        />
      })}
    </div>
  }

  renderSelection() {
    if (!this.props.timelineSelection) return

    let sel = this.props.timelineSelection
    let cssLeft = ""+(sel.left * this.state.zoom)+"px"
    let cssWidth = ""+((sel.right - sel.left) * this.state.zoom + 1)+"px"
    let classes = "__selection test-timeline-selection-"+sel.left+"s-"+sel.right+"s"

    return <div className={classes} style={{left: cssLeft, width: cssWidth}}></div>
  }

  renderPrimaryCursor() {
    let left = ""+(this.props.videoSeekPos * this.state.zoom)+"px"
    return <div id="timelinePrimaryCursor" className="__cursorPrimary" style={{left: left}}></div>
  }

  renderHoverCursor() {
    if (!this.state.hoveringAt) return

    let left = ""+(this.state.hoveringAt * this.state.zoom)+"px"

    let sec = this.state.hoveringAt
    let m = Math.floor(sec / 60)
    let s = (sec % 60).toFixed(1) // keep 1 decimal place
    s = ("00.0" + s).substr(-4, 4) // zeropad
    let time = m+":"+s

    return <div className="__cursorHover" style={{left: left}}>
      <div className="__cursorHoverTime">
        {time}
      </div>
    </div>
  }

  //
  // Handlers
  //

  // We don't have an onClick event, we need the lower-level events so we can distinguish
  // between click and click-and-drag.
  mouseDownOnTimeline(e) {
    // This is the start of either a click or a drag.
    let currentSecs = this.getTimelineSecsFromMouseEvent(e)
    console.log("mouseDown at "+currentSecs+"s.")

    let drag = {type: "timelineSelection", from: currentSecs, intentional: false}
    this.setState({currentDrag: drag})
    this.props.setTimelineSelection(null)
  }

  mouseDownOnTaggingHandle(e, side) {
    e.preventDefault()
    e.stopPropagation()

    let currentSecs = this.getTimelineSecsFromMouseEvent(e)
    let drag = {type: "resizeTagging", side: side, from: currentSecs, intentional: false}

    this.setState({currentDrag: drag})
    this.props.setTimelineSelection(null)
    console.log("Started drag: ", drag)
  }

  handleMouseMove(e) {
    e.preventDefault()
    let currentSecs = this.getTimelineSecsFromMouseEvent(e)
    let drag = this.state.currentDrag

    if (!this.isMouseButtonHeldDown(e)) {
      this.setState({hoveringAt: currentSecs})
    } else if (drag) {
      drag.to = currentSecs
      if (!this.isDragIntentional(drag)) return // Ignore small, maybe-mistaken drags
      drag.intentional = true
      this.setState({currentDrag: drag}) // update :to and :intentional

      if (drag.type == "timelineSelection") {
        let leftSecs = Math.min(drag.from, drag.to)
        let rightSecs = Math.max(drag.from, drag.to)
        this.props.setTimelineSelection({left: leftSecs, right: rightSecs})
        this.props.setVideoSeekPos(drag.to)
      }

      if (drag.type == "resizeTagging") {
        this.setState({hoveringAt: null})
        this.props.setVideoSeekPos(drag.to)
      }
    }
  }

  handleMouseUp(e, mutations) {
    let currentSecs = this.getTimelineSecsFromMouseEvent(e)
    let drag = this.state.currentDrag
    console.log("mouseUp at "+currentSecs+"s. Current drag is: ", drag)

    if (!drag || !drag.intentional) {
      // This is a click. Reset all drag-related states.
      this.props.setTimelineSelection(null)
      this.props.setVideoSeekPos(currentSecs)
    } else if (drag.type == "timelineSelection") {
      // No action needed. We'll reset the drag state, but keep the timeline selection.
    } else if (drag.type == "resizeTagging") {
      // Update this tagging's boundary to reflect this drag.
      // Only proceed with the change if the current tagging boundaries are valid.
      // Otherwise the drag state will be reset and the change discarded.
      if (this.isResizeTaggingValid()) {
        let vars = {id: this.state.selectedTaggingId}
        let whichField = drag.side == "left" ? "startsAt" : "endsAt"
        vars[whichField] = drag.to
        mutations.updateTagging({variables: vars})
      }
    }

    this.setState({currentDrag: null})
  }

  isResizeTaggingValid() {
    let tagging = this.props.taggings.find((t) => t.id == this.state.selectedTaggingId)
    let drag = this.state.currentDrag

    // Sanity check: this func should only be called if a resize drag is present
    if (!drag || !drag.intentional || !drag.type == "resizeTagging")
      raise("Can't evaluate tagging validity because drag is in unexpected state!")

    let startsAt = tagging.starts_at
    let endsAt = tagging.ends_at
    if (drag.side == "left") startsAt = drag.to
    if (drag.side == "right") endsAt = drag.to

    console.log({startsAt, endsAt})

    // The tagging is valid if its duration is at least one (positive) second.
    return startsAt + 1 <= endsAt
  }

  handleZoomInClicked(e) {
    this.setState((state) => {
      return {zoom: state.zoom * 2.0}
    })
  }

  handleZoomOutClicked(e) {
    this.setState((state) => {
      return {zoom: state.zoom / 2.0}
    })
  }

  //
  // Helpers
  //

  timelineWidth() {
    return ""+(this.props.videoDuration * this.state.zoom)+"px"
  }

  getTimelineSecsFromMouseEvent(e) {
    let mousePageX = event.pageX
    let div = document.querySelector(".b-codingPageTimeline .__scrollContainer")
    let divOffset = div.getBoundingClientRect().x
    let divScroll = div.scrollLeft
    let positionInPixels = mousePageX - divOffset + divScroll
    let positionInSecs = positionInPixels / this.state.zoom
    // console.log({mousePageX, divOffset, divScroll, positionInPixels, positionInSecs})
    return positionInSecs
  }

  isMouseButtonHeldDown(e) {
    return e.buttons == 1
  }

  isDragIntentional(drag) {
    return drag.intentional || Math.abs(drag.to - drag.from) * this.state.zoom > 10
  }
}

Timeline.propTypes = {
  codingId: PropTypes.number.isRequired,
  videoSeekPos: PropTypes.number.isRequired, // seconds
  videoDuration: PropTypes.number.isRequired, // seconds
  setVideoSeekPos: PropTypes.func.isRequired,
  timelineSelection: PropTypes.object,
  setTimelineSelection: PropTypes.func.isRequired,
  taggings: PropTypes.array.isRequired
}

export default Timeline
