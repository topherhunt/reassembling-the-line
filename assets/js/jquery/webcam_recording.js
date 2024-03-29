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

// We used to use naniod to generate unique filenames for Ziggeo uploads. Unused now.
// import nanoid from "nanoid"

$(function(){
  if ($('.js-webcam-recording-container').length == 0) { return }

  if (typeof MediaRecorder == "undefined") {
    $('.js-webcam-recording-container').hide()
    $('.js-browser-not-compatible').show()
    return
  }

  //
  // Init the video stream
  //

  console.log("Initializing webcam recording JS.")

  var videoPlayer
  var mediaStream
  var mediaRecorder
  var recordingChunks
  var recordingBlob
  var hasUnsavedData

  videoPlayer = $('.js-recording-preview-video')[0]
  videoPlayer.controls = false
  recordingChunks = []
  hasUnsavedData = false

  // Initialize (but don't start) the recording when the page loads.
  // See https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
  navigator.mediaDevices.getUserMedia({audio: true, video: true})
    .then(function(stream) {
      initializeRecording(stream)
    })
    .catch(function(error) {
      console.log("getUserMedia failed:", error)
      $('.js-webcam-recording-container').hide()
      $('.js-init-failed-alert').show()
    })

  //
  // Listeners
  //

  $('.js-start-recording').click(function(e) {
    e.preventDefault()
    startRecordingCountdown()
  })

  $('.js-stop-recording').click(function(e) {
    e.preventDefault()
    stopRecording()
  })

  $('.js-restart-recording').click(function(e){
    e.preventDefault()
    location.reload() // just refresh the whole page to ensure its state is fully reset
  })

  $('.js-download-recording').click(function(e){
    e.preventDefault()
    downloadRecording()
  })

  $('.js-upload-and-submit-btn, .js-retry-upload').click(function(e) {
    e.preventDefault()
    submitInterview()
  })

  // Prevent accidental navigation away from the in-progress page
  window.addEventListener("beforeunload", function(event) {
    if (hasUnsavedData) {
      report("beforeunload fired and video was not submitted.")
      event.preventDefault()
      let msg = "You haven't submitted your video yet. Are you sure you want to leave this page?"
      event.returnValue = msg
      return msg
    }
  })

  //
  // Lifecycle handlers
  //

  function initializeRecording(stream) {
    mediaStream = stream
    playLiveVideoPreview()

    // TODO: Is there sense in explicitly setting the mimetype options?
    // e.g. {mimeType: 'video/webm;codecs=vp9'}
    mediaRecorder = new MediaRecorder(mediaStream)
    mediaRecorder.onwarning = function(e){ console.log("Warning: ", e) }
    mediaRecorder.onerror   = function(e){ console.log("Error: ", e) }
    mediaRecorder.ondataavailable = function(e) {
      recordingChunks.push(e.data)
      console.log("Receiving data...")
    }

    $('.js-setting-up-recording').hide()
    $('.js-start-recording').show()
  }

  function startRecordingCountdown() {
    report("startRecordingCountdown called.")

    $('.js-interview-form-container').hide()
    $('.js-start-recording').hide()
    $('.js-restart-recording').hide()

    var countdown = $('.js-countdown')
    countdown.show().text("Recording in 3...")
    setTimeout(function(){ countdown.text("Recording in 2...") }, 1000)
    setTimeout(function(){ countdown.text("Recording in 1...") }, 2000)
    setTimeout(function(){ countdown.hide(); startRecording()  }, 3000)
  }

  // The countdown timer has finished; actual recording starts now.
  function startRecording() {
    $('.js-stop-recording').fadeIn()
    $('.js-time-remaining').fadeIn()
    showRecordingTimer(60 * 5)

    recordingChunks = [] // ensure any stale recording data is cleared out
    mediaRecorder.start(100) // send chunk every 100 ms
    hasUnsavedData = true
  }

  function stopRecording() {
    if (mediaRecorder.state != 'recording') {
      console.log("Suppressing stopRecording call; mediaRecorder is already stopped.")
      return
    }

    report("stopRecording called.")

    $('.js-time-remaining').hide()
    $('.js-stop-recording').hide()
    $('.js-restart-recording').show()
    $('.js-recording-instructions-part-1').fadeOut()
    setTimeout(function(){
      $('.js-recording-instructions-part-2').fadeIn()
      $('.js-interview-form-container').fadeIn()
    }, 1000)

    mediaRecorder.stop()
    recordingBlob = new Blob(recordingChunks, {'type': 'video/webm'})
    playRecording(recordingBlob)
  }

  function downloadRecording() {
    var d = new Date()
    var string = d.toLocaleString().replace(/[^\w]+/g, "-")

    var link = $('.js-download-recording-link')[0]
    link.download = string
    link.href = window.URL.createObjectURL(recordingBlob)
    link.click()
  }

  function submitInterview() {
    report("submitInterview called.")

    if (!isSpeakerNamePresent()) { raise("Please fill in your name.") }
    // We don't require a consent checkbox anymore, it's just a warning banner.
    // if (!isPermissionGiven()) { raise("Please select a permission option.") }

    $('.js-interview-form-container').hide()
    $('.js-upload-failed').hide()
    $('.js-upload-progress-container').fadeIn()

    // Grab the presigned S3 upload urls corresponding to each file type.
    // For now we always capture as .webm, and convert to .mp4 & .jpg on the backend.
    let uploadUrls = $('.js-upload-data').data('urls')
    let recordingUrl = uploadUrls.webm || raise("Can't find .webm upload url")

    // Set the filename input fields, so the Video record knows what files to link to.
    let filename_base = $('.js-upload-data').data('filename-base')
    $('.js-recording-filename').val(filename_base+'.webm')

    // Start the actual upload.
    console.log("Uploading the recording to S3...")
    report("Uploading recording...")
    $('.progress-bar').css({width: "2%"})

    uploadFile(recordingUrl, recordingBlob, true, function(){
      console.log("Uploads complete. Submitting.")
      hasUnsavedData = false
      report("Recording uploaded.")
      $('.progress-bar').css({width: "100%"})
      $('.js-submit-form-btn').click()
    })
  }

  //
  // Helpers
  //

  function showRecordingTimer(seconds) {
    if (seconds > 0) {
      var counter = $('.js-time-remaining')
      counter.text("Time left: " + human_time(seconds))
      if (seconds < 10) {
        counter.addClass('text-danger')
      } else if (seconds < 30) {
        counter.addClass('text-warning')
      }

      setTimeout(function(){
        showRecordingTimer(seconds - 1)
      }, 1000)
    } else {
      stopRecording()
    }
  }

  function human_time(total_seconds) {
    var min = Math.floor(total_seconds / 60)
    var sec = total_seconds % 60
    return min + ":" + ("0" + sec).substr(-2, 2)
  }

  function playLiveVideoPreview() {
    videoPlayer.srcObject = mediaStream
    videoPlayer.controls = false
    videoPlayer.muted = true
  }

  function playRecording(blobToPlay) {
    videoPlayer.srcObject = undefined // must unset this before setting src
    videoPlayer.src = window.URL.createObjectURL(blobToPlay)
    videoPlayer.controls = true
    videoPlayer.muted = false
  }

  function isSpeakerNamePresent() {
    return $("#video_speaker_name").val().trim() != ""
  }

  function uploadFile(url, fileBlob, updateBarOnProgress, onSuccess) {
    $.ajax({
      url: url,
      type: "PUT",
      contentType: "binary/octet-stream",
      processData: false,
      data: fileBlob,
      xhr: function() {
        var xhr = $.ajaxSettings.xhr()
        // Progress listener thanks to https://stackoverflow.com/a/46903750/1729692
        xhr.upload.onprogress = function(data) {
          if (updateBarOnProgress) {
            var percent = Math.round((data.loaded / data.total) * 100)
            $('.progress-bar').css({width: percent+"%"})
          }
        }
        return xhr
      },
      success: function() {
        console.log("File successfully uploaded!")
        onSuccess()
      },
      error: function() {
        report("Failed on upload to url: "+url)
        console.log("File not uploaded. Args: ", arguments)
        $('.js-upload-progress-container').hide()
        $('.js-upload-failed').show(200)
      }
    })
  }

  function raise(msg) {
    console.error(msg)
    alert(msg)
    callNonexistentMethodToAbort()
  }

  // Report each important lifecycle event to help in troubleshooting
  function report(msg) {
    $.post("/api/log", {message: "Webcam recording page: "+msg})
  }

})
