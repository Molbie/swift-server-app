import Foundation
import PerfectHTTP


public protocol RootController: Controller {
    
}

public extension RootController {
    public var path: String {
        return "/"
    }
    
    public var childRoutes: Routes {
        var result = Routes()
        for controller in childControllers {
            var routes = controller.routes
            routes.add(controller.childRoutes)
            result.add(routes)
        }
        return result
    }
}
