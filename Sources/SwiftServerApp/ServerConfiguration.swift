import Foundation


public struct ServerConfiguration {
    public let name: String
    public let port: Int
    public let type: ServerType
    public let tlsCert: String? // file path OR raw PEM data
    
    public init(name: String, port: Int, type: ServerType, tlsCert: String? = nil) {
        self.name = name
        self.port = port
        self.type = type
        self.tlsCert = tlsCert
    }
}

public extension ServerConfiguration {
    public static var standard: ServerConfiguration {
        return ServerConfiguration(name: "localhost", port: 8080, type: .standard)
    }
    
    public static var secure: ServerConfiguration {
        // TODO: add tls config
        return ServerConfiguration(name: "localhost", port: 8081, type: .secure, tlsCert: nil)
    }
    
    public static var `internal`: ServerConfiguration {
        return ServerConfiguration(name: "localhost", port: 8090, type: .internal)
    }
}
