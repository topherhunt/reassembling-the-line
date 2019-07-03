import React from "react"
import PropTypes from "prop-types"
import TimelineTickmarks from "./timeline_tickmarks.jsx"

class Timeline extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      zoom: 10, // px width per second
      hoverPos: null, // seconds
      mouseDownPos: null, // seconds. (only relevant to drag-select)
      dragSelection: null
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
      <div className="__zoomInWarning">Nothing to see here, you've zoomed out too far. Zoom back in!</div>
      <div className="__scrollContainer">
        <div className="__timeline" style={{width: this.timelineWidth()}}
          onMouseDown={this.handleMouseDown.bind(this)}
          onMouseUp={this.handleMouseUp.bind(this)}
          onMouseMove={this.handleMouseMove.bind(this)}
          onMouseLeave={() => this.setState({hoverPos: null})}
        >
          <TimelineTickmarks
            videoDuration={this.props.videoDuration}
            zoom={this.state.zoom}
          />
          {this.renderPrimaryCursor()}
          {this.renderSelection()}
          {this.renderHoverCursor()}
        </div>
      </div>
      <div className="__zoomControls">
        <i className="icon" onClick={this.handleZoomInClicked.bind(this)}>zoom_in</i>
        <i className="icon" onClick={this.handleZoomOutClicked.bind(this)}>zoom_out</i>
      </div>
    </div>
  }

  renderPrimaryCursor() {
    let left = ""+(this.props.videoSeekPos * this.state.zoom)+"px"
    return <div id="timelinePrimaryCursor" className="__cursorPrimary" style={{left: left}}></div>
  }

  renderSelection() {
    if (!this.state.dragSelection) return

    let selection = this.state.dragSelection
    // Need to expliictly set the sort algorithm; by default it uses alphasort
    let boundaries = [selection.start, selection.end].sort((a, b) => a - b)
    let startPos = boundaries[0] // timeline position in seconds
    let endPos = boundaries[1] // timeline position in seconds
    let left = ""+(startPos * this.state.zoom)+"px"
    let width = ""+((endPos - startPos) * this.state.zoom + 1)+"px"

    return <div className="__selection" style={{left: left, width: width}}></div>
  }

  renderPrimaryCursor() {
    let left = ""+(this.props.videoSeekPos * this.state.zoom)+"px"
    return <div id="timelinePrimaryCursor" className="__cursorPrimary" style={{left: left}}></div>
  }

  renderHoverCursor() {
    let left = ""+(this.state.hoverPos * this.state.zoom)+"px"
    return <div className="__cursorHover" style={{left: left}}></div>
  }

  //
  // Handlers
  //

  // We don't have an onClick event, we need the lower-level events so we can distinguish
  // between click and click-and-drag.
  handleMouseDown(e) {
    // This is the start of either a click or a drag.
    let position = this.getTimelineSecsFromMouseEvent(e)
    console.log("mouseDown at "+position+"s.")
    this.setState({mouseDownPos: position, dragSelection: null})
  }

  handleMouseUp(e) {
    let position = this.getTimelineSecsFromMouseEvent(e)
    console.log("mouseUp at "+position+"s.")

    if (this.state.dragSelection) {
      // This is the end of a drag. Reset the mouseDownPos tracker.
      this.setState({mouseDownPos: null})
    } else {
      // This is a click.
      this.setState({mouseDownPos: null, dragSelection: null})
      this.props.setVideoSeekPos(position)
    }
  }

  handleMouseMove(e) {
    let position = this.getTimelineSecsFromMouseEvent(e)

    if (this.state.mouseDownPos && e.buttons == 1) {
      // The mouse button is down, so this is a drag in progress.
      let startPos = this.state.mouseDownPos
      // console.log("Dragging. mouseDownPos: "+startPos+", curPos: "+position+".")
      this.setState({dragSelection: {start: startPos, end: position}})
      this.props.setVideoSeekPos(position)
    } else {
      // Mouse button isn't held down. This is a hover.
      this.setState({hoverPos: position})
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
  videoSeekPos: PropTypes.number.isRequired, // seconds
  videoDuration: PropTypes.number.isRequired, // seconds
  setVideoSeekPos: PropTypes.func.isRequired
}

export default Timeline