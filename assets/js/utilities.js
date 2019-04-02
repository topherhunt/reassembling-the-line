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

  // I drop to vanilla addEventListener here to make use of the `capture=true` flag.
  // It's critical that this listener be invoked before any others I define.
  // window.addEventListener("click", function(e){
  //   var target = e.target;
  //   var confirmation = target.dataset && target.dataset.confirmation;

  //   if (!confirmation) { return; }
  //   console.log('This target has data-confirmation.');
  //   if (confirm(confirmation)) {
  //     console.log("data-confirmation approved.");
  //   } else {
  //     console.log("data-confirmation rejected. Event suppressed.");
  //     e.preventDefault();
  //   }
  // }, true);

  // $(document).on("click", "[data-confirmation]", function(e){
  //   var question = $(this).data("confirmation");
  //   if (!confirm(question)) {
  //     console.log("data-confirmation rejected. Event suppressed.");
  //     e.stopPropagation();
  //   } else {
  //     console.log("data-confirmation approved.");
  //   }
  // });

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
