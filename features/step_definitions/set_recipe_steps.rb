Given /^I have defined a SetRecipe$/ do
  recipe = SetRecipe.create(:name => 'recipe_1', :desc => 'the first data set recipe record')
end

Then /^I should see a list of all data set recipes$/ do
  response_body.should include('Recipes')
end


