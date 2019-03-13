import { CodingTagComponent } from './components/coding_tag_component';

var CodingHelpers = {
  init_autocomplete: function() {
    $('.js-tags-table').each(function(i, table) {
      var available_tags = $(table).data('autocompletes');
      $(table).find('.js-tag-text-field').autocomplete({ source: available_tags });
    });
  },

  time_to_integer: function(string) {
    if (string.match(/^(\d\d?):(\d\d)$/)) {
      var matches = string.match(/^(\d\d?):(\d\d)$/)
      var mins = parseInt(matches[1]);
      var secs = parseInt(matches[2]);
      return mins * 60 + secs;
    } else if (string.match(/^(\d\d?)$/)) {
      var matches = string.match(/^(\d\d?)$/)
      var secs = parseInt(matches[1]);
      return secs;
    } else {
      return undefined;
    }
  }
};

$(document).ready(function() {

  if ($('.js-coding-video-player').length == 0) { return; }

  ////
  // Coding controls
  //

  setTimeout(function() {
    CodingHelpers.init_autocomplete();
  }, 1000);

  $('.js-add-tag').click(function(e) {
    e.preventDefault();
    var link = $(this);
    link.parents('tr').before(CodingTagComponent.render());
    link.parents('tr').prev().find('.js-tag-text-field').focus();
    CodingHelpers.init_autocomplete();
  });

  $('.js-tags-table').on('click', '.js-preview-tag', function(e) {
    e.preventDefault();
    var tag_row = $(this).parents('tr');
    var starts_at = tag_row.find('.js-start-time-field').val();
    var ends_at = tag_row.find('.js-end-time-field').val();
    var start_secs = CodingHelpers.time_to_integer(starts_at);
    var end_secs = CodingHelpers.time_to_integer(ends_at);

    if (start_secs === undefined || end_secs === undefined) {
      alert("Your start or end time is invalid, so I can't preview this tag.");
      return;
    }

    // Validations to consider:
    // - Reject if start or end time were present but unparseable
    // - Reject if either start time or end time is present, but not both
    // - Reject if start time is >= end time

    // Seek to starts_at, start playback, and flag when the preview should be stopped
    var video = $('.js-coding-video-player');
    video[0].currentTime = start_secs;
    video[0].play();
    video.data({previewing: true, stop_at: end_secs});
    // Now play the video until you reach ends_at (see the setInterval call)
  });

  $('.js-tags-table').on('click', '.js-remove-tag', function(e) {
    e.preventDefault();
    var tag_row = $(this).parents('tr');
    tag_row.remove();
  });

  // Populate all pre-selected tags
  $('.js-tags-table').each(function(i, table) {
    var footer = $(table).find('.js-add-tag').parents('tr');
    var present_tags = $(table).data('present-tags') || [];
    $.each(present_tags, function(i, presets) {
      footer.before(CodingTagComponent.render(presets));
    });
  });

  ////
  // Video playback
  //

  $('.js-time-skip').click(function(){
    var videoPlayer = $('video')[0];
    var amount = $(this).data('amount');
    videoPlayer.currentTime += amount;
  });

  function ensurePreviewStoppedAtEndTime() {
    var video = $('.js-coding-video-player');
    var previewing = video.data('previewing');
    var stop_at = video.data('stop_at');
    var paused = video[0].paused;
    var currentTime = video[0].currentTime;

    if (previewing) {
      if (paused) {
        // If the user manually paused, clear previewing status.
        video.data({previewing: undefined, stop_at: undefined});
      } else if (currentTime > stop_at) {
        // The preview window is over. Pause the video.
        video[0].pause();
        video.data({previewing: undefined, stop_at: undefined});
      } else {
        // The preview is still running. Nothing to do yet, wait until next tick.
      }
    }
  }

  // Every 0.1 seconds, check if we should move on to the next video
  window.setInterval(ensurePreviewStoppedAtEndTime, 100);
});
