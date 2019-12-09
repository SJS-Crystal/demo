$(document).ready(function() {
    $("body").on("click", "span.reply", function(){
      id = $(this).attr("id");
      $(this).remove();
      $("#form" + id).css("display", "block");
      $("#form" + id).find("#comment_content").focus();
  });
});
