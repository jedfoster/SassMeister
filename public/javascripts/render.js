var style = document.querySelector('style');

var domLoaded = false;

document.addEventListener('DOMContentLoaded', function() {
	domLoaded = true;

	var stored = JSON.parse(localStorage.getItem('outputs'));

	style.textContent = stored.css;
	document.body.innerHTML = stored.html;
});

onmessage = function(event) {
	if (true) {
		var info = JSON.parse(event.data);

    if(info.css) {
      style.textContent = info.css;
    }

    if(info.html) {
      document.body.innerHTML = info.html;
    }
	}
};