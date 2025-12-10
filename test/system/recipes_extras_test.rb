require "application_system_test_case"

class RecipesExtrasTest < ApplicationSystemTestCase
  setup do
    @admin = User.create!(email: "admin@example.com", password: "password", admin: true)
    @category = Category.create!(name: "Test Cat", slug: "test-cat")
  end

  test "admin can add extras to a recipe via form" do
    visit new_user_session_path
    fill_in "Email", with: @admin.email
    fill_in "Password", with: "password"
    click_button "Log in"

    visit category_recipes_path(@category)
    # open new recipe modal
    click_on "Rețetă nouă"

    within "#newRecipeModal" do
      fill_in "Numele rețetei", with: "System Test Recipe"
      fill_in "Descrierea rețetei", with: "Test content"
      check "Are extrasuri?"

      # fill first extra row
      within first('.nested-extra-row') do
        fill_in "Nume", with: "Extra A"
        fill_in "Preț (cenți)", with: "150"
      end

      # click add button to ensure new row appears
      click_on "Adaugă extra"

      # fill the newly added last row
      all('.nested-extra-row').last.tap do |row|
        within row do
          fill_in "Nume", with: "Extra B"
          fill_in "Preț (cenți)", with: "250"
        end
      end

      click_button "Adaugă o rețetă"
    end

    recipe = Recipe.find_by(name: "System Test Recipe")
    assert recipe.present?
    assert_equal 2, recipe.extras.count

    # cleanup
    recipe.destroy
  end
end
