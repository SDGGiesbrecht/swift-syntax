## Overview

The `SwiftParser` framework implements a parser that accepts Swift source text
as input and produces a SwiftSyntax syntax tree. This module is under active development and is not yet ready to completely replace `SwiftSyntaxParser`. For more information about the design of this module, please see [the module documentation](SwiftParser.docc/SwiftParser.md).

## Quickstart

The easiest way to parse Swift source code is to call the `Parser.parse` method, providing it with a string containing the source code:

```swift
import SwiftParser
import SwiftSyntax

let sourceText =
"""
func greeting(name: String) {
  print("Hello, \(name)!")
}
"""

// Parse the source code in sourceText into a syntax tree
let sourceFile: SourceFileSyntax = Parser.parse(source: sourceText)

// The "description" of the source tree is the source-accurate view of what was parsed.
assert(sourceFile.description == sourceText)

// Visualize the complete syntax tree.
dump(sourceFile)
```
