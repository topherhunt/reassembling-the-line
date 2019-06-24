//
// Logic for admin uploading a video manually.
//

$(function(){
  if ($('.js-admin-upload-video-form').length == 0) { return; }

  //
  // Listeners
  //

  $('.js-upload-and-submit-btn, .js-retry-upload').click(function(e) {
    e.preventDefault();
    uploadAndSubmit();
  });

  //
  // Helpers
  //

  function uploadAndSubmit() {
    if (!isPermissionGiven()) {
      alert("Please give permission for us to use this recording.");
      return;
    }

    if (!isSpeakerNamePresent()) {
      alert("Speaker name is required.");
      return;
    }

    // Grab the file blobs that we'll upload
    var thumbnailFile = $('.js-thumbnail-attachment')[0].files[0]
    var recordingFile = $('.js-video-attachment')[0].files[0]

    if (!thumbnailFile) { alert("Please attach a thumbnail image."); return }
    if (!recordingFile) { alert("Please attach a video recording."); return }

    var thumbnailExt = /.+\.(\w+)/.exec(thumbnailFile.name)[1]
    var recordingExt = /.+\.(\w+)/.exec(recordingFile.name)[1]

    var thumbnailUrl = getUploadUrl(thumbnailExt)
    var recordingUrl = getUploadUrl(recordingExt)

    var filenameUuid = $('.js-upload-urls').data('uuid')
    $('.js-thumbnail-filename').val(filenameUuid+'.'+thumbnailExt)
    $('.js-recording-filename').val(filenameUuid+'.'+recordingExt)

    $('.js-admin-upload-video-form').hide();
    $('.js-upload-failed').hide();
    $('.js-upload-progress-container').fadeIn();

    console.log("Uploading the thumbnail to S3...");
    uploadFile(thumbnailUrl, thumbnailFile, false, function() {
      $('.progress-bar').css({width: "2%"});
      console.log("Uploading the recording to S3...");
      uploadFile(recordingUrl, recordingFile, true, function() {
        $('.progress-bar').css({width: "100%"});
        console.log("Uploads complete. Submitting.");
        $('.js-submit-form-btn').click();
      });
    });
  }

  function getUploadUrl(ext) {
    var uploadUrls = $('.js-upload-urls').data('urls')
    // var ext = /.+\.(\w+)/.exec(filename)[1]
    if (uploadUrls[ext]) {
      return uploadUrls[ext]
    } else {
      alert("Sorry, the file you've attached isn't a supported type. ("+ext+") Thumbnails must be in .jpg format; video must be in .webm or .mp4 format.")
      return abortThisThread()
    }
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
            var percent = Math.round((data.loaded / data.total) * 100);
            $('.progress-bar').css({width: percent+"%"});
          }
        }
        return xhr
      },
      success: function() {
        console.log("File successfully uploaded!");
        onSuccess();
      },
      error: function() {
        console.log("File not uploaded. Args: ", arguments);
        $('.js-upload-progress-container').hide();
        $('.js-upload-failed').show(200);
      }
    });
  }

  function isPermissionGiven() {
    return !!$('[name="video[permission]"]:checked').val()
  }

  function isSpeakerNamePresent() {
    return $("#video_speaker_name").val().trim() != ""
  }
});
