import { PlaylistRowComponent } from 'web/static/js/components/playlist_row_component';

var Helpers = {
  uniq: function(array) {
    return array.filter(function(item, index){
      // This will only return true for the FIRST appearance of the item.
      return array.indexOf(item) == index;
    });
  }
};

var PlaylistHelper = {
  refresh_playlist: function() {
    var current_tags = TagHelper.get_from_select_elements();
    var player = $('.js-explore-video-player');
    console.log('refresh_playlist() called. Will query with tags:', current_tags);
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
    $('.js-playlist-container').scrollTop = playlist_row.offsetTop;
    player.data({'segment-id': segment_id, 'ends-at': ends_at});
    player.attr('src', recording_url+'#t='+starts_at);
  },

  is_clip_done: function() {
    var player = $('.js-explore-video-player');
    var current_time = player[0].currentTime;
    var ends_at = player.data('ends-at');
    var is_paused = player[0].paused;
    var is_ended = player[0].ended;
    // console.log('is_clip_done(): ', current_time, ends_at, is_paused, is_ended);
    return is_ended || (!is_paused && current_time > 0 && current_time >= ends_at);
  }
};

var TagHelper = {
  get_from_query_string: function() {
    var query_string = window.location.search.substring(1);
    if (query_string.indexOf("tags=") == -1) { return []; }
    var tags_string = query_string
      .split("&")
      .find(function(i){ return i.indexOf("tags=") == 0; })
      .substring(5);
    var tags = tags_string
      .split(",")
      .map(function(tag){
        var tag_array = tag.split(":");
        return { context: tag_array[0], text: tag_array[1] };
      });
    return tags;
  },

  get_from_select_elements: function() {
    var tags = [];
    $('.js-chosen-select').each(function(index, el) {
      var context = $(el).data('context');
      var texts = $(el).val();
      $.each(texts, function(index, text) {
        tags.push({context: context, text: text});
      });
    });
    return tags;
  },

  to_query_string: function(tags) {
    return tags
      .map(function(i){ return i.context + ':' + i.text; })
      .join(",");
  },

  update_page_url: function(tags) {
    var tags_qs = this.to_query_string(tags);
    window.history.pushState({}, "Explore Videos", "explore?tags=" + tags_qs);
  },

  update_select_elements: function(filtered_tags) {
    console.log('update_select_elements() called with tags: ' + JSON.stringify(filtered_tags));
    var all_contexts = filtered_tags.map(function(t) { return t.context; });
    var contexts = Helpers.uniq(all_contexts);
    $.each(contexts, function(index, context) {
      var select = $('.js-chosen-select[data-context="'+context+'"]');
      var relevant_tags = filtered_tags
        .filter(function(t) { return t.context == context; })
        .map(function(t) { return t.text; });
      select.val(relevant_tags);
      select.trigger('chosen:updated');
    });
  }
}

$(document).ready(function() {

  if ($('.js-explore-video-player').length == 0) { return; }

  ////
  // Init
  //

  $('.js-chosen-select').chosen({width: "100%"});
  TagHelper.update_select_elements(TagHelper.get_from_query_string());
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
    TagHelper.update_select_elements(current_tags);
    TagHelper.update_page_url(current_tags);
    PlaylistHelper.refresh_playlist();
  });

  $('.js-playlist-container').on('click', '.js-playlist-row', function() {
    console.log('js-playlist-row was clicked!');
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
        PlaylistHelper.play_clip(next_playlist_row.data('segment-id'));
      } else {
        $('.js-explore-video-player')[0].pause();
      }
    }
  }, 1000);

});
