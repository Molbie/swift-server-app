import Foundation


public enum ServerType {
    case standard
    case secure
    case `internal`
}

public extension ServerType {
    public static var all: [ServerType] {
        return [.standard, .secure, .internal]
    }
}
