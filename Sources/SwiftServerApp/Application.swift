import Foundation
import PerfectHTTP
import PerfectHTTPServer


public final class Application {
    public let delegate: ApplicationDelegate
    private var servers = [ServerType: HTTPServer.Server]()
    private var serverContexts = [HTTPServer.LaunchContext]()
    private var controllers = [ServerType: RootController]()
    
    public init(delegate: ApplicationDelegate) {
        self.delegate = delegate
    }
    
    public func start() {
        makeServers()
        delegate.applicationWillBecomeActive(self)
        launchServers()
    }
    
    public func stop() {
        guard !serverContexts.isEmpty else { return }
        
        delegate.applicationWillTerminate(self)
        terminateServers()
        delegate.applicationDidTerminate(self)
    }
    
    deinit {
        stop()
    }
}

extension Application {
    private func makeServers() {
        for type in ServerType.all {
            if let config = delegate.configuration(for: type), let controller = delegate.controller(for: type) {
                var routes = Routes(baseUri: controller.path)
                routes.add(controller.routes)
                let childRoutes = controller.childRoutes.map { route -> Routes in
                    var baseUri: String = route.key
                    if baseUri.hasPrefix(controller.path) {
                        baseUri = String(baseUri.dropFirst(controller.path.count))
                    }
                    return Routes(baseUri: baseUri, routes: route.value)
                }
                for route in childRoutes {
                    routes.add(route)
                }
                
                var requestFilters = controller.requestFilters
                requestFilters.append(contentsOf: controller.requestFilters)
                
                var responseFilters = controller.responseFilters
                responseFilters.append(contentsOf: controller.responseFilters)
                
                let server: HTTPServer.Server
                if let tlsCert = config.tlsCert {
                    let tlsConfig = TLSConfiguration(cert: tlsCert)
                    server = HTTPServer.Server(tlsConfig: tlsConfig, name: config.name, port: config.port, routes: routes, requestFilters: requestFilters, responseFilters: responseFilters)
                }
                else {
                    server = HTTPServer.Server(name: config.name, port: config.port, routes: routes, requestFilters: requestFilters, responseFilters: responseFilters)
                }
                
                servers[type] = server
                controllers[type] = controller
            }
        }
    }
    
    private func launchServers() {
        let allServers = servers.map{ $0.value }
        if !allServers.isEmpty {
            do {
                serverContexts = try HTTPServer.launch(allServers)
            }
            catch {
                print("Failed to launch server. Error: \(error)!")
            }
        }
        else {
            print("No servers configured!")
        }
    }
    
    private func terminateServers() {
        for context in serverContexts {
            context.terminate()
        }
    }
}
