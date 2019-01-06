import Foundation

protocol UnsplashAPI {
    
}


/*
 * ---------------------------------------------------------------------------
 * TODO: - Split the class in sections like: photos, collections, user, stats
 * ---------------------------------------------------------------------------
 */


/**
 - Author: [Federico Vitale](https://github.com/rawnly)
 - Version: 0.1
 */
public class UnsplashAPIClient {
    
    /**
     The default callback type of *completion* parameters
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - responseObject: The object returned from the API, such as *Photos* / *Collection* etc..
         - statusCode: The response statuscode
     */
    public typealias DefaultCallback<T: Decodable> = (_ responseObject: T?, _ statusCode: Int) -> Void

    /*
     * -----------------------
     * MARK: - Variables
     * ------------------------
     */
    
    /// The api URL
    private let baseURL: String = "https://api.unsplash.com"
    
    // API Credentials
    private let client_id:String
    private let client_secret:String
    
    private let redirect_uri: URL?
    
    /// Token for authenticated requests
    private let bearerToken: String?

    
    /**
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - accessKey: The Unsplash('s) *Access Key*
        - secretKey: The Unsplash('s) *Secret Key*
        - bearerToken: Token for authentication needed requests
        - redirect_uri: Where to redirect the user once logged
     
     - Returns: Void
     */
    public init(accessKey client_id:String, secretKey client_secret:String, redirect_uri: URL? = nil, bearerToken:String? = nil) {
        self.client_id = client_id
        self.client_secret = client_secret
        
        self.redirect_uri = redirect_uri
        
        self.bearerToken = bearerToken
    }
    
    
    /*
     * -----------------------
     * MARK: - Core
     * ------------------------
     */
    
    
    /**
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - endpoint: The Unsplash('s) endpoint to be fetched
        - params: Optional query params
     
     - Returns: Void
     */
    internal func fetch<ResponseObject: Decodable>(
        endpoint: String,
        params: [URLQueryItem]? = [URLQueryItem](),
        completion: @escaping DefaultCallback<ResponseObject>
    ) -> Void {
        let session = URLSession.shared
        var url = URL(string: self.baseURL)!
        
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "client_id", value: self.client_id)]
        
        params?.forEach({ (item) in
            if item.value != nil {
                queryItems.append(item)
            }
        })
        
        url.appendPathComponent(endpoint)
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        url = urlComponents.url!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else { return }
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            if response.statusCode != 200 {
                completion(nil, response.statusCode)
                return
            }
            
            do {
                let responseObject = try JSONDecoder().decode(ResponseObject.self, from: data)
                completion(responseObject, response.statusCode)
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
        
        task.resume()
    }
    
    /**
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - endpoint: The Unsplash('s) endpoint to be fetched
         - params: Optional query params
     
     - Returns: Void
     */
    internal func fetch(
        endpoint: String,
        params: [URLQueryItem]? = [URLQueryItem](),
        requiredStatusCode: Int = 200,
        completion: @escaping (_ data: Data?, _ response: HTTPURLResponse) -> Void
        ) -> Void {
        let session = URLSession.shared
        var url = URL(string: self.baseURL)!
        
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "client_id", value: self.client_id)]
        
        params?.forEach({ (item) in
            if item.value != nil {
                queryItems.append(item)
            }
        })
        
        url.appendPathComponent(endpoint)
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        url = urlComponents.url!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else { return }
            
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, response)
                return
            }
            
            if response.statusCode != requiredStatusCode {
                completion(nil, response)
                return
            }
            
            completion(data, response)
        }
        
        task.resume()
    }
}


/*
 * -----------------------
 * MARK: - Methods: User
 * ------------------------
 */
