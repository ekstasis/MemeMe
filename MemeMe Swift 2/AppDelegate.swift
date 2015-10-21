//
//  AppDelegate.swift
//  MemeMe Swift 2
//
//  Created by Ekstasis on 9/24/15.
//  Copyright © 2015 Baxter Heavy Industries. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var allMemes = [Meme]()
    
//    func saveMemes() {
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        let nsMutableArrayForMemes = NSMutableArray()
//        
//        // Convert Meme structs to classes to allow saving to NSUserDefaults
//        for meme in allMemes {
//            let memeClass = SentMemeWrapper(inMeme: meme)
//            nsMutableArrayForMemes.addObject(memeClass)
//        }
//        
//        let memesArchiveData = NSKeyedArchiver.archivedDataWithRootObject(nsMutableArrayForMemes)
//        userDefaults.setObject(memesArchiveData, forKey: "Sent Memes")
//    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        /*
        *     Load sent memes.  Tapdancing because Rubrick requires Meme struct, not class.
        *     Meme structs were converted to NSCoding classes and added to NSMutableArray.
        *     SentMemeWrapper class has method to output a Meme struct.
        */
//        if let memesData = userDefaults.objectForKey("Sent Memes") as? NSData {
//            
//            let memesNSArray = NSKeyedUnarchiver.unarchiveObjectWithData(memesData) as! NSMutableArray
//            
//            for memeObject in memesNSArray {
//                let meme = memeObject as! SentMemeWrapper
//                allMemes.append(meme.convertToStruct())
//            }
//        }
        return true
    }
}

