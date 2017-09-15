import { PlaylistHelper } from 'web/static/js/helpers/playlist_helper';
import { TagHelper } from 'web/static/js/helpers/tag_helper';

$(document).ready(function() {

  if ($('.js-explore-video-player').length == 0) { return; }

  ////
  // Init
  //

  $('.js-chosen-select').chosen({width: "100%"});
  TagHelper.update_select_element(TagHelper.get_from_query_string());
  PlaylistHelper.refresh_playlist();

  ////
  // Event listeners
  //

  $('.js-chosen-select').chosen().on('change', function(){
    var current_tags = TagHelper.get_from_select_elements();
    TagHelper.update_page_url(current_tags);
    PlaylistHelper.refresh_playlist();
  });

  $('.js-playlist-container').on('click', '.js-clear-search', function(e) {
    e.preventDefault();
    var current_tags = [];
    TagHelper.update_select_element(current_tags);
    TagHelper.update_page_url(current_tags);
    PlaylistHelper.refresh_playlist();
  });

  $('.js-playlist-container').on('click', '.js-playlist-row', function() {
    var playlist_row = $(this);
    var player = $('.js-explore-video-player');
    if (playlist_row.data('segment-id') != player.data('segment-id')) {
      PlaylistHelper.play_clip(playlist_row.data('segment-id'));
    }
  });

  $('.js-explore-video-player').click(function(){
    this.paused ? this.play() : this.pause();
  });

  // Every second, check if we should move on to the next video
  window.setInterval(function() {
    if (PlaylistHelper.is_clip_done()) {
      var current_segment_id = $('.js-explore-video-player').data('segment-id');
      var current_playlist_row  = $('.js-playlist-row[data-segment-id="'+current_segment_id+'"]');
      var next_playlist_row = current_playlist_row.next('.js-playlist-row');
      if (next_playlist_row.length > 0) {
        var next_row = next_playlist_row.data('segment-id');
        PlaylistHelper.play_clip(next_row);
        PlaylistHelper.scroll_to_clip(current_playlist_row);
      } else {
        $('.js-explore-video-player')[0].pause();
      }
    }
  }, 1000);

});
