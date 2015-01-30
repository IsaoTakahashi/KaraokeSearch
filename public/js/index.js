$(function(){
  // $('th').fontFlex(30, 60, 70); 
  // $('td').fontFlex(30, 60, 70);

  function createPagination(pageCount) {
    $(".pagination").pagination({
        items: pageCount,
        displayedPages: 3,
        cssStyle: 'light-theme',
        onPageClick: function(currentPageNumber){
            showPage(currentPageNumber);
        }
  });
  }

  function showPage(currentPageNumber){
    var page="#page-" + currentPageNumber;
    $('.selection').hide();
    $(page).show();
  }

  $('#search_button').click(function(){
    var artist = $('#artist').val();
    var title = $('#title').val();

    if((artist + title).length == 0) {
      alert('アーティストかタイトルのどちらかを入力してください');
      return false;
    }

    $("#search_result").html('')
    $("#search_result").activity();
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
      displayNoResult();
    });
  });

  function displayNoResult() {
    $('#search_result').html('<div class="alert alert-warning">一件も見つかりませんでした。。。</div>');
  }

  function displayResult(json) {
    itemOnPage = 20;
    len = json.length;

    if (len < 1) {
      displayNoResult();
      return;
    }

    pageNum = ((len-1)/itemOnPage);
    createPagination(pageNum);

    th_font_size = $('#latest > table > thead > tr > th:first').css('font-size');
    th_style = 'style="font-size: ' + th_font_size + ';"'

    result_tag = $('#search_result')
    result_tag.html('')

    // create list
    result_table = $('<table class="table table-striped table-hover table-condensed"></table>');
    result_table.append('<thead><tr><th class="text-center"' + th_style + '>Artist</th><th class="text-center"' + th_style + '>Title</th></tr></thead>');
    
    result_table_body = $('<tbody id="page-1" class ="selection"></tbody>');
    for(var i=0; i<len; i++) {
      if (i % itemOnPage == 0) {
        result_table_body = $('<tbody id="page-' + ((i/itemOnPage)+1) + '" class ="selection"></tbody>');
        result_table.append(result_table_body);
      }
      result_table_body.append('<tr><td class="text-center"' + th_style + '>' + json[i].artist_name +'</td><td class="text-center"' + th_style + '>'+ json[i].song_title + '</td></tr>');
    }

    //result_table.append(result_table_body);

    // result_tag.append();
    // result_tag.append
    // result_tag.append("<div class='row'><div class='span3'>Artist</div><div class='span4'>Title</div></div>")
    // for(var i=0; i<len; i++) {
    //   result_tag.append("<div class='row'><div class='span3'>" + json[i].artist_name +"</div><div class='span4'>"+ json[i].song_title +"</div></div>")
    // }

    result_tag.append(result_table);

    $('.selection').hide();
    $('#page-1').show();
    $('#latest_label').hide();
    $('#latest').hide();
  }
});