extension UnsplashAPIClient {
    /**
     Get a user’s public profile
     
     Retrieve public details on a given user.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - username: The user’s username
     
     - Returns: Void
     */
    public func getUser(user username: String, completion: @escaping DefaultCallback<Unsplash.User>) {
        fetch(endpoint: "users/\(username)", completion: completion)
    }
    
    
    /**
     Get a user’s portfolio link
     
     Retrieve a single user’s portfolio link.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - username: The user’s username
     
     - Returns: Void
     */
    public func getUserPortfolio(user username: String, completion: @escaping DefaultCallback<Unsplash.URLResponse>) {
        fetch(endpoint: "users/\(username)/portfolio", completion: completion)
    }
    
    
    /**
     List a user’s photos
     
     Get a list of photos uploaded by a user.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - username: The user’s username.
         - page: Page number to retrieve. (Default: 1)
         - limit: Number of items per page. (Default: 10)
         - order: How to sort the photos. (Default: `.latest`)
         - stats: Show the stats for each user’s photo. (Default: false)
         - resolution: The frequency of the stats. (Default: “days”)
         - quantity: The amount of for each stat. (Default: 30)
     
     - Returns: Void
     */
    public func getUserPhotos(
        username: String,
        page: Int = 1,
        per_page perPage: Int = 10,
        order_by orderBy: Order = .latest,
        stats: Bool = false,
        resolution frequency: Frequency = .days,
        quantity: Int = 30,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
    ) {
        fetch(endpoint: "users/\(username)/photos", params: [
            URLQueryItem(name: "page", value: "\(page < 1 ? 1 : page)"),
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
            URLQueryItem(name: "order_by", value: orderBy.rawValue),
            URLQueryItem(name: "stats", value: "\(stats)"),
            URLQueryItem(name: "resolution", value: frequency.rawValue),
            URLQueryItem(name: "quantity", value: "\(quantity)")
        ], completion: completion)
    }
    
    /**
     List a user’s liked photos
     
     Get a list of photos liked by a user.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - username: The user’s username
         - page: Page number to retrieve (Default: 1)
         - per_page: Number of items per page (Default: 10)
         - order_by: How to sort the photos (Default: latest)
     
     - Returns: Void
     */
    public func getUserLikes(
        user username: String,
        page: Int = 1,
        per_page: Int = 10,
        order_by orderBy: Order = .latest,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
        ) {
        fetch(endpoint: "users/\(username)/likes", params: [
            URLQueryItem(name: "page", value: page < 1 ? "\(1)" : "\(page)"),
            URLQueryItem(name: "per_page", value: per_page > 30 ? "\(30)" : "\(per_page)"),
            URLQueryItem(name: "order_by", value: orderBy.rawValue)
        ], completion: completion)
    }
    
    
    /**
     Get user's collections
     
     Get a list of collections created by the user.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - username: The user’s username
         - page: Page number to retrieve (Default: 1)
         - limit: Number of items per page (Default: 10)
     
     - Returns: Void
     */
    public func getUserCollections(
        user username: String,
        page: Int = 1,
        per_page perPage: Int = 10,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
        ) {
        fetch(endpoint: "users/\(username)/collections", params: [
            URLQueryItem(name: "page", value: "\(page < 1 ? 1 : page)"),
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)")
        ], completion: completion)
    }
    
    
    /**
     Get a user’s statistics
     
     Retrieve the consolidated number of downloads, views and likes of all user’s photos, as well as the historical breakdown and average of these stats in a specific timeframe (default is 30 days).
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - username: The user’s username
         - page: Page number to retrieve (Default: 1)
         - perPage: Number of items per page (Default: 10)
         - order: How to sort the photos (Default: latest)
     
     - Returns: Void
     */
    
    public func getUserStats(
        user username: String,
        page: Int = 1,
        per_page perPage: Int = 10,
        order_by orderBy: Order = .latest,
        completion: @escaping DefaultCallback<Unsplash.StatsResponse>
        ) {
        fetch(endpoint: "users/\(username)/likes", params: [
            URLQueryItem(name: "page", value: page < 1 ? "\(1)" : "\(page)"),
            URLQueryItem(name: "per_page", value: perPage > 30 ? "\(30)" : "\(perPage)"),
            URLQueryItem(name: "order_by", value: orderBy.rawValue)
        ], completion: completion)
    }
}

/*
 * -----------------------
 * MARK: - Methods: Photos
 * ------------------------
 */
extension UnsplashAPIClient {
    /**
     List photos
     
     Get a single page from the list of all photos.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - page: Page number to retrieve. (Default: 1)
         - perPage: Number of items per page. (Default: 10)
         - orderBy: How to sort the photos. (Default: `.latest`)
     
     - Returns: Void
     */
    public func getPhotos(
        page: Int = 1,
        per_page perPage: Int = 10,
        order_by orderBy: Order = .latest,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
    ) {
        fetch(endpoint: "photos", params: [
            URLQueryItem(name: "page", value: "\(page < 1 ? 1 : page)"),
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
            URLQueryItem(name: "order_by", value: orderBy.rawValue)
        ], completion: completion)
    }
    
