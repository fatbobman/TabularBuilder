//
// TabularColumn.swift
// Created by Xu Yang on 2025-06-04.
// Blog: https://fatbobman.com
// GitHub: https://github.com/fatbobman
//
// Copyright © 2025 Fatbobman. All rights reserved.

import Foundation
import TabularData

/// A generic structure that defines a table column corresponding to a specific property of a
/// persistent object.
///
/// `TabularColumn` represents a column in a tabular data structure, mapping values from a source
/// object to a specific output format. It supports various transformation scenarios including
/// simple
/// mapping, conditional mapping, and column creation conditions.
///
/// ## Generic Parameters
///
/// - `ObjectType`: The type of the source object containing the data
/// - `ValueType`: The type of the property being extracted from the object
/// - `OutputType`: The type of the final output after transformation
///
/// ## Usage Examples
///
/// ```swift
/// // Simple column mapping (type transformation)
/// let ageColumn = TabularColumn(
///     name: "Age",
///     keyPath: \.age,
///     mapping: { age in "\(age) years old" }  // Int -> String
/// )
///
/// // Conditional column (advanced mapping with branching)
/// let statusColumn = TabularColumn.conditional(
///     name: "Status",
///     keyPath: \.score,
///     filter: { student in student.score > 60 },
///     then: { score in "Pass: \(score)" },      // score > 60
///     else: { score in "Fail: \(score)" }       // score <= 60
/// )
///
/// // When column (conditional column creation)
/// let premiumColumn = TabularColumn(name: "Premium Features", keyPath: \.features)
///     .when { $0.isPremium }  // Only create this column for premium user groups
/// ```
public struct TabularColumn<ObjectType, ValueType, OutputType> {
    /// The name of the column as it will appear in the table.
    public let name: String

    /// The key path to the property in the source object.
    public let keyPath: KeyPath<ObjectType, ValueType>

    /// The mapping function that transforms the extracted value to the output type.
    ///
    /// This function is responsible for type transformation, converting `ValueType` to
    /// `OutputType`.
    /// Common use cases include formatting numbers to strings, converting raw values to display
    /// text,
    /// or transforming data structures.
    ///
    /// Example: `{ age in "\(age) years old" }` transforms Int to String.
    public let mapping: (ValueType) -> OutputType

    /// Optional conditional mapping function that provides advanced branching logic.
    ///
    /// This is a powerful extension of `mapping` that allows different transformations based on
    /// the entire object's state, not just the target property value. Unlike `mapping` which only
    /// has access to the extracted property value, conditional mapping can examine other properties
    /// of the object to determine how to transform the current value.
    ///
    /// **Key difference from mapping**: `mapping` can only transform based on the property value
    /// itself,
    /// while `conditionalMapping` can make decisions based on the entire object context.
    ///
    /// Example scenarios where `mapping` alone cannot work:
    /// - Display user age differently based on VIP status: VIPs get "25 years (VIP)", others get
    /// "25"
    /// - Show sensitive data based on user permissions: admins see full data, users see masked data
    /// - Format values differently based on object category or type
    ///
    /// The first parameter indicates whether the object passed the filter condition.
    public var conditionalMapping: ((Bool, ValueType) -> OutputType)?

    /// Optional filter function that determines the branch for conditional mapping.
    ///
    /// This function is applied to each object to determine which branch of the
    /// conditional mapping should be used. Works in conjunction with `conditionalMapping`.
    public var filter: ((ObjectType) -> Bool)?

    /// Condition that determines whether this column should be created for a given data group.
    ///
    /// **Important**: Only the first object in the array is checked against this condition.
    /// This design allows the same builder declaration to be applied to different data groups
    /// by pre-categorizing the data. If the condition returns `false`, the column will not be
    /// created.
    ///
    /// Use case: Create different column sets for different user types by grouping users first,
    /// then applying the same builder to each group.
    public var when: (ObjectType) -> Bool

