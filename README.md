# Unsplash API Client
> Unsplash API wrapper written in Swift

## Description
**UnsplashAPIClient** (name will change soon... hopefully) it's a library to easy access [Unsplash](https://unsplash.com/)'s API

## Example Usage
The following code is an example implementation inside a `ViewController`:
```swift
import UIKit
import UnsplashAPIClient

class ViewController: UIViewController {
    let api: UnsplashAPIClient = UnsplashAPIClient(
        accessKey: "YOUR_ACCESS_KEY",
        secretKey: "YOUR_SECRET_KEY"
    )
    
    var background: UIImageView = UIImageView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()        
        getBackground()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.getBackground))
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - UI Setup 
    func setupUI() {
        background.backgroundColor = .red
        background.contentMode = .scaleAspectFill

        view.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController {
    @objc func getBackground() {
        api.getRandomPhoto { (photo, statusCode) in
            guard let photo = photo else { return }
            
            if let url = photo.getURL(ofSize: .regular) {
                 DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)
                            self.background.image = image
                            
                            let alert = UIAlertController(title: "Background changed", message: "Photo changed to #\(photo.id)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                } 
            }
        }
    }
}
```

### ⚠️Note
Since the latest release is flagged as `pre-release` it's not production-ready.
Please report any bug/issue.

## Installation via **Carthage**
UnsplashAPIClient is available through Carthage. To install just write into your `Cartfile`:
```
  github "rawnly/UnsplashAPIClient"
```
You also need to add `UnsplashAPIClient.framework` in your copy-frameworks script.

## Installation via **Pods**
> Coming Soon

## Related
- [**Splash CLI**](https://github.com/splasg-cli/splash-cli) - Beautiful wallpapers from Unsplash

## Author
- [Federico Vitale](https://rawnly.com) ([@Rawnly](https://github.com/rawnly))

## Contributing
I would love you to contribute to **UnsplashAPIClient**, check the [CONTRIBUTING](CONTRIBUTING.md) file for more info.

##  License
**UnsplashAPIClient** is available under the MIT license. See the [LICENSE](LICENSE.md) file for more info.


