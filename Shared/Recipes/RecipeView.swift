import ComposableArchitecture
import SwiftUI

struct RecipeView: View {
    let store: Store<RecipeState, RecipeAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section(header: Text("Title")) {
                    TextField("Name", text: viewStore.binding(get: { $0.name }, send: RecipeAction.nameChanged))
                        .font(.title)
                }

                VStack(alignment: .leading) {
                    Stepper("Meal count: \(viewStore.mealCount)", value: viewStore.binding(get: { $0.mealCount }, send: RecipeAction.mealCountChanged), in: 0...99)
                }

                Section(header: Text("Ingredients")) {
                    Button(action: { viewStore.send(.addIngredientButtonTapped) }) {
                        Label("New ingredient", systemImage: "plus")
                    }
                }

                ForEachStore(store.scope(state: { $0.ingredientsStates }, action: RecipeAction.ingredient(id:action:)), content: ingredientRow)
                    .onDelete { viewStore.send(.ingredientsDeleted($0)) }
            }
        }
    }

    private func ingredientRow(store: Store<IngredientState, IngredientAction>) -> some View {
        WithViewStore(store) { viewStore in
            HStack {
                TextField("Name", text: viewStore.binding(get: { $0.name }, send: IngredientAction.nameChanged))
                    .font(.title2)
                TextField("Quantity", text: viewStore.binding(get: { $0.quantity.text }, send: IngredientAction.quantityChanged))
//                    .keyboardType(.decimalPad)
                Button { } label: {
                    Text(viewStore.unit?.symbol ?? "-")
                }
                .onTapGesture { viewStore.send(.unitButtonTapped, animation: .default) }
            }
            if viewStore.isUnitInEditionMode {
                Picker("Unit", selection: viewStore.binding(get: { $0.unit }, send: IngredientAction.unitChanged)) {
                    ForEach(RecipeUnit.allCases) { unit in
                        Text(unit.text).tag(unit.rawValue)
                    }
                }
                .pickerStyle(pickerStyle)
            }
        }
    }

    private var pickerStyle: some PickerStyle {
        #if os(iOS)
        return WheelPickerStyle()
        #else
        return DefaultPickerStyle()
        #endif
    }
}

private extension Double {
    var text: String { numberFormatterDecimal.string(from: NSNumber(value: self)) ?? "Error" }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(store: Store(
            initialState: RecipeState(
                recipe: Recipe(
                    id: UUID(),
                    name: "Preview recipe",
                    mealCount: 1,
                    ingredients: [
                        Ingredient(id: UUID(), name: "Water", quantity: 100, unit: UnitVolume.centiliters),
                        Ingredient(id: UUID(), name: "Chocolate", quantity: 200, unit: UnitMass.grams),
                    ]
                )
            ),
            reducer: recipeReducer,
            environment: RecipeEnvironment(uuid: { UUID() })
        ))
    }
}
