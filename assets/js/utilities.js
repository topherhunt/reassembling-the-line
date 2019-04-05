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

  $(document).on("click", "[phx-click-after-confirmation]", function(e){
    e.preventDefault();
    var question = $(this).attr("phx-click-after-confirmation");
    if (confirm(question)) {
      var hiddenTarget = $(this).siblings("[phx-click]")[0];
      console.log("Now triggering click on element: ", hiddenTarget);
      hiddenTarget.dispatchEvent(new Event('click'));
    }
  });
});
