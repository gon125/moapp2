//
//  Selection.swift
//  MealToday
//
//  Created by Geonhyeong LIm on 2021/05/18.
//
import Combine

protocol SelectionUseCase: UseCase {
    mutating func getFoodFromSelection() -> AnyPublisher<Food?, Never>
    mutating func addChoice(for foodType: FoodType, isChosen: Bool)
    mutating func getNextQuery() -> AnyPublisher<FoodType?, Never>
    mutating func setSelections(with selections: Selections)
}

#if DEBUG
struct StubSelectionUseCase: SelectionUseCase {

    private var selections = Selections()
    private var queries: [FoodType] = [.dessertOrMeal]

    mutating func setSelections(with selections: Selections) {
        self.selections = selections
    }

    mutating func addChoice(for foodType: FoodType, isChosen: Bool) {
        if foodType == .dessertOrMeal {
            queries += isChosen ? FoodType.dessert : FoodType.meal
        }
        selections[foodType] = isChosen
    }

    mutating func getNextQuery() -> AnyPublisher<FoodType?, Never> {
        guard let query = queries.popLast() else { return Just(nil).eraseToAnyPublisher() }
        return Just(query).eraseToAnyPublisher()
    }

    var foods: [Food]? = Food.randomFoods

    mutating func getFoodFromSelection() -> AnyPublisher<Food?, Never> { Just(foods?.popLast()).eraseToAnyPublisher() }

}
#endif

typealias DefaultSelectionUseCase = FoodSelectionUseCase

class FoodSelectionUseCase: SelectionUseCase {

    private var selections = Selections()
    private var queries: [FoodType] = [.dessertOrMeal]
    private let repository: FoodRepository
    var foods: LoopIterator<Food>?
    var selectedFoodIndex = 0

    init(repository: FoodRepository) {
        self.repository = repository
    }

    func getFoodFromSelection() -> AnyPublisher<Food?, Never> {
        if foods != nil { return Just(foods!.next()).eraseToAnyPublisher() }
        return repository.getFood(from: selections).map { [weak self] in
            self?.foods = $0?.shuffled().makeIterator()
            return self?.foods?.next()
        }
        .eraseToAnyPublisher()
    }

    func addChoice(for foodType: FoodType, isChosen: Bool) {
        if foodType == .dessertOrMeal {
            queries += isChosen ? FoodType.dessert : FoodType.meal
        } else {
            selections[foodType] = isChosen
        }
    }

    func getNextQuery() -> AnyPublisher<FoodType?, Never> {
        guard let query = queries.popLast() else { return Just(nil).eraseToAnyPublisher() }
        return Just(query).eraseToAnyPublisher()
    }

    func setSelections(with selections: Selections) {
        self.selections = selections
    }
}

struct LoopIterator<T>: IteratorProtocol {
    private var elements: [T]
    private var index = 0

    init(_ elements: [T]) {
        self.elements = elements
    }

    mutating func next() -> T? {
        guard !elements.isEmpty else { return nil }
        index = (index + 1) % elements.count
        return elements[index]
    }
}

extension Array where Element == Food {
    fileprivate func makeIterator() -> LoopIterator<Food> {
        LoopIterator(self)
    }
}
