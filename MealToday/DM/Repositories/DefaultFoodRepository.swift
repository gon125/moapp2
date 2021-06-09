//
//  DefaultFoodRepository.swift
//  MealToday
//
//  Created by Geonhyeong LIm on 2021/05/27.
//

import Combine

struct DefaultFoodRepository: FoodRepository {
    private let dbManager = DBManager()

    func getFood(from selections: Selections) -> AnyPublisher<[Food]?, Never> {

        var query = ""

        for key in selections.filter({ $0.value == true}).keys {
            guard let tableName = key.tableName else { continue }
            query += "SELECT name FROM \(tableName) UNION "
        }

        query.removeLast(7)
        return Just(dbManager.readData(query: query)).eraseToAnyPublisher()
    }
}

extension FoodType {
    var tableName: String? {
        switch self {
        case .friedFood: return "fried"
        case .fastfood: return "fastfood"
        case .noodles: return "noodle"
        case .meat: return "meat"
        case .rice: return "rice"
        case .soup: return "soup"
        case .seafood: return "seafood"
        case .cake: return "cake"
        case .bingsu: return "bingsu"
        case .bread: return "bread"
        case .sweets: return "sweats"
        case .beverage: return "beverage"
        case .icecream: return "icecream"
        default: return nil
        }
    }
}
