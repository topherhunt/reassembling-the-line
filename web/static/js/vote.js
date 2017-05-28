$(function(){

  // On the first page load, hide rating questions until video playback completes
  if ($('.js-validation-errors').length > 0) {
    // If re-displaying the page on validation errors, show the ratings now.
    $('.js-ratings-container').fadeIn();
  } else {
    $('.play-video-container').on('ended', function(){
      if (! $('.js-ratings-container').is(':visible')) {
        $('.js-ratings-container').fadeIn();
      }
    });
  }

  // Show the ratings container after 30 secs even if video playback hasn't ended.
  window.setTimeout(function(){
    if (! $('.js-ratings-container').is(':visible')) {
      $('.js-ratings-container').fadeIn();
    }
  }, 30 * 1000);

  $('.js-select-tag').click(function(e){
    e.preventDefault();
    var button = $(this);
    button.toggleClass('active');
    update_tags_list();
  });

  $('.js-add-custom-tag').click(function(e){
    e.preventDefault();
    var button = $(this);
    if (button.hasClass('active')) {
      $('.js-custom-tag-input').val('').hide(200);
      update_tags_list();
    } else {
      $('.js-custom-tag-input').show(200);
    }
    button.toggleClass('active');
  });

  $('.js-custom-tag-input').change(function(){
    update_tags_list();
  });

  function update_tags_list(){
    var tags = [];
    $('.js-select-tag.active').each(function(){
      tags.push($(this).text());
    });
    if ($('.js-custom-tag-input').val() != ''){
      tags.push($('.js-custom-tag-input').val());
    }
    $('.js-vote-tags').val(tags.join(','));
  }

  // On page load, re-activate any selected tags
  if ($('.js-validation-errors').length > 0) {
    var tags = $('.js-vote-tags').val().split(",");
    $.each(tags, function(i, tag) {
      var existing_tag = $('.js-select-tag[text="'+tag+'"]');
      if (existing_tag.length > 0) {
        existing_tag.addClass('active');
      } else {
        $('.js-add-custom-tag').addClass('active');
        $('.js-custom-tag-input').show().val(tag);
      }
    });
  }

});
