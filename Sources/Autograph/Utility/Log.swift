//
// Project «Autograph»
// Created by Jeorge Taflanidi
//


import Foundation


/**
 Override to forward logs somewhere else than ```stdout```
 */
open class Log {
    
    /**
     Verbose print to ```stdout```
     */
    open class func v(_ message: String) {
        print(message)
    }
    
}
