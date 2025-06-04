# TabularBuilder

![Swift 6](https://img.shields.io/badge/Swift-6-orange?logo=swift) ![iOS](https://img.shields.io/badge/iOS-15.0+-green) ![macOS](https://img.shields.io/badge/macOS-12.0+-green) ![watchOS](https://img.shields.io/badge/watchOS-8.0+-green) ![visionOS](https://img.shields.io/badge/visionOS-1.0+-green) ![tvOS](https://img.shields.io/badge/tvOS-15.0+-green) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/fatbobman/TabularBuilder)

A Swift library that provides a declarative, type-safe approach to converting any object arrays into TabularData DataFrames. TabularBuilder enables seamless data export and analysis by bridging the gap between object-oriented data models and columnar data structures.

## Features

- **Universal Object Conversion**: Convert any object arrays (Core Data entities, structs, classes) to TabularData DataFrames
- **Declarative Column Definition**: Use SwiftUI-like syntax to define columns with `@TabularColumnBuilder`
- **Type-Safe Transformations**: Leverage Swift's type system for safe data mapping and transformation
- **Conditional Logic**: Support for conditional column creation and conditional value mapping
- **Custom Column Ordering**: Precise control over column order and naming
- **Value Mapping**: Transform values using custom mapping functions before export
- **Non-Intrusive**: Add DataFrame conversion capability to existing types without modification

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 16.0+

## Motivation

When working with data-intensive applications, there's often a need to convert object collections (like Core Data entities) into structured tabular formats for two primary purposes:

- **Data Export**: Easily save data as JSON/CSV files for sharing or archival
- **Data Analysis**: Leverage TabularData's powerful APIs for filtering, aggregation, and statistical operations

While this seems straightforward—converting "row-oriented" data structures to "column-oriented" ones—the reality becomes complex when dealing with dozens of different entity types. Writing individual conversion code for each entity is both tedious and error-prone.

TabularBuilder was created to solve this challenge by providing a **universal, type-safe, and declarative** approach to DataFrame conversion. Instead of repetitive boilerplate code, you can define your data transformations once and apply them consistently across all your data types.

The library showcases Swift's modern language features including generics, KeyPath, type erasure, protocol extensions, and Result Builders to create an elegant solution that is both powerful and easy to use.

**The result?** Clean, maintainable code that leverages Swift's powerful type system while providing the flexibility to handle complex data transformation scenarios.

> For a detailed exploration of the design philosophy and Swift features that make this library possible, read the full article: [Experience the Charm of Swift: One-Click DataFrame Export](https://fatbobman.com/en/posts/experience-the-charm-of-swift-one-click-export-dataframe/)

---

Don't miss out on the latest updates and excellent articles about Swift, SwiftUI, Core Data, and SwiftData. Subscribe to **[Fatbobman's Swift Weekly](https://weekly.fatbobman.com)** and receive weekly insights and valuable content directly to your inbox.

---

## Installation

### Swift Package Manager

Add TabularBuilder to your project through Xcode:

1. Go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/fatbobman/TabularBuilder`
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/fatbobman/TabularBuilder", from: "0.5.0")
]
```

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
    Student(name: "Bob", age: 22, score: 87.0, isActive: false),
    Student(name: "Charlie", age: 19, score: 92.5, isActive: true)
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

## Advanced Usage

### Custom Value Mapping

Transform values during column creation:

```swift
let dataFrame = Student.makeDataFrame(objects: students) {
    // Convert Int to String with formatting
    TabularColumn(name: "Age", keyPath: \.age, mapping: { "\($0) years old" })
    
    // Complex transformations
    TabularColumn(name: "Grade", keyPath: \.score, mapping: { score in
        switch score {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        default: return "F"
        }
    })
}
```

### Conditional Mapping

Apply different mappings based on object properties:

```swift
let dataFrame = Student.makeDataFrame(objects: students) {
    // Display score differently for active vs inactive students
    TabularColumn.conditional(
        name: "Performance",
        keyPath: \.score,
        filter: { $0.isActive },
        then: { score in "Active: \(score)%" },      // For active students
        else: { score in "Inactive: \(score)%" }     // For inactive students
    )
}
```

### Conditional Column Creation

Create columns only when certain conditions are met:

```swift
let dataFrame = Student.makeDataFrame(objects: students) {
    TabularColumn(name: "Name", keyPath: \.name)
    TabularColumn(name: "Age", keyPath: \.age)
    
    // Only include this column for high-performing student groups
    TabularColumn(name: "Honors", keyPath: \.score, mapping: { $0 > 90 ? "Yes" : "No" })
        .when { $0.score > 85 } // Only create this column if first student has score > 85
}
```

### Working with Optional Values

Handle optional properties gracefully:

```swift
struct Person: DataFrameConvertible {
    let name: String
    let email: String?
    let phone: String?
}

let dataFrame = Person.makeDataFrame(objects: people) {
    TabularColumn(name: "Name", keyPath: \.name)
    TabularColumn(name: "Email", keyPath: \.email, mapping: { $0 ?? "N/A" })
    TabularColumn(name: "Contact", keyPath: \.phone, mapping: { $0 ?? "No phone" })
}
```

### Complex Data Transformations

```swift
struct Order: DataFrameConvertible {
    let id: UUID
    let amount: Decimal
    let date: Date
    let items: [String]
}

let dataFrame = Order.makeDataFrame(objects: orders) {
    TabularColumn(name: "Order ID", keyPath: \.id, mapping: { $0.uuidString.prefix(8).uppercased() })
    TabularColumn(name: "Amount", keyPath: \.amount, mapping: { "$\($0)" })
    TabularColumn(name: "Date", keyPath: \.date, mapping: { DateFormatter.shortDate.string(from: $0) })
    TabularColumn(name: "Item Count", keyPath: \.items, mapping: { $0.count })
}
```

## Core Components

### TabularColumn

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

### AnyTabularColumn

Type-erased wrapper that allows columns with different types to be stored together:

```swift
let columns: [AnyTabularColumn<Student>] = [
    AnyTabularColumn(TabularColumn(name: "Name", keyPath: \.name)),        // String column
    AnyTabularColumn(TabularColumn(name: "Age", keyPath: \.age)),          // Int column
    AnyTabularColumn(TabularColumn(name: "Score", keyPath: \.score))       // Double column
]
```

### TabularColumnBuilder

Result builder that enables declarative column definition syntax:

```swift
@TabularColumnBuilder<Student>
var columns: [AnyTabularColumn<Student>?] {
    TabularColumn(name: "Name", keyPath: \.name)
    TabularColumn(name: "Age", keyPath: \.age)
    
    if includeScores {
        TabularColumn(name: "Score", keyPath: \.score)
    }
    
    // Can also include arrays of columns
    additionalColumns
}
```

### DataFrameConvertible Protocol

Protocol that adds DataFrame conversion capabilities to any type:

```swift
extension MyCustomType: DataFrameConvertible {}

// Now you can convert arrays to DataFrames
let dataFrame = MyCustomType.makeDataFrame(objects: myObjects) {
    // Column definitions...
}
```

## Use Cases

### Data Export

```swift
// Export Core Data entities to CSV
let dataFrame = Person.makeDataFrame(objects: people) {
    TabularColumn(name: "Full Name", keyPath: \.name)
    TabularColumn(name: "Birth Year", keyPath: \.birthDate, mapping: { Calendar.current.component(.year, from: $0) })
}

try dataFrame.writeCSV(to: exportURL)
```

### Data Analysis

```swift
// Leverage TabularData's powerful analysis capabilities
let dataFrame = SalesRecord.makeDataFrame(objects: sales) {
    TabularColumn(name: "Amount", keyPath: \.amount)
    TabularColumn(name: "Quarter", keyPath: \.date, mapping: { getQuarter(from: $0) })
}

// Perform analysis
let totalsByQuarter = dataFrame.grouped(by: "Quarter").sums(on: "Amount")
```

### Reporting

```swift
// Generate reports with conditional formatting
let dataFrame = Employee.makeDataFrame(objects: employees) {
    TabularColumn(name: "Name", keyPath: \.name)
    TabularColumn.conditional(
        name: "Performance",
        keyPath: \.rating,
        filter: { $0.rating >= 4.0 },
        then: { "Excellent (\($0))" },
        else: { "Needs Improvement (\($0))" }
    )
}
```

## Why TabularBuilder?

- **Type Safety**: Leverage Swift's type system to prevent runtime errors
- **Expressiveness**: Clean, readable syntax inspired by SwiftUI
- **Flexibility**: Support for complex transformations and conditional logic
- **Performance**: Efficient conversion with minimal overhead
- **Integration**: Seamless integration with existing codebases
- **Maintainability**: Declarative approach makes code easier to understand and modify

## License

TabularBuilder is available under the MIT license. See the LICENSE file for more info.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/fatbobman)
