import { _ } from 'lodash';

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
        var tag_array = decodeURI(tag).split(":");
        return { context: tag_array[0], text: tag_array[1] };
      })
      .filter(function(tag){
        return (tag.context && tag.context != "");
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
    var contexts = _.map($('.js-chosen-select'),
      function(select) { return $(select).data('context'); });
    $.each(contexts, function(index, context) {
      var select = $('.js-chosen-select[data-context="'+context+'"]');
      var relevant_tags = filtered_tags
        .filter(function(t) { return t.context == context; })
        .map(function(t) { return t.text; });
      select.val('');
      select.val(relevant_tags);
      select.trigger('chosen:updated');
    });
  }
}

export { TagHelper };
