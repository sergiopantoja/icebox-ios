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

class ShareViewController: SLComposeServiceViewController {

    let host  = "https://youricebox.com" // must be an HTTPS endpoint
    let email = "you@gmail.com"
    let key   = "abc123"

    override func isContentValid() -> Bool {
        return true
    }

    override func configurationItems() -> [Any]! {
        return []
    }

    override func didSelectPost() {
        let extensionItem = extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = extensionItem.attachments?.first as! NSItemProvider
        let propertyList = String(kUTTypePropertyList)

        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList, options: nil, completionHandler: { (item, error) -> Void in
                let dictionary = item as! NSDictionary
                OperationQueue.main.addOperation {
                    let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    let urlString = results["currentUrl"] as? String
                    self.postData(title: self.contentText, url: urlString!)
                }
            })
        }

        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
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
                if error != nil {
                    print(error?.localizedDescription ?? "Unknown Error")
                    return
                }
            }

            task.resume()
        }
    }

}
