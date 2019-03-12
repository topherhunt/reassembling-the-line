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
      this.preview_button_html() +
      this.remove_button_html()
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
  },

  preview_button_html: function() {
    return '<td><a href="#" class="js-preview-tag text-info btn btn-light"><i class="ion-md-search"></i></a></td>';
  },

  remove_button_html: function() {
    return '<td><a href="#" class="js-remove-tag test-remove-tag text-danger btn btn-light"><i class="ion-md-trash"></i></a></td>';
  }
};

export { CodingTagComponent };
