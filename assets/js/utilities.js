$(function(){

  $('[data-tooltip]').each(function(){
    var target = $(this);
    target.tooltip({
      title:     target.data('tooltip'),
      placement: target.data('placement') || 'top',
      delay:     100
    });
  });

  $('[data-confirmation]').each(function(){
    var question = $(this).data('confirmation');
    $(this).click(function(e){
      if (!confirm(question)) {
        e.preventDefault();
      }
    });
  });

});
