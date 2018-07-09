import Foundation
import PerfectHTTP


public protocol ApplicationDelegate {
    func applicationWillBecomeActive(_ application: Application)
    func applicationWillTerminate(_ application: Application)
    func applicationDidTerminate(_ application: Application)
    
    func requestLogFileLocation() -> String
    func applicationLogFileLocation() -> String
    
    func configuration(for server: ServerType) -> ServerConfiguration?
    func controller(for server: ServerType) -> RootController?
}

public extension ApplicationDelegate {
    public func applicationWillBecomeActive(_ application: Application) {}
    public func applicationWillTerminate(_ application: Application) {}
    public func applicationDidTerminate(_ application: Application) {}
    
    public func requestLogFileLocation() -> String {
        return "/var/log/access.log"
    }
    public func applicationLogFileLocation() -> String {
        return "/var/log/application.log"
    }
    
    public func configuration(for server: ServerType) -> ServerConfiguration? {
        switch server {
            case .standard:
                return ServerConfiguration.standard
            case .secure:
                return ServerConfiguration.secure
            case .internal:
                return ServerConfiguration.internal
        }
    }
}
