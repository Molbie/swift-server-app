import Foundation
import PerfectHTTP


public protocol Controller {
    var routes: Routes { get }
    var requestFilters: [(HTTPRequestFilter, HTTPFilterPriority)] { get }
    var responseFilters: [(HTTPResponseFilter, HTTPFilterPriority)] { get }
    var childControllers: [Controller] { get }
}

public extension Controller {
    public var path: String {
        return String(describing: type(of: self)).replacingOccurrences(of: "Controller", with: "").lowercased()
    }
    
    public var childRoutes: Routes {
        var result = Routes(baseUri: path)
        for controller in childControllers {
            var routes = controller.routes
            routes.add(controller.childRoutes)
            result.add(routes)
        }
        return result
    }
    
    public var childRequestFilters: [(HTTPRequestFilter, HTTPFilterPriority)] {
        var result = [(HTTPRequestFilter, HTTPFilterPriority)]()
        for controller in childControllers {
            result.append(contentsOf: controller.requestFilters)
        }
        return result
    }
    
    public var childResponseFilters: [(HTTPResponseFilter, HTTPFilterPriority)] {
        var result = [(HTTPResponseFilter, HTTPFilterPriority)]()
        for controller in childControllers {
            result.append(contentsOf: controller.responseFilters)
        }
        return result
    }
}
