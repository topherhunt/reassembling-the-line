// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".

//
// 3rd-party
//

import "phoenix_html"
import "bootstrap"
import "react-phoenix"
import "trix"

// Local

import "./liveview_init"
import "./react/globals"
import "./jquery/utilities"
import "./jquery/explore"
import "./jquery/webcam_recording"
