import React from "react"
import PropTypes from "prop-types"

class TimelineTickmarks extends React.Component {
  render() {
    return <div style={{position: "relative", width: "100%", height: "100%"}}>
      {this.renderTickmarksEvery1Second()}
      {this.renderLabelsEvery5Seconds()}
      {/* (TODO: make the tickmark granularity conditional on zoom) */}
    </div>
  }

  renderTickmarksEvery1Second() {
    if (this.props.timelineZoom < 5) return
    let output = []

    for (let sec = 1; sec < this.props.videoDuration; sec ++) {
      if (sec % 5 == 0) continue
      output.push(
        // TODO: Move these styles to the class to reduce DOM verbosity
        <div key={sec} className="timeline1sTickmark" style={{
          position: "absolute",
          top: "0px",
          left: ""+(sec * this.props.timelineZoom)+"px",
          height: "10px",
          width: "0px",
          border: "0.5px solid rgba(255, 255, 255, 0.2)"
        }}></div>
      )
    }

    return output
  }

  renderLabelsEvery5Seconds() {
    let output = []

    for (let sec = 5; sec < this.props.videoDuration; sec += 5) {
      if (this.props.timelineZoom < 5 && sec % 20 != 0) continue
      if (this.props.timelineZoom < 1 && sec % 60 != 0) continue

      let m = Math.floor(sec / 60)
      let s = (sec % 60)
      s = ("00" + s).substr(-2, 2) // zeropad
      output.push(
        // TODO: Move these styles to the class to reduce DOM verbosity
        <div key={sec+"tick"} className="timeline5sTickmark" style={{
          position: "absolute",
          top: "0px",
          left: ""+(sec * this.props.timelineZoom)+"px",
          height: "15px",
          width: "0px",
          border: "0.5px solid rgba(255, 255, 255, 0.4)"
        }}></div>
      )
      output.push(
        // TODO: Move these styles to the class to reduce DOM verbosity
        <div key={sec+"label"} className="timeline5sLabel" style={{
          position: "absolute",
          top: "15px",
          left: ""+(sec * this.props.timelineZoom-10)+"px",
          textAlign: "center",
          fontSize: "10px",
          backgroundColor: "rgba(0, 0, 0, 0.2)",
          // border: "1px solid rgba(255, 255, 255, 0.2)",
          color: "rgba(255, 255, 255, 0.5)"
        }}>
          {m+":"+s}
        </div>
      )
    }

    return output
  }
}

TimelineTickmarks.propTypes = {
  videoDuration: PropTypes.number.isRequired,
  timelineZoom: PropTypes.number.isRequired
}

export default TimelineTickmarks
