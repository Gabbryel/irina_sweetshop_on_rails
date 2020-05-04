function animateCard() {
  let cardContainers = document.querySelectorAll('.card-container');

  const mouseEnterFunc = () => {
      cardContainers.forEach( (elem) => {
        elem.addEventListener('mouseover', () => {
          elem.classList.add('animated')
          elem.classList.add('pulse')
        })
      })
    }

  const mouseOutFunc = () => {
    cardContainers.forEach( (elem) => {
      elem.addEventListener('mouseleave', () => {
        elem.classList.remove('animated')
        elem.classList.remove('pulse')
      })
    })
  }



 


  if (cardContainers) {
    mouseEnterFunc()
    mouseOutFunc()
  }

}

export { animateCard }