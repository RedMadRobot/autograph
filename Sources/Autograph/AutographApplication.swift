//
// Project «Autograph»
// Created by Jeorge Taflanidi
//


import Foundation
import Synopsis


/**
 Base abstract class for all applications that compose helper classes from model objects' source 
 code.
 
 ```ComposerApplication``` instance is supposed to be initialised and launched from ```main.swift``` 
 file by calling it's ```run()``` method.
 
 Sample source code:
 ```swift
 import Foundation
 // main.swift
 exit(AutographApplication().run())
 ```
 
 YOU NEED TO IMPLEMENT / OVERRIDE:
 * **printHelp()** — extend with generator help; call ```super``` beforehand
 * **provideInputFoldersList(fromParameters:)** — return input folder paths from execution parameters
 * **compose(forObjects:parameters:)** — return composed utility classes
 * **Composer (abstract class)** — make your own composers; use them in ```compose(forSynopsis:parameters:)```
 
 */
open class AutographApplication {
    
    /**
     Override to use own execution parameters.
     */
    open var executionParametersReader: ExecutionParametersReader {
        return ExecutionParametersReader()
    }
    
    /**
     Override to replace or filtrate original ```CommandLine.arguments```
     */
    open var commandLineArguments: [String] {
        return CommandLine.arguments
    }
    
    /**
     Override to change file finding algorithm.
     */
    open var fileFinder: FileFinder {
        return FileFinder()
    }
    
    /**
     Override to change file writing process.
     */
    open var fileWriter: FileWriter {
        return FileWriter()
    }
    
    /**
     Application starts here.
     
     Processing includes three steps:
     0. reading execution parameters
     1. reading contents of input directories
     2. compiling found source code into objects
     3. implementing utility classes
     4. writing implemented source code to disk.
     
     Also, application may print help, if you ask politely.
     
     - returns: execution result code.
     */
    public func run() -> Int32 {
        do {
            let executionParameters: ExecutionParameters = try self.readExecutionParameters()
            
            if executionParameters.printHelp {
                self.printHelp()
                return 0
            }
            
            let inputFolders:         [String]         = try self.provideInputFoldersList(fromParameters: executionParameters)
            let files:                [URL]            = try self.findFiles(inFolders: inputFolders, parameters: executionParameters)
            let synopsis:             Synopsis         = try self.compile(files: files, parameters: executionParameters)
            let implementedUtilities: [Implementation] = try self.compose(forSynopsis: synopsis, parameters: executionParameters)
            
            try self.write(implementations: implementedUtilities, parameters: executionParameters)
        } catch let error {
            print(error)
            return 1
        }
        return 0
    }
    
    /**
     Get input folders from ```ExecutionParameters```.
     */
    open func provideInputFoldersList(fromParameters parameters: ExecutionParameters) throws -> [String] {
        return []
    }
    
    /**
     Compose utilities.
     */
    open func compose(forSynopsis synopsis: Synopsis, parameters: ExecutionParameters) throws -> [Implementation] {
        return []
    }
    
    /**
     Extend to add help information.
     */
    open func printHelp() {
        print("""
        Accepted arguments:
        
        -project_name [name]
        Project name to be used in generated files.
        If not set, "GEN" is used as a default project name.

        -verbose
        Application prints additional verbose information: found input files and folders, successfully saved files etc.


        """)
    }
    
    /**
     Allow children to be initialized.
     */
    public init() {}
    
}

private extension AutographApplication {
    
    func readExecutionParameters() throws -> ExecutionParameters {
        return try self.executionParametersReader.readExecutionParameters(fromCommandLineArguments: self.commandLineArguments)
    }
    
    func findFiles(inFolders folders: [String], parameters: ExecutionParameters) throws -> [URL] {
        return try self.fileFinder.findFiles(inFolders: folders, parameters: parameters)
    }
    
    func compile(files: [URL], parameters: ExecutionParameters) throws -> Synopsis {
        let result = Synopsis(files: files)
        
        if parameters.verbose {
            result.printToXcode()
        }
        
        return result
    }
    
    func write(implementations: [Implementation], parameters: ExecutionParameters) throws {
        return try self.fileWriter.write(implementations: implementations, parameters: parameters)
    }
    
}
