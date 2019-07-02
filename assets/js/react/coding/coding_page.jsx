import React from "react"
import PropTypes from "prop-types"
import {ApolloProvider} from "react-apollo"
import apolloClient from "../../apollo/client"
import {Query} from "react-apollo"
import {codingPageQuery} from "../../apollo/queries"
import TagManager from "./tag_manager.jsx"
import TimelineTickmarks from "./timeline_tickmarks.jsx"

class CodingPage extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      videoSeek: 0.0, // seconds
      videoDuration: 600, // seconds (default: 10 mins)
      timelineZoom: 10, // px per second
      // Once we have a subcomponent for the timeline, move this down
      timelineHover: null // seconds
    }

    this.setActualVideoDuration()
    setInterval(this.setVideoSeek.bind(this), 100)
  }

  componentDidUpdate(prevProps, prevState) {
    // If the seek position has changed, ensure the seek cursor is visible.
    if (this.state.videoSeek != prevState.videoSeek) {
      document.querySelector("#timelineSeekCursor").scrollIntoViewIfNeeded()
    }
  }

  render() {
    return <ApolloProvider client={apolloClient}>
      <Query query={codingPageQuery} variables={{id: this.props.coding_id}}>
        {({loading, error, data}) => {
          if (loading) return this.renderLoading()
          else if (error) return this.renderError()
          else return this.renderCodingPage(data.coding)
        }}
      </Query>
    </ApolloProvider>
  }

  renderLoading() {
    return <div>Loading...</div>
  }

  renderError() {
    return <div>Error!</div>
  }

  renderCodingPage(coding) {
    let timelineWidth = ""+(this.state.videoDuration * this.state.timelineZoom)+"px"
    return <div className="row">
      <div className="col-8">
        <div>
          <video className="b-codingPageVideo"
            poster={coding.video.thumbnail_url}
            src={coding.video.recording_url}
            controls preload="auto"
          ></video>
        </div>
        <div className="b-codingPageTimeline">
          <div className="__zoomInWarning">Nothing to see here, you've zoomed out too far. Zoom back in!</div>
          <div className="__scrollContainer">
            <div className="__timeline" style={{width: timelineWidth}}
              onClick={(e) => {
                let secs = this.getTimelineSecsFromMouseEvent(e)
                document.querySelector('.b-codingPageVideo').currentTime = secs
              }}
              onMouseMove={(e) => {
                let secs = this.getTimelineSecsFromMouseEvent(e)
                this.setState({timelineHover: secs})
              }}
              onMouseLeave={() => {
                this.setState({timelineHover: null})
              }}
            >
              {/* This is a good boundary for a subcomponent because we don't want it to re-render unless the props change. */}
              <TimelineTickmarks
                videoDuration={this.state.videoDuration}
                timelineZoom={this.state.timelineZoom} />
              {this.renderTimelineVideoSeekCursor()}
              {this.renderTimelineHoverCursor()}
            </div>
          </div>
          <div className="__zoomControls">
            <i className="icon"
              onClick={(e) => {
                this.setState((state) => {
                  return {timelineZoom: state.timelineZoom * 2.0}
                })
              }}
            >zoom_in</i>
            <i className="icon"
              onClick={(e) => {
                this.setState((state) => {
                  return {timelineZoom: state.timelineZoom / 2.0}
                })
              }}
            >zoom_out</i>
          </div>
        </div>
      </div>
      <div className="col-4 u-stack">
        <div>
          <h4>Basic video info</h4>
          <div>
            Speaker: {coding.video.speaker_name}
            {coding.video.permission_show_name ? "" : this.warnNamePrivate()}
          </div>
          <div>
            Question: <span className="text-success">{coding.video.prompt.sanitized_text}</span>
          </div>
        </div>

        <TagManager tags={coding.video.prompt.project.tags} />
      </div>
    </div>
  }

  renderTimelineVideoSeekCursor() {
    let left = ""+(this.state.videoSeek * this.state.timelineZoom)+"px"
    return <div id="timelineSeekCursor" className="__cursorPrimary" style={{left: left}}></div>
  }

  renderTimelineHoverCursor() {
    let left = ""+(this.state.timelineHover * this.state.timelineZoom)+"px"
    return <div className="__cursorHover" style={{left: left}}></div>
  }

  warnNamePrivate() {
    return <span className="small em">(name is private) - TODO</span>
  }

  setActualVideoDuration() {
    let video = document.querySelector('.b-codingPageVideo')
    if (video && !!video.duration && video.duration != Infinity) {
      console.log("Got actual video duration: "+video.duration+"s.")
      this.setState({videoDuration: video.duration})
    } else {
      console.log("No video duration info, will check again in 1s.")
      setTimeout(this.setActualVideoDuration.bind(this), 1000)
    }
  }

  setVideoSeek() {
    let video = document.querySelector('.b-codingPageVideo')
    if (video && video.currentTime != this.state.videoSeek) {
      this.setState({videoSeek: video.currentTime})
    }
  }

  getTimelineSecsFromMouseEvent(e) {
    let mousePageX = event.pageX
    let div = document.querySelector(".b-codingPageTimeline .__scrollContainer")
    let divOffset = div.getBoundingClientRect().x
    let divScroll = div.scrollLeft
    let positionInPixels = mousePageX - divOffset + divScroll
    let positionInSecs = positionInPixels / this.state.timelineZoom
    // console.log({mousePageX, divOffset, divScroll, positionInPixels, positionInSecs})
    return positionInSecs
  }
}

CodingPage.propTypes = {
  coding_id: PropTypes.number.isRequired
}

export default CodingPage
