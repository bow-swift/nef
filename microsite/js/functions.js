// This initialization requires that this script is loaded with `defer`
const navElement = document.querySelector("#site-nav");

// Navigation element modification through scrolling
function scrollFunction() {
  if (document.documentElement.scrollTop > 0) {
    navElement.classList.add("nav-scroll");
  } else {
    navElement.classList.remove("nav-scroll");
  }
}

// Init call
function loadEvent() {
  document.addEventListener("scroll", scrollFunction);
}

// Attach the functions to each event they are interested in
window.addEventListener("load", loadEvent);


function w3_open() {
    "use strict";
    document.getElementById("sidebar").style.display = "block";
}
function w3_close() {
    "use strict";
    document.getElementById("sidebar").style.display = "none";
}