    /**
     Get a photo
     
     Retrieve a single photo.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - id: The photo’s ID
     
     - Returns: Void
     */
    public func getPhoto(id: String, completion: @escaping DefaultCallback<Unsplash.Photo>) {
        fetch(endpoint: "/photos/\(id)", completion: completion)
    }
    
    
    /**
     Get a random photo
     
     Retrieve a single random photo, given optional filters.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - filters: Query filters like `user/collection/featured/count`
     
     - Returns: Void
     */
    public func getRandomPhoto(
        filters: Filters?=nil,
        completion: @escaping DefaultCallback<Unsplash.Photo>
    ) {
        var params: [URLQueryItem] = [URLQueryItem]()
        
        if let filters = filters {
            params = [
                URLQueryItem(name: "query", value: filters.query),
                URLQueryItem(name: "count", value: filters.count),
                URLQueryItem(name: "collections", value: filters.collections),
                URLQueryItem(name: "user", value: filters.user)
            ]
        }
        
        fetch(endpoint: "photos/random", params: params, completion: completion)
    }
    
    /**
     Get a photo’s statistics
     
     Retrieve total number of downloads, views and likes of a single photo, as well as the historical breakdown of these stats in a specific timeframe (default is 30 days).
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - id: The public id of the photo.
         - frequency: The frequency of the stats (Default: `.days`)
         - quantity: The amount of for each stat (Default: 30)
     
     - Returns: Void
     */
    public func getPhotoStats(
        id: String,
        resolution frequency: Frequency = .days,
        quantity: Int = 30,
        completion: @escaping DefaultCallback<Unsplash.StatsResponse>
    ) {
        fetch(
            endpoint: "photos/\(id)/statistics",
            params: [
                URLQueryItem(name: "resolution", value: frequency.rawValue),
                URLQueryItem(name: "quantity", value: "\(quantity)")
            ],
            completion: completion
        )
    }
    
    /**
     Track a photo download
     
     To abide by the API guidelines, you need to trigger a GET request to this endpoint every time your application performs a download of a photo. To understand what constitutes a download, please refer to the ‘[Triggering a download](https://medium.com/unsplash/unsplash-api-guidelines-triggering-a-download-c39b24e99e02)’ guideline.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - id: The public id of the photo.
     
     - Returns: Void
     */
    public func getDownloadURL(
        id: String,
        completion: @escaping DefaultCallback<Unsplash.URLResponse>
    ) {
        fetch(endpoint: "photos/\(id)/download", completion: completion)
    }
}

/*
 * -----------------------
 * MARK: - Methods: Photos/Authenticated
 * ------------------------
 */
extension UnsplashAPIClient {
    /**
     Update a photo

     Update a photo on behalf of the logged-in user. This requires the write_photos scope.

     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - id: The public id of the photo.
        - data: The updated photo data
     
     - Returns: Void
     
     */
//    public func updatePhoto(
//        id: String,
//        data: Unsplash.Photo,
//        completion: DefaultCallback<Unsplash.Photo>
//    ) {
//        // Code here
//    }
    
    
    /**
     Like a photo
     
     Like a photo on behalf of the logged-in user. This requires the write_likes scope.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Note: This action is idempotent; sending the **POST** request to a single photo multiple times has no additional effect.
     - Parameters:
        - id: The public id of the photo.
     
     - Returns: Void
     
     */
//    public func likePhoto(
//        id: String,
//        completion: DefaultCallback<Unsplash.Photo>
//        ) {
//        // Code here
//    }
    
    /**
     Unlike a photo
     
     Remove a user’s like of a photo.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Note: This action is idempotent; sending the **DELETE** request to a single photo multiple times has no additional effect
     - Parameters:
        - id: The public id of the photo.
     
     - Returns: Void
     
     */
//    public func unlikePhoto(
//        id: String,
//        completion: DefaultCallback<Unsplash.Photo>
//        ) {
//        // Code here
//    }
}


/*
 * ----------------------------
 * MARK: - Methods: Collections
 * ----------------------------
 */
