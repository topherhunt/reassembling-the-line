$(function(){
  if ($('.js-start-recording').length > 0) {
    // Spec is at http://dvcs.w3.org/hg/dap/raw-file/tip/media-stream-capture/RecordingProposal.html
    // Get any available version of the getUserMedia API

    // === Setup ===
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;
    var videoElement = document.querySelector('video'); // TODO: Can I Jquery-ize this?
    var mediaRecorder;
    var recording_data;
    var chunks = [];
    videoElement.controls = false;
    videoElement.muted    = true;

    $('.js-start-recording').click(function(e) {
      e.preventDefault();
      if (isBrowserCompatible()){
        $(this).hide();
        $('.js-time-remaining').show();
        $('.js-stop-recording').show();
        navigator.getUserMedia(userMediaSettings(), initializeRecording, alertRecordingFailed);
        setRecordingTimeout(120);
      } else {
        alert("Our recording plugin isn't compatible with your web browser. Please load this page using an up-to-date version of the Chrome or Firefox browser.");
      }
    });

    $('.js-stop-recording').click(function(e) {
      e.preventDefault();
      stopRecording();
    });

    $('.js-reset-recording').click(function(e){
      e.preventDefault();
      location.reload();
    });

    $('.js-submit-recording').click(function(e) {
      e.preventDefault();
      $('.js-reset-recording').hide();
      $(this).hide();
      $('.upload-progress-container').fadeIn();
      $('.progress-bar').animate({width: "95%"}, 10000);
      console.log("Uploading the recording to S3...");
      $.ajax({
        url: $(this).data('presigned-s3-url'),
        type: "PUT",
        contentType: "binary/octet-stream",
        processData: false,
        data: recording_data,
        success: function() {
          console.log("File successfully uploaded!");
          $('.edit-interview-form-submit-button').click();
        },
        error: function() {
          console.log("File not uploaded.");
          console.log(arguments);
        }
      });
    });

    // === Internal helpers ===

    function initializeRecording(stream) {
      console.log("Starting recording...");
      if (typeof MediaRecorder.isTypeSupported == 'function') {
        // MediaRecorder.isTypeSupported is a function announced in https://developers.google.com/web/updates/2016/01/mediarecorder and later introduced in the MediaRecorder API spec http://www.w3.org/TR/mediastream-recording/
        if (MediaRecorder.isTypeSupported('video/webm;codecs=h264')) {
          var options = {mimeType: 'video/webm;codecs=h264'};
        } else if (MediaRecorder.isTypeSupported('video/webm;codecs=vp9')) {
          var options = {mimeType: 'video/webm;codecs=vp9'};
        } else if (MediaRecorder.isTypeSupported('video/webm;codecs=vp8')) {
          var options = {mimeType: 'video/webm;codecs=vp8'};
        }
        console.log("Using mimetype: " + options.mimeType);
        mediaRecorder = new MediaRecorder(stream, options);
      } else {
        console.log("Using default codecs for this browser.");
        mediaRecorder = new MediaRecorder(stream);
      }

      mediaRecorder.start(10);

      var url = window.URL || window.webkitURL;
      videoElement.src = url ? url.createObjectURL(stream) : stream;
      videoElement.play();

      mediaRecorder.ondataavailable = function(event) {
        console.log("Data available...");
        chunks.push(event.data);
        // console.log(event.data);
        // console.log(event.data.type);
        // console.log(event);
      };

      mediaRecorder.onerror = function(e){
        console.log("Error: ", e); };

      mediaRecorder.onstart = function(){
        console.log("Started; state = " + mediaRecorder.state); };

      mediaRecorder.onstop = function(){
        console.log("Stopped; state = " + mediaRecorder.state);
        // TODO: Move all this to the Jquery listener
        var blob = new Blob(chunks, {type: "video/webm"});
        recording_data = blob;
        // Note: chunks can be reset to [] if we want to re-record without refresh
        var videoURL = window.URL.createObjectURL(blob);
        videoElement.src = videoURL;
        videoElement.controls = true;
        videoElement.muted    = false;
      };

      mediaRecorder.onpause = function(){
        console.log("Paused; state = " + mediaRecorder.state); };

      mediaRecorder.onresume = function(){
        console.log("Resumed; state = " + mediaRecorder.state); };

      mediaRecorder.onwarning = function(e){
        console.log("Warning: " + e); };
    }

    function setRecordingTimeout(seconds) {
      if (seconds > 0) {
        var counter = $('.js-time-remaining');
        counter.text("Time left: " + human_time(seconds));
        if (seconds < 10) {
          counter.addClass('text-danger');
        } else if (seconds < 30) {
          counter.addClass('text-warning');
        }

        setTimeout(function(){
          setRecordingTimeout(seconds - 1);
        }, 1000);
      } else {
        stopRecording();
      }
    }

    function human_time(seconds) {
      var m = Math.floor(seconds / 60);
      var s = seconds % 60;
      return m + ":" + ("0" + s).substr(-2, 2);
    }

    function stopRecording() {
      mediaRecorder.stop();
      $('.js-time-remaining').hide();
      $('.js-stop-recording').hide();
      setTimeout(function(){
        $('.js-reset-recording').fadeIn();
        $('.js-submit-recording').fadeIn();
      }, 1000);
    }

    function getBrowserName() {
      var nVer = navigator.appVersion;
      var nAgt = navigator.userAgent;
      var browserName  = navigator.appName;
      var fullVersion  = ''+parseFloat(navigator.appVersion);
      var majorVersion = parseInt(navigator.appVersion,10);
      var nameOffset,verOffset,ix;

      // In Opera, the true version is after "Opera" or after "Version"
      if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
       browserName = "Opera";
       fullVersion = nAgt.substring(verOffset+6);
       if ((verOffset=nAgt.indexOf("Version"))!=-1)
         fullVersion = nAgt.substring(verOffset+8);
      }
      // In MSIE, the true version is after "MSIE" in userAgent
      else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
       browserName = "Microsoft Internet Explorer";
       fullVersion = nAgt.substring(verOffset+5);
      }
      // In Chrome, the true version is after "Chrome"
      else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
       browserName = "Chrome";
       fullVersion = nAgt.substring(verOffset+7);
      }
      // In Safari, the true version is after "Safari" or after "Version"
      else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
       browserName = "Safari";
       fullVersion = nAgt.substring(verOffset+7);
       if ((verOffset=nAgt.indexOf("Version"))!=-1)
         fullVersion = nAgt.substring(verOffset+8);
      }
      // In Firefox, the true version is after "Firefox"
      else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
       browserName = "Firefox";
       fullVersion = nAgt.substring(verOffset+8);
      }
      // In most other browsers, "name/version" is at the end of userAgent
      else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) <
           (verOffset=nAgt.lastIndexOf('/')) )
      {
       browserName = nAgt.substring(nameOffset,verOffset);
       fullVersion = nAgt.substring(verOffset+1);
       if (browserName.toLowerCase()==browserName.toUpperCase()) {
        browserName = navigator.appName;
       }
      }
      // trim the fullVersion string at semicolon/space if present
      if ((ix=fullVersion.indexOf(";"))!=-1)
         fullVersion=fullVersion.substring(0,ix);
      if ((ix=fullVersion.indexOf(" "))!=-1)
         fullVersion=fullVersion.substring(0,ix);

      majorVersion = parseInt(''+fullVersion,10);
      if (isNaN(majorVersion)) {
       fullVersion  = ''+parseFloat(navigator.appVersion);
       majorVersion = parseInt(navigator.appVersion,10);
      }

      return browserName;
    }

    function userMediaSettings() {
      switch(getBrowserName()){
        case "Chrome":
          return {"audio": true, "video": {  "mandatory": {  "minWidth": 640,  "maxWidth": 640, "minHeight": 480,"maxHeight": 480 }, "optional": [] } };
        case "Firefox":
          return {audio: true,video: {  width: { min: 640, ideal: 640, max: 640 },  height: { min: 480, ideal: 480, max: 480 }}};
        default:
          return false;
      }
    }

    function isBrowserCompatible() {
      return !(typeof MediaRecorder === 'undefined' || !navigator.getUserMedia); }

    function alertRecordingFailed(error) {
      console.log('navigator.getUserMedia error: ', error);
      alert("There was an error; recording failed. Please refresh the page or contact us if you see this message repeatedly."); }
  }
});
