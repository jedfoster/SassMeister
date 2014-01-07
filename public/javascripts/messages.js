// Number.isInteger() polyfill
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isInteger#Polyfill
if (!Number.isInteger) {
  Number.isInteger = function isInteger (nVal) {
    return typeof nVal === "number" && isFinite(nVal) && nVal > -9007199254740992 && nVal < 9007199254740992 && Math.floor(nVal) === nVal;
  };
}

Object.size = function(obj) {
  var size = 0, key;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) size++;
  }
  return size;
};

(function($) {
  Messenger.options = {
    theme: 'block',
    messageDefaults: {
      hideAfter: 6,
      showCloseButton: true
    }
  };


  var messageCatalog = {
    'libsass': {
      visit_interval: 20,
      time_interval: 86400 * 1,
      impression_limit: 5,
      content: '<h1>LibSass is here!</h1><p>Click the <span class="control-icon" style="font-size: 0.66em;"><span class="alt">gear</span></span> icon above, and select "LibSass" as the compiler.</p>',
      messengerOptions: {
        extraClasses: 'messenger-on-top',
        postOptions: {hideAfter: 10}
      },
      conditions: function(stats) {
        // If this message has been seen 5 times already, r
        if(stats.messages[name] && stats.messages[name].impression_count == 5) {
          return false;
        }

        return (!window.gist || (window.gist && window.gist.can_update_gist == true));
      }
    },
    'stickers': {
      visit_interval: 30,
      time_interval: 86400 * 7,
      impression_limit: -1,
      content: $('#promo .swag-promo').html(),
      messengerOptions: {
        extraClasses: 'messenger-on-bottom',
        postOptions: {  }
      },
      conditions: function(stats) {
        return true;
      }
    }
  };


  if($('body.about, body.thankyou').length < 1 ) {
    var messageStats = $.extend(true, {
      last_visit: Date.now(),
      visit_number: 0,
      messages: {}
    }, JSON.parse(localStorage.getItem('messageStats')) );


    var messageQueue = {};


    var queueAddMessage = function(name, message) {
      // For now, because Messenger is dumb, I need to ensure only one message is in the queue.
      // This means that only the first qualifying message in the catalog will be displayed.
      // So, the more important message needs to be first in the catalog. Blech.
      if (Object.size(messageQueue) >= 1) {
        return;
      }

      messageQueue[name] = message;

      if (messageStats.messages[name]) {
        $.extend(true, messageStats.messages[name], {
          last_seen: Date.now(),
          visit_number: messageStats.visit_number
        });

        messageStats.messages[name].impression_count++;
      }
      else {
        messageStats.messages[name] = {
          last_seen: Date.now(),
          visit_number: messageStats.visit_number,
          impression_count: 1
        }
      }
    };


    var checkTimeIntervals = function(last_visit, interval) {
      return last_visit < (Date.now() - interval * 1000);
    };

    var checkVisitIntervals = function(visits, interval) {
      return Number.isInteger(visits / interval);
    };

    var checkImpressionLimits = function(stats, name, limit) {
      if (limit == -1) {
        return true;
      }

      return ! (stats.messages[name] && stats.messages[name].impression_count >= limit);
    }


    // loop through messageCatalog and check if it is contained in messageStats.messages
    $.each(messageCatalog, function(name, message) {
      if( (checkTimeIntervals(messageStats.last_visit, message.time_interval) || checkVisitIntervals(messageStats.visit_number, message.visit_interval))

      && checkImpressionLimits(messageStats, name, message.impression_limit)

      && message.conditions(messageStats) ) {
        // display a message
        queueAddMessage(name, message);
      }
    });


    // Clean up stored message info
    if(messageStats.messages) {
      $.each(messageStats.messages, function(messageName) {
        if(! messageCatalog[messageName]) { delete(messageStats.messages[messageName]) }
      });
    }

    messageStats.last_visit = Date.now();
    messageStats.visit_number++;

    localStorage.setItem('messageStats', JSON.stringify( messageStats ));


    // Loop through queued messages and display them.
    // May need a refactor as I've only tested with a single message
    $.each(messageQueue, function(i, message) {
      var postHash = $.extend(true, {message: message.content}, message.messengerOptions.postOptions);

      Messenger({ extraClasses: message.messengerOptions.extraClasses }).post(postHash);
    });
  }
})(jQuery);
