var CodingTagComponent = {
  render: function(presets = {}) {
    let defaults = {
      text: '',
      starts_at: '',
      ends_at: '',
      name_root: 'coding[tags]['+this.random_id()+']'
    }
    let tag = {...defaults, ...presets} // presets will override defaults

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
      '<td><input class="js-start-time-field form-control" type="text" name="'+tag.name_root+'[starts_at]" value="'+(tag.starts_at || '')+'" placeholder="mm:ss" style="width: 90px;" /></td>' +
      '<td><input class="js-end-time-field form-control" type="text" name="'+tag.name_root+'[ends_at]" value="'+(tag.ends_at || '')+'" placeholder="mm:ss" style="width: 90px;" /></td>';
  },

  preview_button_html: function() {
    // TODO: Bootstrap Jquery tooltips don't play well with my hand-rolled component system. Once I rewrite on Vue, try tooltips again.
    return '<td><a href="#" class="js-preview-tag text-info btn btn-light" alt="Preview this tag"><i class="ion-md-eye"></i></a></td>';
  },

  remove_button_html: function() {
    return '<td><a href="#" class="js-remove-tag test-remove-tag text-danger btn btn-light"><i class="ion-md-trash"></i></a></td>';
  }
};

export { CodingTagComponent };
