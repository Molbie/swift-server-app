import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectLogger
import PerfectRequestLogger


public final class Application {
    public let delegate: ApplicationDelegate
    private let requestLogger: RequestLogger
    private var servers = [ServerType: HTTPServer.Server]()
    private var serverContexts = [HTTPServer.LaunchContext]()
    private var controllers = [ServerType: RootController]()
    
    public init(delegate: ApplicationDelegate) {
        self.delegate = delegate
        self.requestLogger = RequestLogger()
        
        RequestLogFile.location = delegate.requestLogFileLocation()
        LogFile.location = delegate.applicationLogFileLocation()
    }
    
    public func start() {
        LogFile.info("Starting application")
        makeServers()
        delegate.applicationWillBecomeActive(self)
        launchServers()
        LogFile.info("Application started")
    }
    
    public func stop() {
        guard !serverContexts.isEmpty else { return }
        
        LogFile.info("Terminating application")
        delegate.applicationWillTerminate(self)
        terminateServers()
        delegate.applicationDidTerminate(self)
        LogFile.info("Application terminated")
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
                
                var requestFilters: [(HTTPRequestFilter, HTTPFilterPriority)] = [(requestLogger, .high)]
                requestFilters.append(contentsOf: controller.requestFilters)
                requestFilters.append(contentsOf: controller.childRequestFilters)
                
                var responseFilters: [(HTTPResponseFilter, HTTPFilterPriority)] = [(requestLogger, .low)]
                responseFilters.append(contentsOf: controller.responseFilters)
                responseFilters.append(contentsOf: controller.childResponseFilters)
                
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
                LogFile.critical("Failed to launch servers. \(error)")
            }
        }
        else {
            LogFile.critical("No servers configured.")
        }
    }
    
    private func terminateServers() {
        for context in serverContexts {
            context.terminate()
        }
    }
}
