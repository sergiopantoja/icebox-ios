//
//  ShareViewController.swift
//  safari-extension
//
//  Created by Sergio Pantoja on 3/15/17.
//  Copyright © 2017 Sergio. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var statusLabel: UILabel!
    let host  = "https://youricebox.com" // must be an HTTPS endpoint
    let email = "you@gmail.com"
    let key   = "abc123"

    override func viewDidLoad() {
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
        let propertyList = String(kUTTypePropertyList)

        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList, options: nil, completionHandler: { (item, error) -> Void in
                let dictionary = item as! NSDictionary
                OperationQueue.main.addOperation {
                    let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    let urlString = results["url"] as? String
                    let titleString = results["title"] as? String
                    self.postData(title: titleString!, url: urlString!)
                }
            })
        }
    }

    func postData(title: String, url: String) {
        let dict = ["item": ["title": title, "url": url]] as [String: Any]
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {

            let url = NSURL(string: "\(self.host)/items")!
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(self.email, forHTTPHeaderField: "X-Api-Email")
            request.addValue(self.key, forHTTPHeaderField: "X-Api-Key")

            let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
                let message = (error == nil) ? "Done!" : "Error: \(error?.localizedDescription)"
                self.updateStatus(message: message)

                let delayInSeconds = 3.0
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
            }

            task.resume()
        }
    }

    func updateStatus(message: String) {
        // needs to execute on UI thread
        OperationQueue.main.addOperation({ () -> Void in
            self.statusLabel.text = message
        })
    }

}
