function sections () {

  let recipeButton = document.querySelector('.section-btn-recipe')
  let modelButton = document.querySelector('.section-btn-model')

  let recipesIndex = document.querySelector('.category-recipes-index')
  let modelsIndex = document.querySelector('.category-models-index')

  const activateRecipesSection = () => {
    recipesIndex.classList.remove('inactive-section-index')
    recipesIndex.classList.add('active-section-index')
    recipeButton.classList.remove('inactive-section-btn')
    recipeButton.classList.add('active-section-btn')
  }

  const inactivateRecipesSection = () => {
    recipesIndex.classList.remove('active-section-index')
    recipesIndex.classList.add('inactive-section-index')
    recipeButton.classList.add('inactive-section-btn')
    recipeButton.classList.remove('active-section-btn')
  }

  const activateModelsSections = () => {
    modelsIndex.classList.remove('inactive-section-index')
    modelsIndex.classList.add('.active-section-index')
    modelButton.classList.remove('inactive-section-btn')
    modelButton.classList.add('active-section-btn')
  }

  const inactivateModelsSections = () => {
    modelsIndex.classList.add('inactive-section-index')
    modelsIndex.classList.remove('active-section-index')
    modelButton.classList.add('inactive-section-btn')
    modelButton.classList.remove('active-section-btn')
  }

  if (recipeButton) {
    recipeButton.addEventListener('click', () => {
      activateRecipesSection()
      inactivateModelsSections()
    })
  }
  if (modelButton) {
    modelButton.addEventListener('click', () => {
      activateModelsSections()
      inactivateRecipesSection()
    })
  }
  
}

export { sections }