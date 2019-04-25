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
  
});
