//
// TabularColumnBuilder.swift
// Created by Xu Yang on 2025-06-04.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation

/// A result builder for constructing TabularColumn collections.
///
/// TabularColumnBuilder provides a DSL (Domain Specific Language) for declaratively
/// building arrays of TabularColumn objects. It supports various input types including
/// individual columns, optional columns, arrays of columns, and conditional expressions.
///
/// Usage example:
/// ```swift
/// @TabularColumnBuilder<MyObject>
/// var columns: [AnyTabularColumn<MyObject>] {
///     TabularColumn("Name", value: \.name)
///     TabularColumn("Age", value: \.age)
///     if showOptionalColumn {
///         TabularColumn("Email", value: \.email)
///     }
/// }
/// ```
@resultBuilder
public enum TabularColumnBuilder<ObjectType> {
    /// Combines multiple component arrays into a single flattened array.
    ///
    /// This method takes variadic parameters where each component is an array of
    /// optional AnyTabularColumn objects and flattens them into a single array.
    ///
    /// - Parameter components: Variable number of arrays containing optional AnyTabularColumn
    /// objects
    /// - Returns: A flattened array of optional AnyTabularColumn objects
    public static func buildBlock(
        _ components: [AnyTabularColumn<ObjectType>]...) -> [AnyTabularColumn<ObjectType>]
    {
        components.flatMap(\.self)
    }

    /// Builds an expression from a single TabularColumn.
    ///
    /// Converts a concrete TabularColumn into an array containing a single AnyTabularColumn.
    /// This allows individual column definitions to be used directly in the builder.
    ///
    /// - Parameter column: A TabularColumn with any Content and SortComparator types
    /// - Returns: An array containing the wrapped column as AnyTabularColumn
    public static func buildExpression(
        _ column: TabularColumn<ObjectType, some Any, some Any>) -> [AnyTabularColumn<ObjectType>]
    {
        [AnyTabularColumn(column)]
    }

    /// Builds an expression from an array of AnyTabularColumn objects.
    ///
    /// Converts an array of AnyTabularColumn objects into the builder's expected format
    /// by wrapping each element in an Optional.
    ///
    /// - Parameter columns: An array of AnyTabularColumn objects
    /// - Returns: An array of optional AnyTabularColumn objects
    public static func buildExpression(
        _ columns: [AnyTabularColumn<ObjectType>]) -> [AnyTabularColumn<ObjectType>]
    {
        columns
    }

    /// Builds an expression from a single AnyTabularColumn.
    ///
    /// Wraps a single AnyTabularColumn in an array for use in the builder context.
    ///
    /// - Parameter any: A single AnyTabularColumn object
    /// - Returns: An array containing the AnyTabularColumn
    public static func buildExpression(
        _ any: AnyTabularColumn<ObjectType>) -> [AnyTabularColumn<ObjectType>]
    {
        [any]
    }

    /// Builds an expression from an optional TabularColumn.
    ///
    /// Handles optional TabularColumn objects by converting them to AnyTabularColumn
    /// if they exist, or nil if they don't.
    ///
    /// - Parameter column: An optional TabularColumn with any Content and SortComparator types
    /// - Returns: An array containing the wrapped column or nil
    public static func buildExpression(
        _ column: TabularColumn<ObjectType, some Any, some Any>?) -> [AnyTabularColumn<ObjectType>]
    {
        column.map { [AnyTabularColumn($0)] } ?? []
    }

    /// Handles optional components for conditional expressions.
    ///
    /// Used when an `if` statement without an `else` clause is present in the builder.
    /// Returns an empty array if the component is nil, or the component itself if it exists.
    ///
    /// - Parameter component: An optional array of AnyTabularColumn objects
    /// - Returns: The component array or an empty array if nil
    public static func buildOptional(
        _ component: [AnyTabularColumn<ObjectType>]?) -> [AnyTabularColumn<ObjectType>]
    {
        component ?? []
    }

    /// Handles the first branch of an if-else statement.
    ///
    /// Used in conditional expressions where both `if` and `else` branches are present.
    /// This method handles the `if` branch.
    ///
    /// - Parameter component: The array from the first (if) branch
    /// - Returns: The component array unchanged
    public static func buildEither(first component: [AnyTabularColumn<ObjectType>])
    -> [AnyTabularColumn<ObjectType>] {
        component
    }

    /// Handles the second branch of an if-else statement.
    ///
    /// Used in conditional expressions where both `if` and `else` branches are present.
    /// This method handles the `else` branch.
    ///
    /// - Parameter component: The array from the second (else) branch
    /// - Returns: The component array unchanged
    public static func buildEither(second component: [AnyTabularColumn<ObjectType>])
    -> [AnyTabularColumn<ObjectType>] {
        component
    }

    /// Builds an array from a collection of components (for `for-in` loops).
    ///
    /// - Parameter components: An array of arrays containing AnyTabularColumn objects
    /// - Returns: A flattened array of AnyTabularColumn objects
    public static func buildArray(
        _ components: [[AnyTabularColumn<ObjectType>]]) -> [AnyTabularColumn<ObjectType>]
    {
        components.flatMap(\.self)
    }

    /// Handles limited availability checks (#available).
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func buildLimitedAvailability(
        _ component: [AnyTabularColumn<ObjectType>]) -> [AnyTabularColumn<ObjectType>]
    {
        component
    }
}
