//
// Logic for capturing a video recording from webcam and uploading it to S3.
//
// Resources re: recording video:
// - https://developer.mozilla.org/en-US/docs/Web/API/MediaStream_Recording_API/Using_the_MediaStream_Recording_API
// - https://developer.mozilla.org/en-US/docs/Web/API/MediaStream
// - https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder
//
// Resources re: uploading to S3:
// - https://stackoverflow.com/a/42211543/1729692
//

import $ from "jquery"
import nanoid from "nanoid"

$(function(){
  if ($('#ziggeo-recorder').length == 0) { return }

  let videoKey = nanoid(10) // Generate a unique filename for this video & thumbnail
  let hasUnsavedData = false

  window.ziggeoApp.on("ready", function() {
    let ziggeoRecorderElement = document.getElementById("ziggeo-recorder")
    report("Initializing Ziggeo widget. videoKey: "+videoKey)

    let recorder = new ZiggeoApi.V2.Recorder({
      element: ziggeoRecorderElement,
      attrs: {
        // countdown: false,
        width: '100%',
        height: '100%',
        theme: "modern",
        themecolor: "red",
        timelimit: 60 * 5,
        key: videoKey,
        'expiration-days': 1
      }
    });

    recorder.activate();

    // Ziggeo events: https://ziggeo.com/docs/sdks/javascript/browser-interaction/events

    recorder.on("recording", () => {
      report("Video recording started. videoKey: "+videoKey)
      hasUnsavedData = true
    })

    recorder.on('uploading', () => {
      report("Video upload started. videoKey: "+videoKey)
      $('.js-ziggeo-processing').fadeIn()
    })

    recorder.on('upload_progress', (uploaded, total) => {
      let total_pct = (100 * uploaded / total / 2) + 0
      $('.js-ziggeo-processing .progress-bar').css('width', ''+total_pct+'%')
    })

    recorder.on('processing', (pct) => {
      let total_pct = (100 * pct / 2) + 50
      $('.js-ziggeo-processing .progress-bar').css('width', ''+total_pct+'%')
    })

    recorder.on('processed', () => {
      report("Video upload complete. videoKey: "+videoKey)
      $('.js-ziggeo-processing').hide()
      $('.js-interview-form-container').fadeIn();
      $('.js-recording-filename').val(videoKey+'.mp4')
      $('.js-thumbnail-filename').val(videoKey+'.jpg')
    })

    recorder.on('rerecord', () => {
      $('.js-interview-form-container').hide()
      $('.js-ziggeo-processing').hide()
    })
  });

  $('.js-form-submit').click((e) => {
    if (!isSpeakerNamePresent()) {
      preventSubmit(e, gettext("Please fill in your name."))
    } else {
      report("Submitting video form. videoKey: "+videoKey)
      hasUnsavedData = false
    }
  })

  // Prevent accidental navigation away from the in-progress page
  window.addEventListener("beforeunload", function(event) {
    if (hasUnsavedData) {
      report("beforeunload fired and video was not submitted. videoKey: "+videoKey)
      event.preventDefault()
      let msg = "You haven't submitted your video yet. Are you sure you want to leave this page?"
      event.returnValue = msg
      return msg
    }
  })

  //
  // Helpers
  //

  function isSpeakerNamePresent() {
    return $("#video_speaker_name").val().trim() != ""
  }

  function preventSubmit(e, message) {
    alert(message)
    e.preventDefault()
  }

  // Unused now. Re-add if I need better monitoring.
  function report(msg) {
    console.log(msg)
    $.post("/api/log", {message: "Webcam recording page: "+msg})
  }

});
