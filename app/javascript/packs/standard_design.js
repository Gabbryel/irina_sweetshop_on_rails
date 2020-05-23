function showStandardDesign() {
  let standard = document.querySelector('.standard')
  let standardDesign = document.querySelector('.standard-design')
  
  if (standard) {
    standard.addEventListener('mouseover', () => {
      standardDesign.style.display = 'block'
    })
  }
  if (standard) {
    standard.addEventListener('mouseout', () => {
      standardDesign.style.display = 'none'
    })
  }
}

export { showStandardDesign };