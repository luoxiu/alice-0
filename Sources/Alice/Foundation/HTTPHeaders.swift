import Foundation

public struct HTTPHeader {
    
    public var name: HTTPHeaderName
    public var value: String
    
    public init(name: HTTPHeaderName, value: String) {
        self.name = name
        self.value = value
    }
}

public struct HTTPHeaders {
    
    private var storage: [HTTPHeader]

    public init() {
        self.storage = []
    }
    
    public init(dict: [String: String]) {
        self.storage = dict.map {
            HTTPHeader(name: HTTPHeaderName($0.key), value: $0.value)
        }
    }
    
    public subscript(name: HTTPHeaderName) -> String? {
        get {
            return self.value(for: name)
        }
        set {
            if let value = newValue {
                self.set(value, for: name)
            } else {
                self.remove(name)
            }
        }
    }
    
    public mutating func add(_ value: String, for name: HTTPHeaderName) {
        if let index = self.storage.firstIndex(where: { $0.name == name }) {
            self.storage[index].value.append("," + value)
        } else {
            self.storage.append(HTTPHeader(name: name, value: value))
        }
    }
    
    public mutating func set(_ value: String, for name: HTTPHeaderName) {
        if let index = self.storage.firstIndex(where: { $0.name == name }) {
            self.storage[index].value = value
        } else {
            self.storage.append(HTTPHeader(name: name, value: value))
        }
    }
    
    public mutating func remove(_ name: HTTPHeaderName) {
        self.storage.removeAll(where: { $0.name == name })
    }
    
    public mutating func removeAll() {
        self.storage.removeAll()
    }
    
    public func value(for name: HTTPHeaderName) -> String? {
        return self.storage.first(where: { $0.name == name })?.value
    }
    
    public func contains(_ name: HTTPHeaderName) -> Bool {
        return self.value(for: name) != nil
    }
    
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, String)...) {
        self.storage = []
        self.storage.reserveCapacity(elements.count)
        for kv in elements {
            self.add(kv.0, for: HTTPHeaderName(kv.1))
        }
    }
}

extension HTTPHeaders: CustomStringConvertible {
    
    public var description: String {
        let content = self.storage
            .map {
                "\t" + $0.name.description + ": " + $0.value
            }
            .joined(separator: ",\n")
        
        return "[\n" + content + "\n]"
    }
}

extension HTTPHeaders {
    
    public func toDictionary() -> [String: String] {
        var dict: [String: String] = .init(minimumCapacity: self.storage.count)
        for header in self.storage {
            dict[header.name.rawValue] = header.value
        }
        return dict
    }
}

extension HTTPHeaders {
    
    init(_ request: URLRequest) {
        guard let headers = request.allHTTPHeaderFields else {
            self.init()
            return
        }
        self.init(dict: headers)
    }
    
    init(_ response: HTTPURLResponse) {
        guard let headers = response.allHeaderFields as? [String: String] else {
            self.init()
            return
        }
        self.init(dict: headers)
    }
}
