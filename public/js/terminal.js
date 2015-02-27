$(function(){
  $('.terminal-input').keypress(function(event){
    if(event.keyCode == 13) {
      $.get( "/panel/terminal/ajax=" + $('.terminal-input').val(), function( data ) {
        $(".terminal-output").html(data);
        console.log('ok');
      });
      $('.terminal-input').val('');
    }
  })
})
