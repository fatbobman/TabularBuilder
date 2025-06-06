# ``TabularBuilder``

Declarative TabularData creation for Swift

## Overview

TabularBuilder is a Swift library that provides a declarative, type-safe approach to converting any object arrays into TabularData DataFrames. It enables seamless data export and analysis by bridging the gap between object-oriented data models and columnar data structures.

The library showcases Swift's modern language features including generics, KeyPath, type erasure, protocol extensions, and Result Builders to create an elegant solution that is both powerful and easy to use.

### When to Use TabularBuilder

TabularBuilder was created to solve the challenge of converting object collections (like Core Data entities) into structured tabular formats for:

- **Data Export**: Easily save data as JSON/CSV files for sharing or archival
- **Data Analysis**: Leverage TabularData's powerful APIs for filtering, aggregation, and statistical operations

While this seems straightforward—converting "row-oriented" data structures to "column-oriented" ones—the reality becomes complex when dealing with dozens of different entity types. TabularBuilder provides a **universal, type-safe, and declarative** approach to DataFrame conversion.

> For a detailed exploration of the design philosophy and Swift features that make this library possible, read the full article: [Experience the Charm of Swift: One-Click DataFrame Export](https://fatbobman.com/en/posts/experience-the-charm-of-swift-one-click-export-dataframe/)

## Key Features

- **Universal Object Conversion**: Convert any object arrays (Core Data entities, structs, classes) to TabularData DataFrames
- **Declarative Column Definition**: Use SwiftUI-like syntax to define columns with `@TabularColumnBuilder`
- **Type-Safe Transformations**: Leverage Swift's type system for safe data mapping and transformation
- **Conditional Logic**: Support for conditional column creation and conditional value mapping
- **Custom Column Ordering**: Precise control over column order and naming
- **Value Mapping**: Transform values using custom mapping functions before export
- **Non-Intrusive**: Add DataFrame conversion capability to existing types without modification

## Quick Start

### 1. Make Your Type DataFrame-Convertible

```swift
import TabularBuilder

struct Student: DataFrameConvertible {
    let name: String
    let age: Int
    let score: Double
    let isActive: Bool
}
```

### 2. Define Columns and Convert

```swift
let students = [
    Student(name: "Alice", age: 20, score: 95.5, isActive: true),
    Student(name: "Bob", age: 22, score: 87.0, isActive: false)
]

let dataFrame = Student.makeDataFrame(objects: students) {
    TabularColumn(name: "Name", keyPath: \.name)
    TabularColumn(name: "Age", keyPath: \.age)
    TabularColumn(name: "Score", keyPath: \.score, mapping: { "\($0)%" })
    TabularColumn(name: "Status", keyPath: \.isActive, mapping: { $0 ? "Active" : "Inactive" })
}

// Export to CSV
try dataFrame.writeCSV(to: URL(fileURLWithPath: "students.csv"))
```

## Advanced Features

### Custom Value Mapping

Transform values during column creation:

```swift
TabularColumn(name: "Grade", keyPath: \.score, mapping: { score in
    switch score {
    case 90...100: return "A"
    case 80..<90: return "B"
    case 70..<80: return "C"
    default: return "F"
    }
})
```

### Conditional Mapping

Apply different mappings based on object properties:

```swift
TabularColumn.conditional(
    name: "Performance",
    keyPath: \.score,
    filter: { $0.isActive },
    then: { score in "Active: \(score)%" },      // For active students
    else: { score in "Inactive: \(score)%" }     // For inactive students
)
```

### Conditional Column Creation

Create columns only when certain conditions are met:

```swift
TabularColumn(name: "Honors", keyPath: \.score, mapping: { $0 > 90 ? "Yes" : "No" })
    .when { $0.score > 85 } // Only create this column if first student has score > 85
```

## Core Components

### ``TabularColumn``

The fundamental building block that defines how to extract and transform data from your objects:

```swift
// Basic column (no transformation)
TabularColumn(name: "Age", keyPath: \.age)

// Column with transformation
TabularColumn(name: "Formatted Age", keyPath: \.age, mapping: { "\($0) years" })

// Conditional column with different logic paths
TabularColumn.conditional(
    name: "Status",
    keyPath: \.score,
    filter: { student in student.score >= 60 },
    then: { score in "Pass (\(score))" },
    else: { score in "Fail (\(score))" }
)
```

### ``AnyTabularColumn``

Type-erased wrapper that allows columns with different types to be stored together while preserving their functionality.

### ``TabularColumnBuilder``

Result builder that enables declarative column definition syntax similar to SwiftUI:

```swift
@TabularColumnBuilder<Student>
var columns: [AnyTabularColumn<Student>] {
    TabularColumn(name: "Name", keyPath: \.name)
    TabularColumn(name: "Age", keyPath: \.age)
    
    if includeScores {
        TabularColumn(name: "Score", keyPath: \.score)
    }
}
```

### ``DataFrameConvertible``

Protocol that adds DataFrame conversion capabilities to any type. Simply conform to this protocol to enable TabularBuilder functionality:

```swift
extension MyCustomType: DataFrameConvertible {}

let dataFrame = MyCustomType.makeDataFrame(objects: myObjects) {
    // Column definitions...
}
```

## Use Cases

### Data Export

Export Core Data entities or any Swift objects to CSV/JSON files with custom formatting.

### Data Analysis

Leverage TabularData's powerful analysis capabilities for filtering, grouping, and statistical operations.

### Reporting

Generate reports with conditional formatting and dynamic column sets based on data characteristics.

## Why TabularBuilder?

- **Type Safety**: Leverage Swift's type system to prevent runtime errors
- **Expressiveness**: Clean, readable syntax inspired by SwiftUI
- **Flexibility**: Support for complex transformations and conditional logic
- **Performance**: Efficient conversion with minimal overhead
- **Integration**: Seamless integration with existing codebases
- **Maintainability**: Declarative approach makes code easier to understand and modify
