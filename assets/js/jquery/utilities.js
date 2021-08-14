import $ from "jquery"

$(function(){
  $("[data-focus-on-click]").click(function(){
    var target_selector = $(this).data("focus-on-click");
    $(target_selector).focus();
  });

  $(".js-copy-input").click(function(e){
    e.preventDefault()
    var fromSel = $(this).data("from")
    var toSel = $(this).data("to")
    var valueToCopy = $(fromSel).val()
    $(toSel).val(valueToCopy)
  })

  // Apply this class to an input or an entire form to suppress submit on enter.
  // TODO: Switch to HTML-only method: https://stackoverflow.com/a/51507806/1729692
  $('.js-suppress-enter').keydown(function(e){
    if (e.keyCode == 13) {
      console.log("ENTER press detected, default handler suppressed.")
      e.preventDefault()
    }
  })

  if ($('.js-show-if-video-unavailable').length > 0) {
    setTimeout(function(){
      var video = $('video')[0]
      if (video.readyState == 0) {
        $('.js-show-if-video-unavailable').show()
      }
    }, 1000)
  }
});

// This will help with testing that sourcemaps are working
window.testError = function() {
  return someRandomFunctionName()
}
