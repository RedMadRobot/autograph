//
// Project «Autograph»
// Created by Jeorge Taflanidi
//


import Foundation


/**
 Application execution parameters received from command line.
 */
open class ExecutionParameters: Equatable {
    
    /**
     Optional
     
     Default value: "GEN"
     
     ```
     -project_name $NAME
     ```
     */
    public let projectName: String
    
    /**
     Optional
     
     Default value: false
     
     ```
     -verbose
     ````
     */
    public let verbose: Bool
    
    /**
     Optional
     
     Default value: false
     
     ```
     -help
     ```
     */
    public let printHelp: Bool
    
    /**
     Application working directory.
     */
    public let workingDirectory: String
    
    /**
     Collected parameters.
     */
    public let raw: [String: String]
    
    /**
     Default initializer.
     */
    public init(
        projectName: String,
        verbose:     Bool,
        printHelp:   Bool,
        raw:         [String: String]
    ) {
        self.projectName = projectName
        self.verbose     = verbose
        self.printHelp   = printHelp
        self.raw         = raw
        
        self.workingDirectory = FileManager.default.currentDirectoryPath
    }
    
    public subscript(key: String) -> String? {
        return self.raw[key]
    }
    
    
    public static func ==(left: ExecutionParameters, right: ExecutionParameters) -> Bool {
        return left.projectName == right.projectName
            && left.verbose     == right.verbose
            && left.printHelp   == right.printHelp
            && left.raw         == right.raw
    }
    
}
