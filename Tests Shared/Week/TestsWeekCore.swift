import Combine
import XCTest
import ComposableArchitecture

@testable import Mes_Superbes_Recettes

class TestsWeekCore: XCTestCase {
    let week = Week(recipes: [Recipe].embedded)
    var store: TestStore<WeekState, WeekState, WeekAction, WeekAction, WeekEnvironment>?

    override func setUp() {
        store = TestStore(
            initialState: WeekState(recipes: .embedded, week: week),
            reducer: weekReducer,
            environment: WeekEnvironment()
        )
    }

    func testMealTimeFilledCount() throws {
        let state = WeekState(recipes: .embedded, week: week)
        // Count the meal you can serve for the week with accumulating meal count of recipes
        XCTAssertEqual(state.mealTimeFilledCount, 5)
    }

    func testMealTimes() throws {
        let state = WeekState(recipes: .embedded, week: week)
        let firstRecipeWith2Meals = [Recipe].embedded[0]
        let secondRecipeWith2Meals = [Recipe].embedded[1]
        let thirdRecipeWith1Meal = [Recipe].embedded[2]
        let expectedMealTimeRecipe = [
            MealTimeRecipe(mealTime: .sundayDinner, recipe: firstRecipeWith2Meals),
            MealTimeRecipe(mealTime: .mondayLunch, recipe: firstRecipeWith2Meals),
            MealTimeRecipe(mealTime: .mondayDinner, recipe: secondRecipeWith2Meals),
            MealTimeRecipe(mealTime: .tuesdayLunch, recipe: secondRecipeWith2Meals),
            MealTimeRecipe(mealTime: .tuesdayDinner, recipe: thirdRecipeWith1Meal),
            MealTimeRecipe(mealTime: .wednesdayLunch, recipe: nil),
            MealTimeRecipe(mealTime: .wednesdayDinner, recipe: nil),
            MealTimeRecipe(mealTime: .thursdayLunch, recipe: nil),
            MealTimeRecipe(mealTime: .thursdayDinner, recipe: nil),
            MealTimeRecipe(mealTime: .fridayLunch, recipe: nil),
            MealTimeRecipe(mealTime: .fridayDinner, recipe: nil),
            MealTimeRecipe(mealTime: .saturdayLunch, recipe: nil),
            MealTimeRecipe(mealTime: .saturdayDinner, recipe: nil),
            MealTimeRecipe(mealTime: .sundayLunch, recipe: nil),
        ]

        XCTAssertEqual(state.mealTimes, expectedMealTimeRecipe)
    }

    func testDisplayedRecipes() throws {
        let firstRecipe = [Recipe].embedded[0]
        let secondRecipe = [Recipe].embedded[1]
        let thirdRecipe = [Recipe].embedded[2]
        let week = Week(recipes: [secondRecipe])
        var state = WeekState(recipes: .embedded, week: week, isRecipeListPresented: true)
        // Recipe in week shall be in top position
        XCTAssertEqual(state.displayedRecipes, [secondRecipe, firstRecipe, thirdRecipe])

        state.isRecipeListPresented = false
        XCTAssertEqual(state.displayedRecipes, [secondRecipe])
    }

    func testAddRecipe() throws {
        let store = try XCTUnwrap(self.store)
        let recipeToAdd = Recipe(
            id: UUID(),
            name: "Test Recipe",
            mealCount: 2,
            ingredients: []
        )

        store.assert(
            .send(.addRecipe(recipeToAdd)) {
                $0.week.recipes = $0.week.recipes + [recipeToAdd]
            }
        )
    }

    func testRemoveRecipe() throws {
        let store = try XCTUnwrap(self.store)
        let recipeToRemove = try XCTUnwrap([Recipe].embedded.first)

        store.assert(
            .send(.removeRecipe(recipeToRemove)) {
                $0.week.recipes = Array([Recipe].embedded.dropFirst())
            }
        )
    }
}
