$(function(){

  // TODO: This seems to not remotely work. And I'm unsure how to make it work
  // in a LiveView-heavy world.
  $("[data-tooltip]").each(function(){
    var target = $(this);
    target.tooltip({
      title:     target.data("tooltip"),
      placement: target.data("placement") || "top",
      delay:     100
    });
  });

  $(".js-chosen-select").chosen();

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
});