extension UnsplashAPIClient {
    /**
     Get a collection by ID
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
        - id: The collections’s ID.
     
     - Returns: Void
     */
    public func getCollection(
        id:String,
        isCurated curated: Bool = false,
        completion: @escaping DefaultCallback<Unsplash.Collection>
    ) {
        let endpoint = curated ? "collections/curated/\(id)" : "collections/\(id)"
        fetch(endpoint: endpoint, completion: completion)
    }
    
    /**
     Get photos from a collection
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - collection: The collection object
         - page: Page number to retrieve (Default: 1)
         - perPage: Number of items per page (Default: 10)
     
     - Returns: Void
     */
    public func getPhotosFromCollection(
        collection: Unsplash.Collection,
        page: Int = 1,
        per_page perPage:Int = 10,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
    ) {
        fetch(endpoint: "collections/\(collection.id)/photos", params: [
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ], completion: completion)
    }
    
    /**
     Get photos from a collection
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - collection_id: The collection ID
         - page: Page number to retrieve (Default: 1)
         - perPage: Number of items per page (Default: 10)
     
     
     - Returns: Void
     */
    public func getPhotosFromCollection(
        collection_id: String,
        page: Int = 1,
        per_page perPage: Int = 30,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
    ) {
        fetch(endpoint: "collections/\(collection_id)/photos", params: [
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ], completion: completion)
    }
    
    
    
    /**
     Get a single page from the list of all collections.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     - Parameters:
         - featured: If `true` retrives only featured collections
         - page: Page number to retrieve (Default: 1)
         - perPage: Number of items per page (Default: 10)
     
     - Returns: Void
     */
    public func listCollections(
        featured: Bool = false,
        page: Int = 1,
        per_page perPage:Int=10,
        completion: @escaping DefaultCallback<[Unsplash.Collection]>
    ) {
        fetch(endpoint: featured ? "collections/featured" : "collections", params: [
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ], completion: completion)
    }
}


/*
 * -----------------------
 * MARK: - Methods: Search
 * ------------------------
 */
extension UnsplashAPIClient {
    /**
     Search photos
     
     Get a single page of photo results for a query.
     
     - Author: [Federico Vitale](https://rawnly.com) &mdash; [Github](https://github.com/rawnly)
     - Parameters:
         - query: Search terms.
         - page: Page number to retrieve. (Default: 1)
         - perPage: Number of items per page. (Default: 10)
         - collections: Collection ID(‘s) to narrow search. If multiple, comma-separated.
         - orientation: Filter search results by photo orientation.
     
     - Returns: Void
     */
    public func searchPhotos(
        query: String,
        page: Int = 1,
        per_page perPage: Int = 10,
        collections: String,
        orientation: Orientation = .landscape,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
    ) {
        fetch(endpoint: "search/photos", params: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page < 1 ? 1 : page)"),
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
            URLQueryItem(name: "collections", value: collections),
            URLQueryItem(name: "orientation", value: orientation.rawValue),
        ], completion: completion)
    }
    
    /**
     Search photos
     
     Get a single page of photo results for a query.
     
     - Author: [Federico Vitale](https://rawnly.com) &mdash; [Github](https://github.com/rawnly)
     - Parameters:
     - query: Search terms.
     - page: Page number to retrieve. (Default: 1)
     - perPage: Number of items per page. (Default: 10)
     - collections: Collections ID(‘s) to narrow search.
     - orientation: Filter search results by photo orientation.
     
     - Returns: Void
     */
    public func searchPhotos(
        query: String,
        page: Int = 1,
        per_page perPage: Int = 10,
        collections: [String],
        orientation: Orientation = .landscape,
        completion: @escaping DefaultCallback<[Unsplash.Photo]>
    ) {
        fetch(endpoint: "search/photos", params: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page < 1 ? 1 : page)"),
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
            URLQueryItem(name: "collections", value: collections.joined(separator: ",")),
            URLQueryItem(name: "orientation", value: orientation.rawValue),
        ], completion: completion)
    }
    
    
    /**
     Search collections
     
     Get a single page of collection results for a query.
     
     - Author: [Federico Vitale](https://rawnly.com) &mdash; [Github](https://github.com/rawnly)
     - Parameters:
         - query: Search terms.
         - page: Page number to retrieve. (Default: 1)
         - perPage: Number of items per page. (Default: 10)
     
     - Returns: Void
     */
    public func searchCollections(
        query: String,
        page: Int = 1,
        per_page perPage: Int = 10,
        completion: @escaping DefaultCallback<[Unsplash.Collection]>
    ) {
        fetch(endpoint: "search/collections", params: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page < 1 ? 1 : page)"),
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
        ], completion: completion)
    }
    
    
    /**
     Search users
     
     Get a single page of user results for a query.
     
     - Author: [Federico Vitale](https://rawnly.com) &mdash; [Github](https://github.com/rawnly)
     - Parameters:
         - query: Search terms.
         - page: Page number to retrieve. (Default: 1)
         - perPage: Number of items per page. (Default: 10)
     
     - Returns: Void
     */
    public func searchUsers(
        query: String,
        page: Int = 1,
        per_page perPage: Int = 10,
        completion: @escaping DefaultCallback<[Unsplash.User]>
    ) {
        fetch(endpoint: "search/users", params: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page < 1 ? 1 : page)"),
            URLQueryItem(name: "per_page", value: "\(perPage > 30 ? 30 : perPage)"),
        ], completion: completion)
    }
}

