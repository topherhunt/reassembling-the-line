$(document).ready(function(){

  $('video').click(function(){
    this.paused ? this.play() : this.pause();
  });

});
