/**
 * Toggle an specific class to the received DOM element.
 * @param {string}	elemSelector The query selector specifying the target element.
 * @param {string}	[activeClass='active'] The class to be applied/removed.
 */
function toggleClass(elemSelector, activeClass = 'active') {
	const elem = document.querySelector(elemSelector);
  if (elem) {
    elem.classList.toggle(activeClass);
  }
}

/**
 * Toggle specific classes to an array of corresponding DOM elements.
 * @param {Array<string>}	elemSelectors The query selectors specifying the target elements.
 * @param {Array<string>}	activeClasses The classes to be applied/removed.
 */
function toggleClasses(elemSelectors, activeClasses) {
  elemSelectors.map((elemSelector, idx) => {
		toggleClass(elemSelector, activeClasses[idx]);
	});
}

/**
 * Remove active class from siblings DOM elements and apply it to event target.
 * @param {Element}		element The element receiving the class, and whose siblings will lose it.
 * @param {string}		[activeClass='active'] The class to be applied.
 */
function activate(element, activeClass = 'active') {
	[...element.parentNode.children].map((elem) => elem.classList.remove(activeClass));
	element.classList.add(activeClass);
}

/**
 * Remove active class from siblings parent DOM elements and apply it to element target parent.
 * @param {Element}		element The element receiving the class, and whose siblings will lose it.
 * @param {string}		[activeClass='active'] The class to be applied.
 */
function activateParent(element, activeClass = 'active') {
	const elemParent = element.parentNode;
	activate(elemParent, activeClass);
}
