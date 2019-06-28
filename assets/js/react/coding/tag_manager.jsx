import React from "react"
import PropTypes from "prop-types"

class TagManager extends React.Component {
  render() {
    return <div>
      <div><span className="h4">Tags</span> <a href="TODO">How does this work?</a></div>
      <div className="u-box-shadow" style={{height: "200px"}}>
        {this.props.tags.map((tag) =>
          <div key={tag.id} className="u-hover-highlight" style={{position: "relative"}}>
            <div>{tag.text} (TODO: buttons on hover)</div>
            <div style={{position: "absolute", top: "0px", right: "10px"}}>{tag.countTaggings}</div>
          </div>
        )}
      </div>
    </div>
  }
}

TagManager.propTypes = {
  tags: PropTypes.array.isRequired
}

export default TagManager
