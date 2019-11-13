//
// Logic for admin uploading a video manually.
//

import $ from "jquery"

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
    if (!isSpeakerNamePresent()) { raise("Please fill in your name.") }

    var thumbnailData = validateAndPrepFileForUpload('thumbnail')
    var recordingData = validateAndPrepFileForUpload('recording')

    $('.js-admin-upload-video-form').hide();
    $('.js-upload-failed').hide();
    $('.js-upload-progress-container').fadeIn();

    console.log("Uploading the thumbnail to S3...");
    uploadFile(thumbnailData.url, thumbnailData.file, false, function() {
      $('.progress-bar').css({width: "2%"});
      console.log("Uploading the recording to S3...");
      uploadFile(recordingData.url, recordingData.file, true, function() {
        $('.progress-bar').css({width: "100%"});
        console.log("Uploads complete. Submitting.");
        $('.js-submit-form-btn').click();
      });
    });
  }

  function validateAndPrepFileForUpload(type) {
    if (!['thumbnail', 'recording'].includes(type)) raise("Invalid file type: "+type)

    var file = $('.js-'+type+'-attachment')[0].files[0] || raise(type+" is required.")
    var ext = /.+\.(\w+)/.exec(file.name)[1]
    var uuid = $('.js-upload-urls').data('uuid')
    var allUploadUrls = $('.js-upload-urls').data('urls')
    var uploadUrl = allUploadUrls[ext] || raise("Unsupported "+type+" extension: ."+ext)

    // Set the filename input fields, so the Video record knows what files to link to.
    $('.js-'+type+'-filename').val(uuid+'.'+ext)

    return {file: file, url: uploadUrl}
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

  function isSpeakerNamePresent() {
    return $("#video_speaker_name").val().trim() != ""
  }

  function raise(msg) {
    console.error(msg)
    alert(msg)
    callNonexistentMethodToAbort()
  }
});
