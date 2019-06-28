import React from "react"
import PropTypes from "prop-types"
import {ApolloProvider} from "react-apollo"
import apolloClient from "../../apollo/client"
import {Query} from "react-apollo"
import {codingPageQuery} from "../../apollo/queries"
import TagManager from "./tag_manager.jsx"

class CodingPage extends React.Component {
  constructor(props) {
    super(props)
    // Not yet sure what state we'll want to manage from here:
    // - current video cursor location?
    // - ??
    this.state = {}
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
    return <div className="row">
      <div className="col-8">
        <div>
          <video
            poster={coding.video.thumbnail_url}
            src={coding.video.recording_url}
            style={{display: "block", width: "100%", height: "380px", backgroundColor: "#222"}}
            controls
          ></video>
        </div>
        <div>
          <div style={{width: "100%", height: "200px", backgroundColor: "#2A075E"}}>
            TODO
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

  warnNamePrivate() {
    return <span className="small em">(name is private) - TODO</span>
  }
}

CodingPage.propTypes = {
  coding_id: PropTypes.number.isRequired
}

export default CodingPage
