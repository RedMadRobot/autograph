//
// Project «Autograph»
// Created by Jeorge Taflanidi
//


import Foundation


/**
 Source code implementation.
 
 After compilation, `Klass` instances are used to generate utilities. Generated source code of these
 utilities is organised into `Implementation` instances.
 */
public struct Implementation: Equatable {

    /**
     File path for future Swift class.
     */
    public let filePath:   String

    /**
     Source code.
     */
    public let sourceCode: String

    /**
     Initializer.
     */
    public init(filePath: String, sourceCode: String) {
        self.filePath = filePath
        self.sourceCode = sourceCode
    }
    
    public static func ==(left: Implementation, right: Implementation) -> Bool {
        return left.filePath   == right.filePath
            && left.sourceCode == right.sourceCode
    }

}
