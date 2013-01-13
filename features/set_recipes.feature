Feature: SetRecipe stuff

  Scenario: List SetRecipes
    Given I have defined a SetRecipe
    Given I am viewing "/setup/"
    Then I should see "Set Recipes"
    
