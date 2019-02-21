import { _ } from 'lodash';
// Same as: var _ = require('lodash');

var CodingTagComponent = {
  render: function(presets = {}) {
    var tag = _.merge({
      text: '',
      starts_at: '',
      ends_at: '',
      name_root: 'coding[tags]['+this.random_id()+']'
    }, presets);
    return '<tr class="test-tag-row">' +
      this.text_html(tag) +
      this.time_window_html(tag) +
      '<td><a href="#" class="js-remove-tag test-remove-tag text-danger">remove</a></td>'
    '</tr>';
  },

  random_id: function() {
    return Math.round(Math.random() * 1000000000);
  },

  text_html: function(tag) {
    return '<td>' +
      '<input class="js-tag-text-field test-tag-text-field form-control" type="text" name="'+tag.name_root+'[text]" value="'+tag.text+'" placeholder="Type tag here" />' +
    '</td>';
  },

  time_window_html: function(tag) {
    return '' +
      '<td><input class="css-tag-time-field test-tag-time-field form-control" type="text" name="'+tag.name_root+'[starts_at]" value="'+(tag.starts_at || '')+'" placeholder="mm:ss" style="width: 70px;" /></td>' +
      '<td><input class="css-tag-time-field test-tag-time-field form-control" type="text" name="'+tag.name_root+'[ends_at]" value="'+(tag.ends_at || '')+'" placeholder="mm:ss" style="width: 70px;" /></td>';
  }
};

export { CodingTagComponent };