    /// Creates a new TabularColumn with a custom mapping function for type transformation.
    ///
    /// This is the standard initializer that allows for type transformation from `ValueType`
    /// to `OutputType`. The mapping function is responsible for converting the extracted
    /// property value to the desired output format.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to the property in the source object
    ///   - mapping: The type transformation function from ValueType to OutputType
    ///   - when: Optional condition for column creation (defaults to always true)
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, ValueType>,
        mapping: @escaping (ValueType) -> OutputType,
        when: @escaping (ObjectType) -> Bool = { _ in true })
    {
        self.name = name
        self.keyPath = keyPath
        self.mapping = mapping
        conditionalMapping = nil
        filter = nil
        self.when = when
    }

    /// Converts an array of objects to a table column.
    ///
    /// This method extracts values from the provided objects using the configured
    /// key path and applies the appropriate mapping function to create a `Column`.
    ///
    /// - Parameter objects: An array of source objects to extract data from
    /// - Returns: A `Column` containing the transformed values, or `nil` if the column
    ///   should not be created (empty array or `when` condition fails)
    public func makeColumn(objects: [ObjectType]) -> Column<OutputType>? {
        guard !objects.isEmpty, when(objects[0]) else {
            return nil
        }
        let values = objects.map { object in
            let raw = object[keyPath: keyPath]
            if let filter, let conditionalMapping {
                return conditionalMapping(filter(object), raw)
            } else {
                return mapping(raw)
            }
        }
        return Column(name: name, contents: values)
    }

    /// Creates a new TabularColumn without transformation when ValueType equals OutputType.
    ///
    /// This convenience initializer is available when no type transformation is needed,
    /// and the property value can be used directly as the column output.
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to the property in the source object
    public init(
        name: String,
        keyPath: KeyPath<ObjectType, ValueType>) where ValueType == OutputType
    {
        self.init(name: name, keyPath: keyPath, mapping: { $0 })
    }

    /// Creates a TabularColumn with conditional mapping based on a filter function.
    ///
    /// This static method creates a column with context-aware transformation logic that cannot be
    /// achieved with simple `mapping`. It allows the transformation of a property value to depend
    /// on other properties of the same object, enabling complex conditional formatting.
    ///
    /// **When to use conditional over mapping**:
    /// - When the transformation needs to consider other object properties
    /// - When the same property value should be displayed differently based on object state
    /// - When you need access to the entire object context during transformation
    ///
    /// Example: Transform age display based on user type
    /// ```swift
    /// TabularColumn.conditional(
    ///     name: "Age",
    ///     keyPath: \.age,
    ///     filter: { user in user.isVIP },
    ///     then: { age in "\(age) years (VIP)" },    // VIP users get special formatting
    ///     else: { age in "\(age)" }                 // Regular users get simple formatting
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the column
    ///   - keyPath: The key path to the property in the source object
    ///   - filter: The condition function that examines the entire object to determine which
    /// mapping branch to use
    ///   - thenMap: The mapping function used when the filter condition is true
    ///   - elseMap: The mapping function used when the filter condition is false
    ///   - when: Optional condition for column creation (defaults to always true)
    /// - Returns: A new `TabularColumn` with conditional mapping configured
    public static func conditional(
        name: String,
        keyPath: KeyPath<ObjectType, ValueType>,
        filter: @escaping (ObjectType) -> Bool,
        then thenMap: @escaping (ValueType) -> OutputType,
        else elseMap: @escaping (ValueType) -> OutputType,
        when: @escaping (ObjectType) -> Bool = { _ in true }) -> Self
    {
        var col = Self(name: name, keyPath: keyPath, mapping: thenMap, when: when)
        col.conditionalMapping = { passed, raw in
            passed ? thenMap(raw) : elseMap(raw)
        }
        col.filter = filter
        return col
    }

    /// Adds a condition for column creation based on data group characteristics.
    ///
    /// This method returns a new column instance with the specified creation condition.
    /// **Important**: The condition is only evaluated against the first object in the array.
    /// This design enables the same builder declaration to be applied to different pre-categorized
    /// data groups, creating different column sets based on group characteristics.
    ///
    /// Typical workflow:
    /// 1. Categorize your data into groups (e.g., premium users, standard users)
    /// 2. Apply the same builder to each group
    /// 3. Different columns will be created based on the group's first object characteristics
    ///
    /// - Parameter condition: The condition function that determines whether to create the column
    /// - Returns: A new `TabularColumn` instance with the updated creation condition
    public func when(_ condition: @escaping (ObjectType) -> Bool) -> Self {
        var column = self
        column.when = condition
        return column
    }
}
