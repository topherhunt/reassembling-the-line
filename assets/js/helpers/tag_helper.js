import $ from "jquery"
import { _ } from 'lodash'

var TagHelper = {
  get_from_query_string: function() {
    var query_string = window.location.search.substring(1)
    if (query_string.indexOf("tags=") == -1) { return [] }
    var tags_string = query_string
      .split("&")
      .find(function(i){ return i.indexOf("tags=") == 0 })
      .substring(5)
    var tags = tags_string
      .split(",")
      .map(function(tag){
        var tag_array = decodeURI(tag).split(":")
        return {text: tag_array[1]}
      })
    return tags
  },

  get_from_select_elements: function() {
    var tag = $('.js-filter-tag').val()
    return !!tag ? [{text: tag}] : []
  },

  to_query_string: function(tags) {
    return tags
      .map(function(i){ return i.text })
      .join(",")
  },

  update_page_url: function(tags) {
    var tags_qs = this.to_query_string(tags)
    window.history.pushState({}, "Explore Videos", "clips?tags=" + tags_qs)
  },

  update_select_element: function(filtered_tags) {
    var select = $('.js-filter-tag')
    var tag_text = filtered_tags.map(function(t) { return t.text })
    select.val('')
    select.val(tag_text)
    select.trigger('chosen:updated')
  }
}

export { TagHelper }