/*
 * ------------------------
 * MARK: - Methods: Stats
 * ------------------------
 */
extension UnsplashAPIClient {
    public struct Stats {
        public struct Month: Decodable {
            let month_stats: Unsplash.Stats
        }
        
        public struct Total: Decodable {
            let total_stats: Unsplash.Stats
        }
    }
    
    /**
     Totals
     
     Get a list of counts for all of Unsplash.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     
     - Returns: Void
     */
    public func total(completion: @escaping DefaultCallback<Stats.Total>) {
        fetch(endpoint: "stats/total", completion: completion)
    }
    
    /**
     Month
     
     Get the overall Unsplash stats for the past 30 days.
     
     - Author: [Federico Vitale](https://github.com/rawnly)
     
     - Returns: Void
     */
    public func month(completion: @escaping DefaultCallback<Stats.Month>) {
        fetch(endpoint: "stats/month", completion: completion)
    }
}


/*
 * ----------------
 * MARK: - Helpers
 * ----------------
 */
extension UnsplashAPIClient {
    public enum Orientation:String {
        case landscape = "landscape"
        case portrait = "portrait"
        case squarish = "squarish"
    }
    
    public enum Order: String {
        case latest = "latest"
        case oldest = "oldest"
        case popular = "popular"
    }
    
    public enum Frequency: String {
        case days = "days"
    }
    
    /// Query filters for `getRandomPhoto` method
    public struct Filters {
        private(set) var query: String?
        private(set) var user: String?
        private(set) var collections: String?
        private(set) var count: String?
        private(set) var orientation: String?
        private(set) var featured: Bool?
        
        /**
         - Parameters:
             - query: Limit selection to photos matching a search term
             - user: Limit selection to a single user
             - count: The number of photos to return
             - collections: Public collection ID(‘s) to filter selection.
             - orientation: Filter search results by photo orientation. Valid values are landscape, portrait, and squarish
             - featured: Limit selection to featured photos
         */
        public init(
            collections:[String]?=nil,
            featured:Bool?=nil,
            user:String?=nil,
            query:String?=nil,
            orientation:Orientation?=nil,
            count:Int? = 1
        ) {
            self.collections = collections?.joined(separator: ",")
            self.featured = featured
            self.user = user
            self.query = query
            self.orientation = orientation?.rawValue
            self.count = count != nil ? "\(count!)" : nil
        }
        
        
        /**
         - Parameters:
             - query: Limit selection to photos matching a search term
             - user: Limit selection to a single user
             - count: The number of photos to return
             - collections: Public collection ID(‘s) to filter selection. If multiple, comma-separated
             - orientation: Filter search results by photo orientation. Valid values are landscape, portrait, and squarish
             - featured: Limit selection to featured photos
         */
        public init(
            collections:String?=nil,
            featured:Bool?=nil,
            user:String?=nil,
            query:String?=nil,
            orientation:Orientation?=nil,
            count:Int? = 1
        ) {
            self.collections = collections
            self.featured = featured
            self.user = user
            self.query = query
            self.orientation = orientation?.rawValue
            self.count = count != nil ? "\(count!)" : nil
        }
    }
}
