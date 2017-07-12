CodingHelpers = {
  init_autocomplete: function() {
    $('.js-tags-table').each(function(i, table) {
      var available_tags = JSON.parse(table.data('autocompletes'));
      table.find('.js-tag-text-field').autocomplete({ source: available_tags });
    });
  }
};

$(document).ready(function() {
  setTimeout(function() {
    CodingHelpers.init_autocomplete();
  }, 1000);

  $('.js-add-tag').click(function(e) {
    e.preventDefault();
    var link = $(this);
    var context = link.parents('table.tags-table').data('context');
    link.parents('tr').before(CodingTagComponent.render(context));
    link.parents('tr').prev().find('.tag-text-field').focus();
    CodingHelpers.init_autocomplete();
  });

  $('.tags-table').on('click', '.js-remove-tag', function(e) {
    e.preventDefault();
    var tag_row = $(this).parents('tr');
    tag_row.remove();
  });
});
