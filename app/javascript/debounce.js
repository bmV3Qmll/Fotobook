var csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

function debounce(func, wait, immediate) {
  var timeout;
  return function() {
    var context = this, args = arguments;
    var later = function() {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };
    var callNow = immediate && !timeout;
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
    if (callNow) func.apply(context, args);
  };
};

// state: false - unfollow, true - follow
var toggleFollow = (e) => {
  const btn = e.target;
  const tid = btn.getAttribute('data');
  const isActive = btn.getAttribute('aria-pressed') === 'true';

  fetch('/follow', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken
    },
    body: JSON.stringify({
      tid: tid,
      state: isActive
    })
  })
  .catch(error => console.error('Error:', error));
};

// state: false - unlike, true - like
var toggleLike = (e) => {
  const btn = e.target.closest('.btn-like');
  const pid = btn.getAttribute('data');
  const isActive = btn.getAttribute('aria-pressed') === 'true';

  fetch('/like', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken
    },
    body: JSON.stringify({
      pid: pid,
      state: isActive
    })
  })
  .then(response => response.text())
  .then(data => {
    if (data == '1') {
      const icon = btn.firstElementChild;
      let curr = parseInt(icon.textContent, 10);
      if (isActive) {
        icon.textContent = curr + 1;
      } else {
        icon.textContent = curr - 1;
      }
    }
  })
  .catch(error => console.error('Error:', error));
};

var handleFollow = debounce(toggleFollow, 500);
var handleLike = debounce(toggleLike, 500);