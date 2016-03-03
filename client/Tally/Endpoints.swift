class Endpoints {
    private static let debug = "http://localhost:5000"
    private static let api = "https://api.tally.us"
    
    private static var host: String {
        #if DEBUG
            return debug
        #else
            return api
        #endif
    }
    
    static let authenticate = host + "/v1/authenticate"
    static let z0675e3xqgs0pb93 = host + "/v1/z0675e3xqgs0pb93"
    static let setCard = host + "/v1/set-card"
    
    static let recentEvents = "https://generated.tally.us/v1/events/recent.json"
    static let topEvents = "https://generated.tally.us/v1/events/top.json"
}
