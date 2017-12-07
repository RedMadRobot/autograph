//
// Project «Autograph»
// Created by Jeorge Taflanidi
//


import Foundation


/**
 Utility responsible for command line parameters parsing.
 */
open class ExecutionParametersReader {
    
    open func readExecutionParameters(fromCommandLineArguments commandLineArguments: [String]) throws -> ExecutionParameters {
        var verbose:     Bool               = false
        var printHelp:   Bool               = false
        var projectName: String             = "GEN"
        var raw:         [String: String]   = [:]
        
        for (index, argument) in commandLineArguments.enumerated() {
            if "-verbose" == argument {
                verbose = true
            }
            
            if "-help" == argument {
                printHelp = true
            }
            
            if "-project_name" == argument {
                if let value: String = commandLineArguments.nextAfter(index), !isKey(value) {
                    if verbose {
                        Log.v("Project name: \(value)")
                    }
                    projectName = value
                } else {
                    throw NSError(
                        domain: "\(type(of: self))",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "-project_name parameter found, but key is absent"
                        ]
                    )
                }
            }
            
            if isKey(argument) {
                if let value: String = commandLineArguments.nextAfter(index), !isKey(value) {
                    if verbose {
                        Log.v("Found pair of arguments: \(argument) = \(value)")
                    }
                    raw[argument] = value
                } else {
                    if verbose {
                        Log.v("Found argument: \(argument)")
                    }
                    raw[argument] = ""
                }
            }
        }
        
        defer {
            // NOTE: ExecutionParameters will contain current working directory after initialisation
            Log.v("Working directory: \(FileManager.default.currentDirectoryPath)")
        }
        
        return ExecutionParameters(
            projectName: projectName,
            verbose: verbose,
            printHelp: printHelp,
            raw: raw
        )
    }
    
}


private extension ExecutionParametersReader {
    
    func isKey(_ argument: String) -> Bool {
        return argument.hasPrefix("-")
    }
    
}


private extension Array {
    
    func nextAfter(_ index: Array.Index) -> Element? {
        if self.count > index + 1 {
            return self[index + 1]
        }
        return nil
    }
    
}
