$(function(){

  $('[data-tooltip]').each(function(){
    var target = $(this);
    target.tooltip({
      title:     target.data('tooltip'),
      placement: target.data('placement') || 'top',
      delay:     100
    });
  });

});
