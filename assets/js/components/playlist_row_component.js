var PlaylistRowComponent = {
  render: function(segment) {
    var data = 'data-segment-id="'+segment.segment_id+'" data-video-id="'+segment.video_id+'" data-recording-url="'+segment.recording_url+'" data-starts-at="'+segment.starts_at+'" data-ends-at="'+segment.ends_at+'"';
    return '<div class="js-playlist-row" '+data+'>' +
      this.thumbnail_html(segment) +
      '<div class="js-playlist-title">'+segment.title+'</div>' +
      '<div class="playlist-tags-container">'+this.tags_html(segment.tags)+'</div>' +
    '</div>';
  },

  random_id: function() {
    return Math.round(Math.random() * 1000000000);
  },

  thumbnail_html: function(segment) {
    var style = 'background-image: url(\''+segment.thumbnail_url+'\')';
    return '<div class="play-icon"></div>' +
      '<div class="js-thumbnail" style="'+style+'"></div>';
  },

  // Input: an array of tag objects, each in format {text:}
  tags_html: function(tags) {
    return tags
      .map(function(tag) {
        var text = tag.text;
        return '<span class="js-playlist-tag" data-text="'+text+'">'+text+'</span>';
      })
      .join("");
  }
};

export { PlaylistRowComponent };
