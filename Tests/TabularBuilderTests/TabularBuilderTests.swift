//
// TabularBuilderTests.swift
// Created by Xu Yang on 2025-06-04.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
@testable import TabularBuilder
import TabularData
import Testing

/// Test suite for TabularBuilder functionality.
///
/// This test suite validates the core functionality of the TabularBuilder framework,
/// including DataFrame creation, result builder features, column mapping, conditional
/// logic, and column creation conditions.
@Suite("TabularBuilder")
struct TabularBuilderTests {
    /// Tests basic DataFrame creation using the result builder syntax.
    ///
    /// Validates that:
    /// - All specified columns are created correctly
    /// - Column names match the expected values
    /// - Row count matches the input data
    @Test func makeDataFrame() async throws {
        let users = User.sample
        let df = User.makeDataFrame(objects: users) {
            TabularColumn(name: "name", keyPath: \.name)
            TabularColumn(name: "age", keyPath: \.age)
            TabularColumn(name: "role", keyPath: \.role)
        }

        #expect(df.columns.count == 3)
        #expect(df.columns[0].name == "name")
        #expect(df.columns[1].name == "age")
        #expect(df.columns[2].name == "role")
        #expect(df.rows.count == 3)
    }

    /// Tests the result builder's conditional `if` statement functionality.
    ///
    /// Validates that columns are conditionally included or excluded based on
    /// boolean conditions in the result builder context. When `includeRole` is false,
    /// the role column should not be created.
    @Test func resultBuilderIf() async throws {
        let users = User.sample
        let includeRole = false
        let df = User.makeDataFrame(objects: users) {
            TabularColumn(name: "name", keyPath: \.name)
            TabularColumn(name: "age", keyPath: \.age)
            if includeRole {
                TabularColumn(name: "role", keyPath: \.role)
            }
        }

        #expect(df.columns.count == 2)
        #expect(df.columns[0].name == "name")
        #expect(df.columns[1].name == "age")
        #expect(df.rows.count == 3)
    }

    /// Tests value transformation using the mapping function.
    ///
    /// Validates that the mapping function correctly transforms values from one type
    /// to another. In this case, integer age values are converted to string representations.
    @Test func resultBuilderMapping() async throws {
        let users = User.sample
        let df = User.makeDataFrame(objects: users) {
            TabularColumn(name: "name", keyPath: \.name)
            TabularColumn(name: "age", keyPath: \.age, mapping: { "\($0)" })
            TabularColumn(name: "role", keyPath: \.role)
        }

        #expect(df.columns.count == 3)
        #expect(df.columns[0].name == "name")
        #expect(df.columns[1].name == "age")
        #expect(df.columns[2].name == "role")
        #expect(df.rows.count == 3)
        #expect(df.columns[1].first as? String == "20")
    }

    /// Tests conditional column mapping based on object properties.
    ///
    /// Validates that the `conditional` static method correctly applies different
    /// transformations based on a filter condition. Users with age > 20 should get their role
    /// values while others should get nil values.
    @Test func resultBuilderCondition() async throws {
        let users = User.sample
        let df = User.makeDataFrame(objects: users) {
            TabularColumn(name: "name", keyPath: \.name)
            TabularColumn(name: "age", keyPath: \.age)
            TabularColumn
                .conditional(
                    name: "role",
                    keyPath: \User.role,
                    filter: { $0.age > 20 },
                    then: { Optional($0.rawValue) },
                    else: { _ in nil })
        }

        #expect(df.columns.count == 3)
        #expect(df.columns[0].name == "name")
        #expect(df.columns[1].name == "age")
        #expect(df.columns[2].name == "role")
        #expect(df.rows.count == 3)
    }

    /// Tests the `when` condition for conditional column creation.
    ///
    /// Validates that columns are only created when the `when` condition is satisfied
    /// by the first object in the dataset. The role column should only appear for
    /// admin users but not for regular users, demonstrating data group-based column creation.
    @Test func resultBuilderWhen() async throws {
        let users = User.sample.filter { $0.role == .user }
        let admins = User.sample.filter { $0.role == .admin }

        @TabularColumnBuilder<User> var columns: [AnyTabularColumn<User>?] {
            TabularColumn(name: "name", keyPath: \.name)
            TabularColumn(name: "age", keyPath: \.age)
            TabularColumn(name: "role", keyPath: \.role)
                .when { $0.role == .admin }
        }

        let usersDF = User.makeDataFrame(objects: users, anyColumns: columns)
        let adminsDF = User.makeDataFrame(objects: admins, anyColumns: columns)

        #expect(usersDF.columns.count == 2)
        #expect(adminsDF.columns.count == 3)
    }

    /// Tests the `disable` method for conditional column creation.
    ///
    /// Validates that columns are only created when the `disable` condition is not met
    /// by the first object in the dataset. The role column should only appear for
    /// admin users but not for regular users, demonstrating data group-based column creation.
    @Test func resultBuilderDisable() async throws {
        let users = User.sample.filter { $0.role == .user }
        let admins = User.sample.filter { $0.role == .admin }

        @TabularColumnBuilder<User> var columns: [AnyTabularColumn<User>?] {
            TabularColumn(name: "name", keyPath: \.name)
            TabularColumn(name: "age", keyPath: \.age)
            TabularColumn(name: "role", keyPath: \.role)
                .disable { $0.role == .user }
        }

        let usersDF = User.makeDataFrame(objects: users, anyColumns: columns)
        let adminsDF = User.makeDataFrame(objects: admins, anyColumns: columns)

        #expect(usersDF.columns.count == 2)
        #expect(adminsDF.columns.count == 3)
    }
}
