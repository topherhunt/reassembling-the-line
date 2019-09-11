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

    // Ziggeo events: https://ziggeo.com/docs/sdks/javascript/browser-interaction/events

    recorder.on('uploading', () => {
      $('.js-ziggeo-processing').fadeIn()
    })

    recorder.on('upload_progress', (uploaded, total) => {
      console.log('upload_progress: '+uploaded+' uploaded out of '+total+' total')
      let total_pct = (100 * uploaded / total / 2) + 0
      $('.js-ziggeo-processing .progress-bar').css('width', ''+total_pct+'%')
    })

    recorder.on('processing', (pct) => {
      console.log('processing progress: '+pct+'%')
      let total_pct = (100 * pct / 2) + 50
      $('.js-ziggeo-processing .progress-bar').css('width', ''+total_pct+'%')
    })

    recorder.on('processed', () => {
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

  })

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
