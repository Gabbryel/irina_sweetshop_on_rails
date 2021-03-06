const cards = Array.from(document.getElementsByClassName('card-container'));
const links = Array.from(document.getElementsByClassName('card-paths'));
const titles = Array.from(document.getElementsByClassName('card-title'));

const showLinks = () => {
    cards.map((card, index) => {
        const title = titles[index].textContent
        console.log(title)
        card.addEventListener('click', () => {
            if (links[index].classList.contains('hidden')) {
                links[index].classList.remove('hidden');
                titles[index].textContent = '';
            } else {
                links[index].classList.add('hidden');
                titles[index].textContent = title;
            }
        })
    })
}

export {showLinks}