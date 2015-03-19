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

    $('.pagination:first').html('');
    $('#search_result').html('');
    $('#search_result').activity({
      width: 30,
      length: 40
    });
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
    $('#search_result').html('<div class="alert alert-warning sp-alert">一件も見つかりませんでした。。。</div>');
  }

  function displayResult(json) {
    itemOnPage = 10;
    len = json.length;

    if (len < 1) {
      displayNoResult();
      return;
    }

    pageNum = ((len-1)/itemOnPage);
    createPagination(pageNum);

    th_font_size = $('#latest > table > thead > tr > th:first').css('font-size');
    th_style = 'style="font-size: ' + th_font_size + ';"'

    resultTag = $('#search_result')
    resultTag.html('')

    classForElement = 'text-center col-xs-12 col-md-6'

    for(var i=0; i<len; i++) {
      if (i % itemOnPage == 0) {
        page = $('<div id="page-' + ((i/itemOnPage)+1) + '" class ="selection"></div>');
        resultTag.append(page);
      }
      artistElement = $('<div class="' + classForElement + ' sp-artist">' + json[i].artist_name +'</div>');
      titleElement = $('<div class="' + classForElement + ' sp-title">' + json[i].song_title + '</div>');
      page.append(artistElement).append(titleElement);
   }

    $('.selection').hide();
    $('#page-1').show();
    $('#latest_label').hide();
    $('#latest').hide();
  }
});