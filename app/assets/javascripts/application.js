const makeEl = function(html) {
    const template = document.createElement('template');

    template.innerHTML = html.trim();

    return template.content.firstChild;
};

function addTag(element, tag) {
    const existingElements = element.value.split(',').filter(n => n);

    if (existingElements.indexOf(tag) === -1) {
        existingElements.push(tag);
        element.value = existingElements.join(',');
    }
}

function removeTag(element, tag) {
    const existingElements = element.value.split(',').filter(n => n);
    const index = existingElements.indexOf(tag);

    if (index !== -1) {
        existingElements.splice(index, 1);
        element.value = existingElements.join(',');
    }
}

function makeTagElement(hiddenInput, visualInput, tagName, excluded) {
    // Set up the tag element
    const tagEl = makeEl(`<div class="${excluded ? 'excluded' : ''}"><span>${tagName}</span></div>`);
    tagEl.firstChild.addEventListener('click', function(e) {
        if (tagEl.classList.contains('excluded')) {
            removeTag(hiddenInput, '-' + tagName);
            addTag(hiddenInput, tagName);
            tagEl.classList.remove('excluded');
        } else {
            removeTag(hiddenInput, tagName);
            addTag(hiddenInput, '-' + tagName);
            tagEl.classList.add('excluded');
        }
    });

    // Set up the child "X" button
    const removeEl = makeEl('<a class="remove" />');
    removeEl.addEventListener('click', function(e) {
        removeTag(hiddenInput, tagEl.classList.contains('excluded') ? '-' + tagName : tagName);
        visualInput.removeChild(tagEl);
    });

    tagEl.appendChild(removeEl);

    return tagEl;
}

function setupFancyTagEditor(rootElement) {
    rootElement.classList.remove('hidden');

    const selectDropdown = rootElement.querySelector('select');
    const hiddenInput = rootElement.querySelector('input[type=text]');
    const visualInput = rootElement.querySelector('.selected-tags');

    if (!selectDropdown || !hiddenInput || !visualInput) {
        console.log('Nothing there!');
        return;
    }

    hiddenInput.setAttribute('type', 'hidden');

    // Load existing tags from the input field as visual tag elements
    for (const tag of hiddenInput.value.split(',').filter(n => n)) {
        let tagElement;
        if (tag[0] === '-') {
            tagElement = makeTagElement(hiddenInput, visualInput, tag.substring(1), true);
        } else {
            tagElement = makeTagElement(hiddenInput, visualInput, tag, false);
        }

        visualInput.appendChild(tagElement);
    }

    selectDropdown.addEventListener('change', function(e) {
        const tagName = selectDropdown.value;
        addTag(hiddenInput, tagName);
        visualInput.appendChild(makeTagElement(hiddenInput, visualInput, tagName, false));
    });
}

function whenReady() {
    for (const element of document.querySelectorAll('.js-tag-editor')) {
        setupFancyTagEditor(element);
    }
}

if (document.readyState !== 'loading') {
    whenReady();
} else {
    document.addEventListener('DOMContentLoaded', whenReady);
}
