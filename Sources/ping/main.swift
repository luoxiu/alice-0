import Foundation
import Alice

class LogMW: HTTPMiddleware {
    
    func respond(to req: HTTPRequest, chainingTo next: HTTPResponder) throws -> Future<HTTPResponse, Error> {
        print("[LOG IN]: \(req.method) \(req.url)")
        
        return try next.respond(to: req).always {
            print("[LOG OUT]: \(req.method) \(req.url)")
        }
    }
}

class TimeSpentMW: HTTPMiddleware {
    
    func respond(to req: HTTPRequest, chainingTo next: HTTPResponder) throws -> Future<HTTPResponse, Error> {
        let now = Date()
        
        return try next.respond(to: req).map {
            $0.with {
                $0.headers.set("\(Date().timeIntervalSince(now))", for: "Time-Spent")
            }
        }
    }
}

HTTPClient.shared
    .use(LogMW())
    .use(TimeSpentMW())

let url = HTTPURL().withHost("localhost").withPort(3000)

var req = HTTPRequest(method: .get, url: url)

let task = req.downloadTask()
    
task.start()

task.response
    .whenSucceed {
        print($0.json as Any)
    }

RunLoop.current.run()
