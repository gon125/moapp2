//
//  AppState.swift
//  MealToday
//
//  Created by Geonhyeong LIm on 2021/05/19.
//
import Combine

final class AppState: ObservableObject {
    var viewRouting: ViewRouting = .shortcut
}

enum ViewRouting {
    case shortcut
    case selecting
    case selectionFinished
    case resultView
}