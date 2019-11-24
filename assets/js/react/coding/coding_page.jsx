import React from "react"
import PropTypes from "prop-types"
import {ApolloProvider} from "react-apollo"
import apolloClient from "../../apollo/client"
import {Query} from "react-apollo"
import {codingPageQuery} from "../../apollo/queries"
import Timeline from "./timeline.jsx"
import TagManager from "./tag_manager.jsx"

class CodingPage extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      videoSeekPos: 0.0, // seconds
      videoDuration: 600, // seconds (default: 10 mins)
      timelineSelection: null // {start: pos, end: pos}
    }

    this.setActualVideoDuration()
    setInterval(this.refreshVideoSeekPos.bind(this), 100)
  }

  render() {
    return this.renderApolloProviderWrapper()
  }

  renderApolloProviderWrapper() {
    return <ApolloProvider client={apolloClient}>
      {this.renderMainQueryWrapper()}
    </ApolloProvider>
  }

  renderMainQueryWrapper() {
    return <Query query={codingPageQuery} variables={{id: this.props.codingId}}>
      {({loading, error, data}) => {
        if (loading) return this.renderLoading()
        else if (error) return this.renderError()
        else return this.renderCodingPage(data.coding)
      }}
    </Query>
  }

  renderLoading() {
    return <div>Loading...</div>
  }

  renderError() {
    return <div>Error!</div>
  }

  renderCodingPage(coding) {
    return <div className="row test-coding-page">
      <div className="col-8">
        <div>
          <video className="b-codingPageVideo"
            poster={coding.video.thumbnail_url}
            src={coding.video.recording_url}
            controls preload="auto"
          ></video>
        </div>

        <Timeline
          codingId={this.props.codingId}
          taggings={coding.taggings}
          videoSeekPos={this.state.videoSeekPos}
          videoDuration={this.state.videoDuration}
          timelineSelection={this.state.timelineSelection}
          setVideoSeekPos={(position, opts) => {
            let video = document.querySelector('.b-codingPageVideo')
            video.currentTime = position
            if (opts && opts.play) video.play()
            if (opts && opts.pauseAt) this.setState({pauseVideoAt: opts.pauseAt})
          }}
          setTimelineSelection={(selection) => {
            // The selection is either {left:, right:} (in decimal seconds) or null.
            this.setState({timelineSelection: selection})
          }}
        />
      </div>

      <div className="col-4 u-stack">
        <div>
          <h4>Video info</h4>
          <div>
            Speaker: {coding.video.speaker_name}
            {coding.video.permission_show_name ? "" : this.warnNamePrivate()}
          </div>

          <div>
            Question: <span className="text-success">{coding.video.prompt.sanitized_text}</span>
          </div>
        </div>

        <TagManager
          codingId={this.props.codingId}
          projectId={parseInt(coding.video.prompt.project.id)}
          tags={coding.video.prompt.project.tags}
          taggings={coding.taggings}
          timelineSelection={this.state.timelineSelection}
        />
      </div>
    </div>
  }

  warnNamePrivate() {
    return <span className="small em">(name is private) - TODO</span>
  }

  setActualVideoDuration() {
    let video = document.querySelector('.b-codingPageVideo')

    if (video && video.duration && video.duration != Infinity) {
      console.log("Got actual video duration: "+video.duration+"s.")
      this.setState({videoDuration: video.duration})
    } else {
      console.log("No video duration info, will check again in 1s.")
      setTimeout(this.setActualVideoDuration.bind(this), 1000)
    }
  }

  refreshVideoSeekPos() {
    let video = document.querySelector('.b-codingPageVideo')
    if (!video) return // in case it hasn't rendered yet

    if (video.currentTime != this.state.videoSeekPos)
      this.setState({videoSeekPos: video.currentTime})

    if (this.state.pauseVideoAt && video.currentTime >= this.state.pauseVideoAt) {
      video.pause()
      this.setState({pauseVideoAt: null})
    }
  }
}

CodingPage.propTypes = {
  codingId: PropTypes.number.isRequired
}

export default CodingPage
