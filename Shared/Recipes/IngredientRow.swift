import ComposableArchitecture
import SwiftUI

struct IngredientRow: View {
    let store: Store<Ingredient, IngredientAction>

    var body: some View {
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
