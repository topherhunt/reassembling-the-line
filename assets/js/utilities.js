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

  // LiveView dom targets used to have very agressive JS listeners that would
  // ignore any stopPropagation attempts. But I wanted to use a JS confirm
  // pop-up guarding my phx-click event, so I used this workaround: click on
  // a second (visible) element, and if the confirm msg is approved, emit a
  // click event on the primary (hidden) element. That no longer works but
  // I think the latest version of LiveView plays nicer with event propagation.
  // Leaving this commented out in case they re-break it.
  // $(document).on("click", "[phx-click-after-confirmation]", function(e){
  //   e.preventDefault();
  //   var question = $(this).attr("phx-click-after-confirmation");
  //   if (confirm(question)) {
  //     var hiddenTarget = $(this).siblings("[phx-click]")[0];
  //     console.log("Now triggering click on element: ", hiddenTarget);
  //     hiddenTarget.dispatchEvent(new Event('click'));
  //   }
  // });

  // Now that LiveView dom handlers respect event propagation, I can simply
  // add a normal data-confirm to my phx- listeners.
  // Actually it looks like phoenix_html already supports data-confirm.
  // $(document).on("click", "[data-confirm]", function(e){
  //   var message = $(this).data("confirm");
  //   if (!confirm(message)) {
  //     console.log("STOPPING");
  //     e.preventDefault();
  //   }
  // });
});
