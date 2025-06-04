//
// DataFrameConvertible.swift
// Created by Xu Yang on 2025-06-04.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import TabularData

/// A protocol for converting arrays of objects into TabularData DataFrame structures.
///
/// `DataFrameConvertible` provides a standardized interface for transforming collections
/// of objects (such as NSManagedObject subclasses) into structured tabular data that can
/// be used with Swift's TabularData framework. This protocol enables seamless integration
/// between custom data models and tabular data processing workflows.
///
/// The protocol supports two conversion approaches:
/// - Direct conversion using pre-built column arrays
/// - Declarative conversion using result builder syntax
///
/// ## Usage Examples
///
/// ```swift
/// struct Person: DataFrameConvertible {
///     let name: String
///     let age: Int
///     let isActive: Bool
/// }
///
/// let people = [
///     Person(name: "Alice", age: 30, isActive: true),
///     Person(name: "Bob", age: 25, isActive: false)
/// ]
///
/// // Using result builder syntax
/// let dataFrame = Person.makeDataFrame(objects: people) {
///     TabularColumn(name: "Name", keyPath: \.name)
///     TabularColumn(name: "Age", keyPath: \.age)
///     if includeStatus {
///         TabularColumn(name: "Status", keyPath: \.isActive, mapping: { $0 ? "Active" : "Inactive"
/// })
///     }
/// }
/// ```
public protocol DataFrameConvertible {
    /// Converts an array of objects to a DataFrame using pre-built column definitions.
    ///
    /// This method provides the foundation for DataFrame conversion by taking an array
    /// of optional `AnyTabularColumn` objects and creating a corresponding `DataFrame`.
    /// Non-nil columns that successfully generate data will be included in the result.
    ///
    /// - Parameters:
    ///   - objects: The array of objects to be converted to tabular data
    ///   - anyColumns: An array of optional `AnyTabularColumn` instances defining the columns to
    /// include
    /// - Returns: A `DataFrame` containing the converted tabular data
    static func makeDataFrame(objects: [Self], anyColumns: [AnyTabularColumn<Self>?]) -> DataFrame

    /// Converts an array of objects to a DataFrame using result builder syntax.
    ///
    /// This method provides a declarative approach to DataFrame creation using the
    /// `@TabularColumnBuilder` result builder. It enables clean, readable column
    /// definitions with support for conditional logic and complex transformations.
    ///
    /// - Parameters:
    ///   - objects: The array of objects to be converted to tabular data
    ///   - columns: A closure that uses `@TabularColumnBuilder` to define the columns
    /// - Returns: A `DataFrame` containing the converted tabular data
    static func makeDataFrame(
        objects: [Self],
        @TabularColumnBuilder<Self> _ columns: () -> [AnyTabularColumn<Self>?]) -> DataFrame
}

extension DataFrameConvertible {
    /// Default implementation for converting objects to DataFrame using column arrays.
    ///
    /// This implementation processes the provided column definitions by:
    /// 1. Filtering out nil columns using `compactMap`
    /// 2. Calling `makeColumn(objects:)` on each valid column
    /// 3. Creating a `DataFrame` from the resulting columns
    ///
    /// Only columns that successfully generate data (return non-nil from `makeColumn`)
    /// will be included in the final DataFrame.
    ///
    /// - Parameters:
    ///   - objects: The array of objects to be converted to tabular data
    ///   - anyColumns: An array of optional `AnyTabularColumn` instances defining the columns
    /// - Returns: A `DataFrame` containing the converted tabular data
    public static func makeDataFrame(
        objects: [Self],
        anyColumns: [AnyTabularColumn<Self>?]) -> DataFrame
    {
        let columns = anyColumns.compactMap { $0?.makeColumn(objects: objects) }
        return DataFrame(columns: columns)
    }

    /// Default implementation for converting objects to DataFrame using result builder syntax.
    ///
    /// This implementation leverages the array-based `makeDataFrame` method to avoid
    /// code duplication. It evaluates the result builder closure to produce an array
    /// of column definitions, then delegates to the primary conversion method.
    ///
    /// This approach ensures consistent behavior between both conversion methods while
    /// maintaining clean separation of concerns.
    ///
    /// - Parameters:
    ///   - objects: The array of objects to be converted to tabular data
    ///   - columns: A closure that uses `@TabularColumnBuilder` to define the columns
    /// - Returns: A `DataFrame` containing the converted tabular data
    public static func makeDataFrame(
        objects: [Self],
        @TabularColumnBuilder<Self> _ columns: () -> [AnyTabularColumn<Self>?]) -> DataFrame
    {
        // Delegate to the array-based implementation to avoid duplicating business logic
        makeDataFrame(objects: objects, anyColumns: columns())
    }
}
