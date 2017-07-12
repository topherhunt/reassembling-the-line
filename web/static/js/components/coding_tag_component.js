var CodingTagComponent = {
  render: function(context, presets = {}) {
    if (!this.context_is_valid(context)) {
      throw new Error("Invalid context: " + context);
    }
    var id = Math.round(Math.random() * 1000000000);
    var name_root = 'coding[tags]['+id+']';
    return '<tr class="test-tag-row">' +
      this.context_and_text_html(context, name_root, presets) +
      this.time_window_html(context, name_root, presets) +
      '<td><a href="#" class="js-remove-tag test-remove-tag text-danger">remove</a></td>'
    '</tr>';
  },

  context_is_valid: function(context) {
    return ['location', 'demographic', 'topic', 'sentiment'].indexOf(context) > -1;
  },

  context_is_global: function(context) {
    return ['location', 'demographic'].indexOf(context) > -1;
  },

  context_and_text_html: function(context, name_root, presets) {
    return '<td>' +
      '<input type="hidden" name="'+name_root+'[context]" value="'+context+'" />' +
      '<input type="text" name="'+name_root+'[text]" value="'+presets.text+'" class="js-tag-text-field test-tag-text-field" />' +
    '</td>';
  },

  time_window_html: function(context, name_root, presets) {
    if (this.context_is_global(context)) {
      return '<td colspan="2"><em>whole video</em></td>';
    } else {
      return
        '<td><input class="css-tag-time-field test-tag-time-field" type="text" name="'+name_root+'[starts_at]" value="'+presets.starts_at+'" /></td>' +
        '<td><input class="css-tag-time-field test-tag-time-field" type="text" name="'+name_root+'[ends_at]" value="'+presets.ends_at+'" /></td>';
    }
  }
};
