import { _ } from 'lodash';
// Same as: var _ = require('lodash');

var CodingTagComponent = {
  render: function(presets = {}) {
    var tag = _.merge({
      context: '',
      text: '',
      starts_at: '',
      ends_at: '',
      name_root: 'coding[tags]['+this.random_id()+']'
    }, presets);
    if (!this.context_is_valid(tag.context)) {
      throw new Error("Invalid context: " + tag.context);
    }
    return '<tr class="test-tag-row">' +
      this.context_and_text_html(tag) +
      this.time_window_html(tag) +
      '<td><a href="#" class="js-remove-tag test-remove-tag text-danger">remove</a></td>'
    '</tr>';
  },

  random_id: function() {
    return Math.round(Math.random() * 1000000000);
  },

  context_is_valid: function(context) {
    return ['location', 'demographic', 'topic', 'sentiment'].indexOf(context) > -1;
  },

  context_is_global: function(context) {
    return ['location', 'demographic'].indexOf(context) > -1;
  },

  context_and_text_html: function(tag) {
    return '<td>' +
      '<input type="hidden" name="'+tag.name_root+'[context]" value="'+tag.context+'" />' +
      '<input class="js-tag-text-field test-tag-text-field form-control" type="text" name="'+tag.name_root+'[text]" value="'+tag.text+'" placeholder="Type tag here" />' +
    '</td>';
  },

  time_window_html: function(tag) {
    if (this.context_is_global(tag.context)) {
      return '<td colspan="2"><em>whole video</em></td>';
    } else {
      return '' +
        '<td><input class="css-tag-time-field test-tag-time-field form-control" type="text" name="'+tag.name_root+'[starts_at]" value="'+tag.starts_at+'" placeholder="mm:ss" style="width: 70px;" /></td>' +
        '<td><input class="css-tag-time-field test-tag-time-field form-control" type="text" name="'+tag.name_root+'[ends_at]" value="'+tag.ends_at+'" placeholder="mm:ss" style="width: 70px;" /></td>';
    }
  }
};

export { CodingTagComponent };
