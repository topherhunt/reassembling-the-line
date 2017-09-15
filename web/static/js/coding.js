import { CodingTagComponent } from 'web/static/js/components/coding_tag_component';

var CodingHelpers = {
  init_autocomplete: function() {
    $('.js-tags-table').each(function(i, table) {
      var available_tags = $(table).data('autocompletes');
      $(table).find('.js-tag-text-field').autocomplete({ source: available_tags });
    });
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

  $('.js-coding-video-player').click(function(){
    this.paused ? this.play() : this.pause();
  });

  $('.js-time-skip').click(function(){
    var videoPlayer = $('video')[0];
    var amount = $(this).data('amount');
    videoPlayer.currentTime += amount;
  });
});
