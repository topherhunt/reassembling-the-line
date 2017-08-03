import { TagHelper } from 'web/static/js/helpers/tag_helper';
import { PlaylistRowComponent } from 'web/static/js/components/playlist_row_component';

var PlaylistHelper = {
  refresh_playlist: function() {
    var current_tags = TagHelper.get_from_select_elements();
    var player = $('.js-explore-video-player');
    $('.js-playlist-container').html('Loading...');
    player.attr('src', '');
    player[0].pause();
    $.ajax({
      method: 'GET',
      url: '/explore/playlist?tags=' + TagHelper.to_query_string(current_tags),
      success: function(data) {
        this.handle_new_playlist_data(data.playlist);
      }.bind(this),
      error: function(error) {
        console.log('Error loading playlist data: ', error);
        alert('Whoops, there was an error loading your playlist. Please refresh the page and try again, or contact us for help.');
      }
    });
  },

  handle_new_playlist_data: function(segments) {
    if (segments.length > 0) {
      this.populate_playlist(segments);
      this.play_clip(segments[0].segment_id);
      this.scroll_to_clip($('.js-playlist-row').first());
    } else {
      $('.js-playlist-container').html(this.no_results_html());
    }
  },

  populate_playlist: function(segments) {
    var container = $('.js-playlist-container');
    container.html('');
    $.each(segments, function(index, segment) {
      container.append(PlaylistRowComponent.render(segment));
    });
    container.append(this.end_of_results_html());
  },

  end_of_results_html: function() {
    return '<hr><div>' +
      'That\'s all the clips we have for your search. Adjust your filters to see more.<br>' +
      '<a href="#" class="js-clear-search">Clear all selected tags</a>' +
    '</div>';
  },

  no_results_html: function() {
    return '<hr><div>' +
      'We didn\'t find any results for that search.<br>' +
      '<a href="#" class="js-clear-search">Clear all selected tags</a>' +
    '</div>';
  },

  play_clip: function(segment_id) {
    var playlist_row  = $('.js-playlist-row[data-segment-id="'+segment_id+'"]');
    var recording_url = playlist_row.data('recording-url');
    var starts_at     = playlist_row.data('starts-at');
    var ends_at       = playlist_row.data('ends-at');
    var player        = $('.js-explore-video-player');
    $('.js-playlist-row.js-active').removeClass('js-active');
    playlist_row.addClass('js-active');
    player.data({'segment-id': segment_id, 'ends-at': ends_at});
    player.attr('src', recording_url+'#t='+starts_at);
  },

  scroll_to_clip: function(row) {
    var container = $('.js-playlist-container')[0];
    container.scrollTop = (row[0].offsetTop - container.offsetTop);
  },

  is_clip_done: function() {
    var player = $('.js-explore-video-player');
    var current_time = player[0].currentTime;
    var ends_at = player.data('ends-at');
    var is_paused = player[0].paused;
    var is_ended = player[0].ended;
    return is_ended || (!is_paused && current_time > 0 && current_time >= ends_at);
  }
};

export { PlaylistHelper };
