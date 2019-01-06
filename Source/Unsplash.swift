import Foundation

public struct Unsplash {
    public struct URLResponse: Decodable {
        public let url: URL?
    }

    
    public struct Stats: Decodable {
        public let photos: Int
        public let downloads: Int
        public let views: Int
        public let likes: Int
        public let photographers: Int
        public let pixels: Int
        public let downloads_per_second: Int
        public let views_per_second: Int
        public let developers: Int
        public let applications: Int
        public let requests: Int
    }
    
    public struct StatsResponse: Decodable {
        struct Detail: Decodable {
            struct Historical: Decodable {
                struct Value: Decodable {
                    public let date: String
                    public let value: Int
                }
                
                public let change: Int
                public let average: Int
                public let resolution: String
                public let quantity: Int
                public let values: [Value]
            }
            
            public let total: Int
            public let historical: Historical
        }
        
        public let username: String
        public let downloads: Detail
        public let views: Detail
        public let likes: Detail
    }

    public struct Photo:Decodable {
        public enum PictureSize {
            case thumb
            case small
            case regular
            case raw
        }
        
        public struct Exif:Decodable {
            public let make: String?
            public let model: String?
            public let exposure_time: String?
            public let aperture: String?
            public let focal_length: String?
            public let iso: Int?
        }
        
        public struct URLS: Decodable {
            public let raw: URL
            public let full: URL
            public let regular: URL
            public let small: URL
            public let thumb: URL
        }
        
        
        public struct Location: Decodable {
            public struct Coords: Decodable {
                public let latitude: Double?
                public let longitude: Double?
            }
            
            public let city: String?
            public let country: String?
            public let position: Coords
        }
        
        public struct Links:Decodable {
            public let `self`:String
            public let html:String
            public let download:String
            public let download_location:String
        }
        
        public let id:String
        public let created_at: String
        public let updated_at: String
        public let width: Double
        public let height: Double
        public let color: String
        public let likes: Int
        public let liked_by_user: Bool
        public let description: String?
        public let categories: [String]
        public let slug: String?
        
        
        public let links: Links
        public let urls: URLS
        public let user: User
        public let exif: Exif?
        
        public let views: Int?
        public let downloads: Int?
        
        public func getURL(ofSize size: PictureSize = .regular) -> URL {
            public let urls = self.urls
            
            switch size {
            case .thumb:
                return urls.thumb
            case .small:
                return urls.small
            case .regular:
                return urls.regular
            case .raw:
                return urls.raw
            }
        }
    }
    
    
    public struct User:Decodable {
        struct Links:Decodable {
            public let `self`:    URL
            public let html:      URL
            public let photos:    URL
            public let likes:     URL
            public let portfolio: URL
            public let following: URL
            public let followers: URL
        }
        
        public struct ProfilePicure: Decodable {
            public let small: String
            public let medium:String
            public let large: String
        }
                        
        public let id: String
        public let username: String
        public let name: String?
        public let first_name:String?
        public let last_name:String?
        public let twitter_username:String?
        public let instagram_username:String?
        public let portfolio_url: URL?
        public let bio: String?
        public let location: String?
        public let total_likes: Int
        public let total_photos: Int
        public let total_collections: Int
        public let accepted_tos: Bool?
        
        public let links: Links
    }
    
    public struct Collection:Decodable {
        public struct PreviewPhoto: Decodable {
            public let id: String
            public let urls: Photo.URLS
        }
        
        public struct Meta:Decodable {
            public let title:String?
            public let description:String?
            public let index: Int?
            public let canonical:Bool?
        }
        
        public struct Links: Decodable {
            public let `self`:  URL
            public let html:    URL
            public let photos:  URL
            public let related: URL
        }
        
        public struct Tag:Decodable {
            public let title: String
            
            public init(title: String) {
                self.title = title
            }
        }
        
        public let id:Int
        public let title:String
        public let description:String?
        public let published_at:String
        public let updated_at:String
        public let curated:Bool
        public let featured:Bool
        public let total_photos:Int
        public let `private`:Bool
        public let share_key:String?
        
        
        public let links: Links?
        public let cover_photo: Photo?
        public let tags: [Tag]?
    }
}

