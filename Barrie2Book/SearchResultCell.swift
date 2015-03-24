//
//  SearchResultCell.swift
//  Barrie2Book
//
//  Created by Robin on 2015-03-04.
//  Copyright (c) 2015 Huibin Zhao. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    var downloadTask: NSURLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom selected cell color
        let selectedView = UIView(frame: CGRect.zeroRect)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        
        let downloadTask = session.downloadTaskWithURL(url, completionHandler: {
            [weak self] url, response, error in
            
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url) {
                    if let image = UIImage(data: data) {
                        dispatch_async(dispatch_get_main_queue()) {
                            if let strongSelf = self {
                                strongSelf.coverImage.image = image
                            }
                        }
                    }
                }
            }
        })
        
        downloadTask.resume()
        return downloadTask
    }
    
    func cellConfigue(book: Books) {
        titleLabel.text = book.title
        if let bookPrice = book.price {
            priceLabel.text = "$ \(bookPrice)"
        } else {
            priceLabel.text = ""
        }
        if let imageUrl = book.imageUrl {
            if let url = NSURL(string: imageUrl) {
                downloadTask = loadImageWithURL(url)
            }
        } else {
            coverImage.image = UIImage(named: "Placeholder")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
        
        titleLabel.text = nil
        priceLabel.text = nil
        coverImage.image = UIImage(named: "Placeholder")
    }
}