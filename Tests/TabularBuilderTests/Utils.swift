//
// Utils.swift
// Created by Xu Yang on 2025-06-04.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import TabularBuilder

struct User: DataFrameConvertible {
    let name: String
    let age: Int
    let role: Role

    static let sample = [
        User(name: "John", age: 20, role: .admin),
        User(name: "Jane", age: 21, role: .user),
        User(name: "Jim", age: 22, role: .admin),
    ]
}

enum Role: String {
    case admin
    case user
}
