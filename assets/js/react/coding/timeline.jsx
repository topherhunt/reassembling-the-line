import React from "react"
import PropTypes from "prop-types"
import TimelineTagging from "./timeline_tagging.jsx"
import TimelineTickmarks from "./timeline_tickmarks.jsx"

class Timeline extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      zoom: 20, // px width per second
      hoverSecs: null, // seconds
      mouseDownSecs: null, // seconds. (only relevant to drag-select)
      selectedTaggingId: null
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
    return <div className="b-codingPageTimeline">
      <div className="__scrollContainer">
        <div className="__timeline" style={{width: this.timelineWidth()}}
          onClick={() => this.setState({selectedTaggingId: null})}
          onMouseDown={this.handleMouseDown.bind(this)}
          onMouseUp={this.handleMouseUp.bind(this)}
          onMouseMove={this.handleMouseMove.bind(this)}
          onMouseLeave={() => this.setState({hoverSecs: null})}
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
          selectThis={() => this.setState({selectedTaggingId: tagging.id})}
          isSelected={this.state.selectedTaggingId == tagging.id}
          zoom={this.state.zoom}
        />
      })}
    </div>
  }

  renderSelection() {
    if (!this.props.timelineSelection) return

    let selection = this.props.timelineSelection
    let cssLeft = ""+(selection.left * this.state.zoom)+"px"
    let cssWidth = ""+((selection.right - selection.left) * this.state.zoom + 1)+"px"

    return <div className="__selection" style={{left: cssLeft, width: cssWidth}}></div>
  }

  renderPrimaryCursor() {
    let left = ""+(this.props.videoSeekPos * this.state.zoom)+"px"
    return <div id="timelinePrimaryCursor" className="__cursorPrimary" style={{left: left}}></div>
  }

  renderHoverCursor() {
    let left = ""+(this.state.hoverSecs * this.state.zoom)+"px"
    return <div className="__cursorHover" style={{left: left}}></div>
  }

  //
  // Handlers
  //

  // We don't have an onClick event, we need the lower-level events so we can distinguish
  // between click and click-and-drag.
  handleMouseDown(e) {
    // This is the start of either a click or a drag.
    let currentSecs = this.getTimelineSecsFromMouseEvent(e)
    console.log("mouseDown at "+currentSecs+"s.")
    this.setState({mouseDownSecs: currentSecs})
    this.props.setTimelineSelection(null)
  }

  handleMouseUp(e) {
    let currentSecs = this.getTimelineSecsFromMouseEvent(e)
    console.log("mouseUp at "+currentSecs+"s.")

    if (this.props.timelineSelection) {
      // This is the end of a drag. Reset the mouseDownSecs tracker.
      this.setState({mouseDownSecs: null})
    } else {
      // This is a click.
      this.setState({mouseDownSecs: null})
      this.props.setTimelineSelection(null)
      this.props.setVideoSeekPos(currentSecs)
    }
  }

  handleMouseMove(e) {
    let currentSecs = this.getTimelineSecsFromMouseEvent(e)

    if (this.state.mouseDownSecs && e.buttons == 1) {
      // The mouse button is down, so this is a drag in progress.
      let leftSecs = Math.min(this.state.mouseDownSecs, currentSecs)
      let rightSecs = Math.max(this.state.mouseDownSecs, currentSecs)
      this.props.setTimelineSelection({left: leftSecs, right: rightSecs})
      this.props.setVideoSeekPos(currentSecs)
    } else {
      // Mouse button isn't held down. This is a hover.
      this.setState({hoverSecs: currentSecs})
    }
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
