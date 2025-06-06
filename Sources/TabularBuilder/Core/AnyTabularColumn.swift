//
// AnyTabularColumn.swift
// Created by Xu Yang on 2025-06-04.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import TabularData

/// A type-erased wrapper for TabularColumn instances.
///
/// `AnyTabularColumn` provides type erasure for `TabularColumn` objects, allowing them to be
/// stored in homogeneous collections regardless of their specific content and sort comparator
/// types.
/// This is particularly useful when building arrays of columns with different types but the same
/// object type.
///
/// The type erasure is achieved by storing a closure that can create an `AnyColumn` from an array
/// of objects, hiding the specific generic parameters of the original `TabularColumn`.
///
/// ## Usage
///
/// ```swift
/// let nameColumn = TabularColumn("Name", value: \.name)
/// let ageColumn = TabularColumn("Age", value: \.age)
///
/// // These can now be stored in the same array
/// let columns: [AnyTabularColumn<Person>] = [
///     AnyTabularColumn(nameColumn),
///     AnyTabularColumn(ageColumn)
/// ]
/// ```
public struct AnyTabularColumn<ObjectType> {
    /// The closure used to create a type-erased column from an array of objects.
    ///
    /// This closure encapsulates the column creation logic while hiding the specific
    /// generic types of the original `TabularColumn`.
    private let _make: ([ObjectType]) -> AnyColumn?

    /// The closure used to determine if the column should be created for a given object.
    private let _when: (ObjectType) -> Bool

    /// Creates a new `AnyTabularColumn` instance by wrapping a `TabularColumn`.
    ///
    /// This initializer performs type erasure on the provided `TabularColumn`,
    /// allowing it to be used in contexts where the specific content and sort
    /// comparator types are not known at compile time.
    ///
    /// - Parameter column: The `TabularColumn` instance to be type-erased.
    ///   Can have any content and sort comparator types as long as they work with `ObjectType`.
    public init(
        _ column: TabularColumn<ObjectType, some Any, some Any>)
    {
        _make = { objects in
            guard let column = column.makeColumn(objects: objects) else {
                return nil
            }
            return column.eraseToAnyColumn()
        }

        _when = column.when
    }

    /// Creates a type-erased column from an array of objects.
    ///
    /// This method calls the underlying wrapped `TabularColumn`'s `makeColumn` method
    /// and returns the result as an `AnyColumn`, providing a uniform interface
    /// regardless of the original column's specific types.
    ///
    /// - Parameter objects: An array of objects of type `ObjectType` used to populate the column.
    /// - Returns: An optional `AnyColumn` containing the column data, or `nil` if column creation
    /// fails.
    public func makeColumn(objects: [ObjectType]) -> AnyColumn? {
        _make(objects)
    }

    /// Determines if the column should be created for a given object.
    ///
    /// - Parameter object: The object to check.
    /// - Returns: `true` if the column should be created, `false` otherwise.
    public func shouldCreate(object: ObjectType) -> Bool {
        _when(object)
    }
}
