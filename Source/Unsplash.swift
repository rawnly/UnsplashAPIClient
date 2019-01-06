import Foundation

public struct Unsplash {
    public struct URLResponse: Decodable {
        let url: URL?
    }

    
    public struct Stats: Decodable {
        let photos: Int
        let downloads: Int
        let views: Int
        let likes: Int
        let photographers: Int
        let pixels: Int
        let downloads_per_second: Int
        let views_per_second: Int
        let developers: Int
        let applications: Int
        let requests: Int
    }
    
    public struct StatsResponse: Decodable {
        struct Detail: Decodable {
            struct Historical: Decodable {
                struct Value: Decodable {
                    let date: String
                    let value: Int
                }
                
                let change: Int
                let average: Int
                let resolution: String
                let quantity: Int
                let values: [Value]
            }
            
            let total: Int
            let historical: Historical
        }
        
        let username: String
        let downloads: Detail
        let views: Detail
        let likes: Detail
    }

    public struct Photo:Decodable {
        public enum PictureSize {
            case thumb
            case small
            case regular
            case raw
        }
        
        public struct Exif:Decodable {
            let make: String?
            let model: String?
            let exposure_time: String?
            let aperture: String?
            let focal_length: String?
            let iso: Int?
        }
        
        public struct URLS: Decodable {
            let raw: URL
            let full: URL
            let regular: URL
            let small: URL
            let thumb: URL
        }
        
        
        public struct Location: Decodable {
            public struct Coords: Decodable {
                let latitude: Double?
                let longitude: Double?
            }
            
            let city: String?
            let country: String?
            let position: Coords
        }
        
        public struct Links:Decodable {
            let `self`:String
            let html:String
            let download:String
            let download_location:String
        }
        
        let id:String
        let created_at: String
        let updated_at: String
        let width: Double
        let height: Double
        let color: String
        let likes: Int
        let liked_by_user: Bool
        let description: String?
        let categories: [String]
        let slug: String?
        
        
        let links: Links
        let urls: URLS
        let user: User
        let exif: Exif?
        
        let views: Int?
        let downloads: Int?
        
        public func getURL(ofSize size: PictureSize = .regular) -> URL {
            let urls = self.urls
            
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
            let `self`:    URL
            let html:      URL
            let photos:    URL
            let likes:     URL
            let portfolio: URL
            let following: URL
            let followers: URL
        }
        
        public struct ProfilePicure: Decodable {
            let small: String
            let medium:String
            let large: String
        }
                        
        let id: String
        let username: String
        let name: String?
        let first_name:String?
        let last_name:String?
        let twitter_username:String?
        let instagram_username:String?
        let portfolio_url: URL?
        let bio: String?
        let location: String?
        let total_likes: Int
        let total_photos: Int
        let total_collections: Int
        let accepted_tos: Bool?
        
        let links: Links
    }
    
    public struct Collection:Decodable {
        public struct PreviewPhoto: Decodable {
            let id: String
            let urls: Photo.URLS
        }
        
        public struct Meta:Decodable {
            let title:String?
            let description:String?
            let index: Int?
            let canonical:Bool?
        }
        
        public struct Links: Decodable {
            let `self`:  URL
            let html:    URL
            let photos:  URL
            let related: URL
        }
        
        public struct Tag:Decodable {
            let title: String
            
            public init(title: String) {
                self.title = title
            }
        }
        
        let id:Int
        let title:String
        let description:String?
        let published_at:String
        let updated_at:String
        let curated:Bool
        let featured:Bool
        let total_photos:Int
        let `private`:Bool
        let share_key:String?
        
        
        let links: Links?
        let cover_photo: Photo?
        let tags: [Tag]?
    }
}

