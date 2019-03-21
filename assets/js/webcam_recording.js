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

$(function(){
  if ($('.js-webcam-recording-container').length == 0) { return; }

  // NOTE: This will probably only work on Chrome and Firefox.
  // I can improve compatibility by keying into browser-specific apis; see the ZB code
  // See also https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder#Browser_compatibility
  // More lenient test: !(navigator.mediaDevices && navigator.mediaDevices.getUserMedia)
  var isBrowserSupported = (['Chrome', 'Firefox'].indexOf(getBrowserName()) > -1)
  if (!isBrowserSupported) {
    $('.js-webcam-recording-container').hide();
    $('.js-incompatible-browser-alert').show();
    return;
  }

  //
  // Init the video stream
  //

  console.log("Initializing webcam recording JS.");

  var videoPlayer;
  var mediaStream;
  var mediaRecorder;
  var recordingChunks;
  var recordingBlob;
  var thumbnailBlob;

  videoPlayer = $('.js-recording-preview-video')[0];
  videoPlayer.controls = false;
  recordingChunks = [];

  // Initialize (but don't start) the recording when the page loads.
  // See https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
  navigator.mediaDevices.getUserMedia({audio: true, video:true})
    .then(function(stream) {
      initializeRecording(stream);
    })
    .catch(function(error) {
      console.log("getUserMedia failed:", error);
      $('.js-webcam-recording-container').hide();
      $('.js-init-failed-alert').show();
    });

  //
  // Listeners
  //

  $('.js-start-recording').click(function(e) {
    e.preventDefault();
    startRecording();
  });

  $('.js-stop-recording').click(function(e) {
    e.preventDefault();
    stopRecording();
  });

  $('.js-restart-recording').click(function(e){
    e.preventDefault();
    // We could clear and restart the recording without a page refresh, but the
    // thumbnail generation process doesn't like this for some reason (dirty canvas?)
    location.reload();
  });

  $('.js-upload-and-submit-btn').click(function(e) {
    e.preventDefault();
    submitInterview();
  });

  //
  // Handler functions
  //

  function initializeRecording(stream) {
    mediaStream = stream;
    playLiveVideoPreview();

    // TODO: Is there sense in explicitly setting the mimetype options?
    // e.g. {mimeType: 'video/webm;codecs=vp9'}
    mediaRecorder = new MediaRecorder(mediaStream);
    mediaRecorder.onwarning = function(e){ console.log("Warning: ", e); };
    mediaRecorder.onerror   = function(e){ console.log("Error: ", e); };
    mediaRecorder.ondataavailable = function(e) {
      recordingChunks.push(e.data);
      console.log("Receiving data...");
    };

    $('.js-setting-up-recording').hide();
    $('.js-start-recording').show();
  }

  function startRecording() {
    $('.js-interview-form-container').hide();
    $('.js-start-recording').hide();
    $('.js-restart-recording').hide();

    setTimeout(function(){
      $('.js-stop-recording').fadeIn();
      $('.js-time-remaining').fadeIn();
      showRecordingTimer(60 * 5);
    }, 1000);

    recordingChunks = []; // ensure any stale recording data is cleared out
    mediaRecorder.start(100); // send chunk every 100 ms

    captureThumbnail();
  }

  function stopRecording() {
    $('.js-time-remaining').hide();
    $('.js-stop-recording').hide();
    $('.js-restart-recording').show();
    $('.js-recording-instructions-part-1').fadeOut();
    setTimeout(function(){
      $('.js-recording-instructions-part-2').fadeIn();
      $('.js-interview-form-container').fadeIn();
    }, 1000);

    mediaRecorder.stop();
    recordingBlob = new Blob(recordingChunks, {'type': 'video/webm'});
    playRecording(recordingBlob);
  }

  function submitInterview() {
    if (!$('#video_permission_researchers').is(':checked') && !$('#video_permission_public').is(':checked')) {
      alert("Please give permission for us to use this interview first.");
      return;
    }

    $('.js-interview-form-container').hide();
    $('.js-upload-progress-container').fadeIn();
    $('.progress-bar').animate({width: "95%"}, 10000);

    var thumbnailUrl = $('.js-upload-data-container').data('thumbnail-presigned-s3-url');
    var recordingUrl = $('.js-upload-data-container').data('recording-presigned-s3-url');

    console.log("Uploading the thumbnail to S3...");
    uploadFile(thumbnailUrl, thumbnailBlob, function() {
      console.log("Uploading the recording to S3...");
      uploadFile(recordingUrl, recordingBlob, function() {
        console.log("Uploads complete. Submitting.");
        $('.js-submit-form-btn').click();
      });
    });
  }

  //
  // Helpers
  //

  function getBrowserName() {
    var nAgt = navigator.userAgent;

    // In Opera, the true version is after "Opera" or after "Version"
    if (nAgt.indexOf("Opera")!=-1) {
      return "Opera";
    }
    // In MSIE, the true version is after "MSIE" in userAgent
    else if (nAgt.indexOf("MSIE")!=-1) {
      return "Microsoft Internet Explorer";
    }
    // In Chrome, the true version is after "Chrome"
    else if (nAgt.indexOf("Chrome")!=-1) {
      return "Chrome";
    }
    // In Safari, the true version is after "Safari" or after "Version"
    else if (nAgt.indexOf("Safari")!=-1) {
      return "Safari";
    }
    // In Firefox, the true version is after "Firefox"
    else if (nAgt.indexOf("Firefox")!=-1) {
      return "Firefox";
    }
    // In most other browsers, "name/version" is at the end of userAgent
    else {
      return "other";
    }
  }

  function showRecordingTimer(seconds) {
    if (seconds > 0) {
      var counter = $('.js-time-remaining');
      counter.text("Time left: " + human_time(seconds));
      if (seconds < 10) {
        counter.addClass('text-danger');
      } else if (seconds < 30) {
        counter.addClass('text-warning');
      }

      setTimeout(function(){
        showRecordingTimer(seconds - 1);
      }, 1000);
    } else {
      stopRecording();
    }
  }

  function human_time(total_seconds) {
    var min = Math.floor(total_seconds / 60);
    var sec = total_seconds % 60;
    return min + ":" + ("0" + sec).substr(-2, 2);
  }

  // Relies on the mediaStream having started
  function captureThumbnail() {
    var track = mediaStream.getVideoTracks()[0];
    var imageCapture = new ImageCapture(track);
    imageCapture.grabFrame()
    .then(function(imageBitmap) {
      // We have the image as imageBitmap, now we need to render it into a jpeg blob.
      // See https://developer.mozilla.org/en-US/docs/Web/API/ImageCapture#Example

      var imgWidth = imageBitmap.width;
      var imgHeight = imageBitmap.height;

      var canvas = document.querySelector('.js-thumbnail-canvas');
      canvas.width = 480; // let's ensure non-terrible image quality
      canvas.height = (canvas.width * imgHeight / imgWidth);
      canvas.getContext('2d').drawImage(imageBitmap, 0, 0, canvas.width, canvas.height);
      canvas.toBlob(updateThumbnailBlob, 'image/jpeg', 0.8);
    })
    .catch(function(error) {
      console.error("ImageCapture.grabFrame() failed: ", error);
      console.log(error);
    });
  }

  function updateThumbnailBlob(blob) {
    thumbnailBlob = blob;
  }

  function playLiveVideoPreview() {
    videoPlayer.srcObject = mediaStream;
    videoPlayer.controls = false;
    videoPlayer.muted = true;
  }

  function playRecording(blobToPlay) {
    videoPlayer.srcObject = undefined; // must unset this before setting src
    videoPlayer.src = window.URL.createObjectURL(blobToPlay);
    videoPlayer.controls = true;
    videoPlayer.muted = false;
  }

  function uploadFile(url, fileBlob, onSuccess) {
    $.ajax({
      url: url,
      type: "PUT",
      contentType: "binary/octet-stream",
      processData: false,
      data: fileBlob,
      success: function() {
        console.log("File successfully uploaded!");
        onSuccess();
      },
      error: function() {
        console.log("File not uploaded. Args: ", arguments);
        // TODO: It would be nice to report the error client-side (Rollbar?) so we aren't in the dark about what caused this unanticipated failure
        alert("There was an error, and we were unable to save your recording. Please refresh the page and try again, or contact us for help.");
        $('.js-upload-progress-container').hide();
      }
    });
  }
});
