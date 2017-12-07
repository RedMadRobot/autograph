# Autograph
## Description

**Autograph** provides instruments for building source code generation utilities (command line applications) on top of the
[Synopsis](https://github.com/RedMadRobot/synopsis) framework.

## Installation
### Swift Package Manager dependency

```swift
Package.Dependency.package(
    url: "https://github.com/RedMadRobot/autograph",
    from: "1.0.0"
)
```

## Usage
### Overview

First of all, in order to build a console executable using Swift there needs to be an execution entry point, a `main.swift` file.

**Autograph** uses a common approach when during the `main.swift` file execution your utility app instantiates a special
«Application» class object and passes control flow to it:

```swift
// main.swift sample code
import Foundation

exit(AutographApplication().run())
```

macOS console utilities are expected to return an `Int32` code after their execution, and any code different from `0` should be
treated as an error, thus `AutographApplication` method `run()` returns `Int32`. The method looks pretty much like this:

```swift
// class AutographApplication { ...

func run() -> Int32 {
    do {
        try someDangerousOperation()
        try someOtherDangerousOperation()
        ...
    } catch let error {
        print(error)
        return 1
    }
    return 0
}
```

Considering everything above, the entry point for you is an `AutographApplication` class.

### AutographApplication class

In order to create your own utility you'll need to create your own `main.swift` file following the example above,
and make your own `AutographApplication` subclass.

`AutographApplication` provides several convenient extension points for you to complete the execution process. When the app
runs, it goes through seven major steps:

##### 1. Gather execution parameters

`AutographApplication` console app supports three arguments by default:

* `-help` — print help;
* `-verbose` — print additional information during execution;
* `-project_name [name]` — provide project name to be used in generated code; if not set, "GEN" is used as a default project name.

All arguments along with current working directory are aggregated in an `ExecutionParameters` instance:

```swift
class ExecutionParameters {
    let projectName:      String
    let verbose:          Bool
    let printHelp:        Bool
    let workingDirectory: String
}
```

An `ExecutionParameters` instance acts like a dictionary, so that you may query it for your own arguments:

```
/*
    ./MyUtility -verbose -my_argument value
 */
 
 let parameters: ExecutionParameters = getParameters()
 let myArgument: String              = parameters["-my_argument"] ?? "default_value"
```

Arguments without values are stored in this dictionary with an empty `String` value.

##### 2. Print help

When your app is run with a `-help` argument, the execution is interrupted, and the `AutographApplication.printHelp()` method is called.

It's the first extension point for you. You may extend this method in order to provide your own help message like this:

```swift
// class App: AutographApplication {

override func printHelp() {
    super.printHelp()
    print("""
        -input
        Input folder with model source files.
        If not set, current working directory is used as an input folder.

        -output
        Where to put generated files.
        If not set, current working directory is used as an input folder.


        """)
}
```

Don't forget to leave an empty line after your help message.

##### 3. Provide list of folders with source code files

`AutographApplication` asks `provideInputFoldersList(fromParameters:)` method for a list of input folders. This method
returns an empty list by default.

It's the next major extension point for you. Here, you need to implement a way your utility app determines the list of input folders,
whence the app should search for the source code files to be analysed.

You may override this method like this:

```swift
// class App: AutographApplication {

override func provideInputFoldersList(
    fromParameters parameters: ExecutionParameters
) throws -> [String] {
    let input: String = parameters["-input"] ?? ""
    return [input]
}
```

Such that, you query the `ExecutionParameters` for an `-input` argument, and provide a default `""` value, which stands for the
current working directory.

`AutographApplication` later transforms all relative paths into absolute paths by concatenating with the current working directory,
thus the empty string `""` will result in the working directory as a default input folder.

If you think it's crucial for the execution to have an explicit `-input` argument value, you may throw an exception like this:

```swift
// class App: AutographApplication {

enum ExecutionError: Error, CustomStringConvertible {
    case noInputFolder
    
    var description: String {
        switch self {
            case .noInputFolder: return "!!! PLEASE PROVIDE AN -input FOLDER !!!"
        }
    }
}

override func provideInputFoldersList(
    fromParameters parameters: ExecutionParameters
) throws -> [String] {
    guard let input: String = parameters["-input"]
    else { throw ExecutionError.noInputFolder }
    return [input]
}
```

##### 4. Find all *.swift files in provided input folders

When the step #3 is complete, `AutographApplication` recursively scans input folders and their subfolders for `*.swift` files.
The result of this operation is a list of `URL` objects, which is then passed to the **Synopsis** framework in the step #5, see below.

There's not much you can do about this process, though there's an `open` calculated property
`AutographApplication.fileFinder`, where you may return your own `FileFinder` subclass instance if you want, for example,
to prohibit a recursive file search.

##### 5. Make a Synopsis out of all found source code

Step #5 is pretty straightforward, as it makes a `Synopsis` instance using the list of `URL` entities of source code files found in the
previous step.

Also, it calls `Synopsis.printToXcode()` in case your app is running in `-verbose` mode.

You can't extend or override this step.

##### 6. Compose utilities

A `Synopsis` instance is passed into the `AutographApplication.compose(forSynopsis:parameters:)` method, where you need
to generate new source code. At last!

This method returns a list of `Implementation` objects, each one contains the generated source code and a file path, where this
source code needs to be stored:

```swift
struct Implementation {
    let filePath:   String
    let sourceCode: String
}
```

Usually, this composition process is divided into several steps.

First, you'll need to define an output folder path. `AutographApplication` won't transform this path into absolute path, thus you
may use the relative one, like `"."`.

Second, you'll need to extract all necessary information out of the obtained `Synopsis` entity.

At last, you'll generate the actual source code.

During each step you may throw errors in case if something went wrong. Consider using an `XcodeMessage` errors in case you want
your app to rant over some particular source code.

```swift
// class App: AutographApplication {

override func compose(
    forSynopsis synopsis: Synopsis,
    parameters: ExecutionParameters
) throws -> [Implementation] {
    // use current directory as a default output folder:
    let output: String = parameters["-output"] ?? "."
    
    // make sure everything is annotated properly:
    try synopsis.classes.forEach { (classDescription: ClassDescription) in
        guard classDescription.annotations.contains(annotationName: "model")
        else {
            throw XcodeMessage(
                declaration: classDescription.declaration,
                message: "[MY GENERATOR] THIS CLASS IS NOT A MODEL"
            )
        }
    }
    
    // my composer may also throw:
    return try MyComposer().composeSourceCode(outOfModels: synopsis.classes)
}
```

##### 7. Write down to disk

Finally, your `Implementation` instances are being written to the hard drive.

All necessary output folders are created, if needed. Also, if there's a generated source code file already, and the source code didn't
change — `FileWriter` won't touch it.

Shall you want to adjust this process, there's an `open` calculated property `AutographApplication.fileWriter`, where you may
return your own `FileWriter` subclass instance.

### Log class — in development

During the app execution through steps mentioned above, different utilities like `FileFinder` or `FileWriter` may print debug
messages in case the app is running in a `-verbose` mode. These utilities use the same `Log.v(message:)` class method that you
can override in order to redirect log messages.

### Running tests

Use `spm_resolve.command` to load all dependencies and `spm_generate_xcodeproj.command` to assemble an Xcode project file.
Also, ensure Xcode targets macOS.

