import React from "react"
import PropTypes from "prop-types"
import TimelineTickmarks from "./timeline_tickmarks.jsx"

class Timeline extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      zoom: 10, // px width per second
      hoverPos: null // seconds
    }
  }

  componentDidUpdate(prevProps, prevState) {
    // If the seek position has changed, ensure the seek cursor is visible.
    if (this.props.videoSeekPos != prevProps.videoSeekPos) {
      document.querySelector("#timelinePrimaryCursor").scrollIntoViewIfNeeded()
    }
  }

  render() {
    let timelineWidth = ""+(this.props.videoDuration * this.state.zoom)+"px"
    return <div className="b-codingPageTimeline">
      <div className="__zoomInWarning">Nothing to see here, you've zoomed out too far. Zoom back in!</div>
      <div className="__scrollContainer">
        <div className="__timeline" style={{width: timelineWidth}}
          onClick={(e) => {
            let position = this.getTimelineSecsFromMouseEvent(e)
            this.props.setVideoSeekPos(position)
          }}
          onMouseMove={(e) => {
            let secs = this.getTimelineSecsFromMouseEvent(e)
            this.setState({hoverPos: secs})
          }}
          onMouseLeave={() => {
            this.setState({hoverPos: null})
          }}
        >
          {/* This is a good boundary for a subcomponent because we don't want it to re-render unless the props change. */}
          <TimelineTickmarks
            videoDuration={this.props.videoDuration}
            zoom={this.state.zoom} />
          {this.renderPrimaryCursor()}
          {this.renderHoverCursor()}
        </div>
      </div>
      <div className="__zoomControls">
        <i className="icon"
          onClick={(e) => {
            this.setState((state) => {
              return {zoom: state.zoom * 2.0}
            })
          }}
        >zoom_in</i>
        <i className="icon"
          onClick={(e) => {
            this.setState((state) => {
              return {zoom: state.zoom / 2.0}
            })
          }}
        >zoom_out</i>
      </div>
    </div>
  }

  renderPrimaryCursor() {
    let left = ""+(this.props.videoSeekPos * this.state.zoom)+"px"
    return <div id="timelinePrimaryCursor" className="__cursorPrimary" style={{left: left}}></div>
  }

  renderHoverCursor() {
    let left = ""+(this.state.hoverPos * this.state.zoom)+"px"
    return <div className="__cursorHover" style={{left: left}}></div>
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
