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
        // console.log("Received query data: ", data)
        if (data.coding) {
          let summary = data.coding.video.prompt.project.tags
            .map((t) => "{id: "+t.id+", text: \""+t.text+"\"}").join(", ")
          console.log("In particular, tags list is: ", summary)
        }

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
    return <div className="row">
      <div className="col-8">
        <div>
          <video className="b-codingPageVideo"
            poster={coding.video.thumbnail_url}
            src={coding.video.recording_url}
            controls preload="auto"
          ></video>
        </div>
        <Timeline
          videoSeekPos={this.state.videoSeekPos}
          videoDuration={this.state.videoDuration}
          setVideoSeekPos={(position) => {
            document.querySelector('.b-codingPageVideo').currentTime = position
          }} />
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

        <TagManager
          tags={coding.video.prompt.project.tags}
          codingId={this.props.codingId}
          projectId={parseInt(coding.video.prompt.project.id)}
        />
      </div>
    </div>
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

  refreshVideoSeekPos() {
    let video = document.querySelector('.b-codingPageVideo')
    if (video && video.currentTime != this.state.videoSeekPos) {
      this.setState({videoSeekPos: video.currentTime})
    }
  }
}

CodingPage.propTypes = {
  codingId: PropTypes.number.isRequired
}

export default CodingPage
