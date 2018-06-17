import Foundation
import PerfectHTTP


open class Controller {
    public var routes = [Route]()
    public var requestFilters: [(HTTPRequestFilter, HTTPFilterPriority)] = []
    public var responseFilters: [(HTTPResponseFilter, HTTPFilterPriority)] = []
    public var childControllers = [Controller]()
    open var path: String {
        return String(describing: type(of: self)).replacingOccurrences(of: "Controller", with: "").lowercased()
    }
    
    public init() {
        
    }
}

internal extension Controller {
    internal var childRoutes: [String: [Route]] {
        var result = [String: [Route]]()
        for controller in childControllers {
            let controllerUri = controller.path
            if result[controllerUri] == nil {
                result[controllerUri] = controller.routes
            }
            else {
                result[controllerUri]?.append(contentsOf: controller.routes)
            }
            
            for (childPath, routes) in controller.childRoutes {
                let childUri = controllerUri.append(childPath, separator: "/")
                if result[childUri] == nil {
                    result[childUri] = routes
                }
                else {
                    result[childUri]?.append(contentsOf: routes)
                }
            }
        }
        return result
    }
    
    internal var childRequestFilters: [(HTTPRequestFilter, HTTPFilterPriority)] {
        var result = [(HTTPRequestFilter, HTTPFilterPriority)]()
        for controller in childControllers {
            result.append(contentsOf: controller.requestFilters)
        }
        return result
    }
    
    internal var childResponseFilters: [(HTTPResponseFilter, HTTPFilterPriority)] {
        var result = [(HTTPResponseFilter, HTTPFilterPriority)]()
        for controller in childControllers {
            result.append(contentsOf: controller.responseFilters)
        }
        return result
    }
}

private extension String {
    func append(_ other: String, separator: String) -> String {
        var result = self
        if !result.hasSuffix(separator) && !other.hasPrefix(separator) {
            result += separator
        }
        result += other
        
        return result
    }
}
