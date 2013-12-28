(function($) {
if($('body.about, body.thankyou').length < 1 ) {
  Messenger.options = {
    extraClasses: 'messenger-on-top',
    theme: 'block'
  };

  var randomMsg = function() {
    msgs = [
      'Show off your sassy side &amp; help support SassMeister.',
      'Get sweet, sassy stickers &amp; help support SassMeister.'
    ];  
  
    return msgs[Math.floor(Math.random() * msgs.length)];
  };
  
  var stickerMsg = '<a href="http://devswag.com/products/sassmeister-stickers-4">\
\
<h1>Swag Alert! </h1> \
<p><img src="/images/sassmeister-detail-v02_medium.jpg"> ' + randomMsg() + '</p>\
</a>';
  
  
  $('#promo .swag-promo').html(stickerMsg);


  // Messenger({extraClasses: 'messenger-on-bottom swag-promo'}).post({
  //   message: stickerMsg,
  //   hideAfter: 600,
  //   showCloseButton: true
  // });
  
}
})(jQuery);