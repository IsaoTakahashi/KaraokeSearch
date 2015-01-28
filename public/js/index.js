$(function(){
  $('#search_button').click(function(){
    var artist = $('#artist').val();
    var title = $('#title').val();

    if((artist + title).length == 0) {
      alert('アーティストかタイトルのどちらかを入力してください');
      return false;
    }
    
    var request = $.ajax({
      type: 'GET',
      url: '/search',
      dataType: 'json',
      data: {
        artist: artist,
        title: title
      }
    }).done(function(json,status,xhr){
      displayResult(json)
    }).fail(function(jqxhr, status, error){
      $('#search_result').html('<div>一件も見つかりませんでした。。。</div>');
    });
  });

  function displayResult(json) {
    len = json.length;
    result_tag = $('#search_result')
    result_tag.html("")
    result_tag.append("<div class='row'><div class='span3'>アーティスト</div><div class='span4'>タイトル</div></div>")
    for(var i=0; i<len; i++) {
      result_tag.append("<div class='row'><div class='span3'>" + json[i].artist_name +"</div><div class='span4'>"+ json[i].song_title +"</div></div>")
    }
  }
});