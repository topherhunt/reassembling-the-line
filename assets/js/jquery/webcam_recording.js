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

  window.ziggeoApp.on("ready", function() {
    let ziggeoRecorderElement = document.getElementById("ziggeo-recorder")
    let videoKey = nanoid(10)
    console.log('Initializing recorder with video key: '+videoKey)

    let recorder = new ZiggeoApi.V2.Recorder({
      element: ziggeoRecorderElement,
      attrs: {
        width: '100%',
        height: '100%',
        theme: "modern",
        themecolor: "red",
        key: videoKey,
        'expiration-days': 1
      }
    });

    recorder.activate();

    // I think listeners go in here

    recorder.on('ready_to_record', (data) => {
      console.log('Event: ready_to_record. Data: ', data)
    })

    // recorder.on('recording_progress', (time) => {
    //   console.log('Event: recording_progress. Time: ', time)
    // })

    // recorder.on('uploading', (data) => {
    //   console.log('Event: uploading. Data: ', data)
    // })

    recorder.on('uploaded', (data) => {
      console.log('Event: uploaded. Data: ', data)
    })

    recorder.on('verified', (data) => {
      console.log('Event: verified. Data: ', data)
    })

    // recorder.on('processing', (pct) => {
    //   console.log('Event: processing. Percent: ', pct)
    // })

    recorder.on('processed', (data) => {
      console.log('Event: processed. Data: ', data)
    })
  });



  //
  // Listeners
  //

  // $('.js-upload-and-submit-btn, .js-retry-upload').click(function(e) {
  //   e.preventDefault()
  //   submitInterview()
  // })

  /*
    TODO - page elements to hide/show at certain moments:

    On recording start:
    $('.js-interview-form-container').hide()

    On recording stop:
    $('.js-recording-instructions-part-1').fadeOut()

    On 1s timeout after recording stop:
    $('.js-recording-instructions-part-2').fadeIn()
    $('.js-interview-form-container').fadeIn()
  */

  //
  // Helpers
  //

  function raise(msg) {
    console.error(msg)
    alert(msg)
    callNonexistentMethodToAbort()
  }

  function report(msg) {
    $.post("/api/log", {message: "Webcam recording page: "+msg})
  }

});
