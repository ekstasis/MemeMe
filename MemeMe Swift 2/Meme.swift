//
//  Meme.swift
//  MemeMe
//
//  Created by Ekstasis on 9/18/15.
//  Copyright (c) 2015 Ekstasis. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    let topText : String
    let bottomText : String
    let image : UIImage
    let memedImage : UIImage
}

class SentMemeWrapper : NSObject, NSCoding {
    var topText : String
    var bottomText : String
    var image : UIImage
    var memedImage : UIImage
    
    func convertToStruct() -> Meme {
        return Meme(topText: topText, bottomText: bottomText, image: image, memedImage: memedImage)
    }
    
    init(inMeme : Meme) {
        topText = inMeme.topText
        bottomText = inMeme.bottomText
        image = inMeme.image
        memedImage = inMeme.memedImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        topText = aDecoder.decodeObjectForKey("topText") as! String
        bottomText = aDecoder.decodeObjectForKey("bottomText") as! String
        image = aDecoder.decodeObjectForKey("image") as! UIImage
        memedImage = aDecoder.decodeObjectForKey("memedImage") as! UIImage
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(topText, forKey: "topText")
        aCoder.encodeObject(bottomText, forKey: "bottomText")
        aCoder.encodeObject(image, forKey: "image")
        aCoder.encodeObject(memedImage, forKey: "memedImage")
    }
}