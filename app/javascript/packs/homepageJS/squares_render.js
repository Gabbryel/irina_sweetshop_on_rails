const squares = document.querySelectorAll('.square');

const addBkgLight = (el) => {
    el.classList.remove('bkg-dark')
    el.classList.add('bkg-light')
}

const addBkgDark = (el) => {
    el.classList.remove('bkg-light')
    el.classList.add('bkg-dark')
}

const squareBkgColor = () => {
    squares.forEach((el, index) => {
        if (window.innerWidth <= 650) {
               if (index === 0 || index === 3 || index === 4) {
                   addBkgLight(el)
               } else {
                   addBkgDark(el)
               }
        } else if (window.innerWidth > 600){
            if (index % 2 === 0) {
                addBkgLight(el)
            } else if (index % 2 === 1) {
                addBkgDark(el)
            }
        }
    })
}

const renderSquares = () => {
    squareBkgColor()
}
const renderSquaresResize = () => {
    window.addEventListener('resize', () => {
        squareBkgColor()
    })
}


export { renderSquares, renderSquaresResize } 



