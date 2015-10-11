//
//  MemeEditorVC.swift
//  imageTest
//
//  Created by Ekstasis on 9/16/15.
//  Copyright (c) 2015 Ekstasis. All rights reserved.
//

import UIKit

// Extension that gives bounds of the image that was picked from album/camera
extension UIImageView {

    func displayedImageFrame() -> CGRect {
        
        let boundsWidth = bounds.size.width
        let boundsHeight = bounds.size.height
        let imageSize = image!.size
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = boundsWidth / boundsHeight
        if ( viewRatio > imageRatio ) {
            let scale = boundsHeight / imageSize.height
            let width = scale * imageSize.width
            let topLeftX = (boundsWidth - width) * 0.5
//            let topLeftX = CGFloat(0.0)
            return CGRectMake(topLeftX, 0, width, boundsHeight)
        }
        let scale = boundsWidth / imageSize.width
        let height = scale * imageSize.height
        let topLeftY = (boundsHeight - height) * 0.5
//        let topLeftY = CGFloat(0.0)
        return CGRectMake(0, topLeftY, boundsWidth,height)
    }
}

class MemeEditorVC: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toggleAspectButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextVerticalConstraint: NSLayoutConstraint!
    
    var memeIndex : Int? // Used for editing meme rather than creating one
// var meme : Meme!
    var memedImage : UIImage!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // only slide view up when editing bottom text
    var bottomTextIsBeingEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(picView.bounds)    //////
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // picView.clipsToBounds = true
        setMemeTextAttributes()
         if let index = memeIndex {
            let meme = appDelegate.allMemes[index]  // otherwise it's a new meme
            picView.image = meme.image
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
        }
        print("viewdidload")
        print(picView.bounds)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        print(picView.bounds) /////////
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        
        shareButton.enabled = (picView.image != nil)
        
//        navigationController?.navigationBarHidden = true
        
        subscribeToKeyboardNotification()
               print(picView.bounds)
        if memeIndex != nil {
            positionTextFields()
        }
        
//        topTextField.setNeedsDisplay()
//        picView.setNeedsDisplay()
//        view.setNeedsDisplay()
//       picView.layer.setNeedsDisplay()
//       topTextField.layer.setNeedsDisplay()
//       view.layer.setNeedsDisplay()
       print("viewWillAppear")
                print(picView.bounds)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotification()
    }
    
//    func shouldEnableTopButtons(enabledOrNot: Bool) {
//        shareButton.enabled = enabledOrNot
//    }
//    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        print("pickImageIBin", picView.bounds)
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
        print("pickImageIBout", picView.bounds)
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func positionTextFields() {
        print(picView.bounds)
        print("positionTextFields", picView.frame)
        
        picView.setNeedsLayout()
        picView.layoutIfNeeded()
        let imageBounds = picView.displayedImageFrame()
        
        topTextVerticalConstraint.constant = 0
        bottomTextVerticalConstraint.constant = 0
        
        
        topTextVerticalConstraint.constant = imageBounds.origin.y
        
//        print(topTextVerticalConstraint.constant)
        
        bottomTextVerticalConstraint.constant = -(picView.bounds.height - imageBounds.height) / 2
        
        print(bottomTextVerticalConstraint.constant)
        topTextField.hidden = false
        bottomTextField.hidden = false
//        picView.updateConstraints()
//        topTextField.updateConstraints()
//        view.updateConstraints()
        print(picView.frame)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        topTextField.hidden = true
        bottomTextField.hidden = true
        coordinator.animateAlongsideTransition(nil, completion: { context in
            self.positionTextFields() } )
    }
    
    @IBAction func showActivity(sender: UIBarButtonItem) {
        
        memedImage = renderMeme()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { (activity, success, items, error) in
            if success {
                self.saveMeme()
            }
        }
        
        presentViewController(activityVC, animated: true, completion: nil)
        
        //        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
        //            presentViewController(activityVC, animated: true, completion: nil)
        //        } else {
        //            let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
        //            popup.presentPopoverFromBarButtonItem(shareButton, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
        //        }
    }
    
    func saveMeme() {
        let newMeme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: picView.image!, memedImage: memedImage)
        if let index = memeIndex {
            appDelegate.allMemes[index] = newMeme     // resave edited meme
        } else {
            appDelegate.allMemes.append(newMeme)      // new meme
        }
        appDelegate.saveMemes()
    }
    
    func renderMeme() -> UIImage {
        
        // Get bounds of album image only
        let imageBounds = picView.displayedImageFrame()
       
        print("image.size:  \(picView.image!.size)")
        print("imagebounds: \(imageBounds)")
        print("picview bounds: \(picView.bounds)")
        
        // take snapshot of image -- returns a UIView, not an image
        let imageY = imageBounds.origin.y + picView.frame.origin.y
        let imageX = imageBounds.origin.x
        let imageOrigin = CGPoint(x: imageX, y: imageY)
        let imageRect = CGRect(origin: imageOrigin, size: imageBounds.size)
        let renderedImageView = view.resizableSnapshotViewFromRect(imageRect, afterScreenUpdates: true, withCapInsets:  UIEdgeInsetsZero)
        
        // convert snapshot UIView to UIImage
        UIGraphicsBeginImageContext(imageBounds.size)
        renderedImageView.drawViewHierarchyInRect(renderedImageView.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("memedimagesize: \(memedImage.size)")
        return memedImage
        
//        let picViewOriginalBounds = picView.bounds
//        UIGraphicsBeginImageContext(imageBounds.size)
//        picView.bounds = imageBounds
//        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        picView.bounds = picViewOriginalBounds
//        return memedImage
    }
    
    @IBAction func userCanceledEdit(sender: UIBarButtonItem) {
//        picView.image = nil
//        topTextField.text = nil
//        bottomTextField.text = nil
//        
//        shouldEnableTopButtons(false)
//       navigationController?.popViewControllerAnimated(true)
        
        // Returns to Sent Memes as per Rubrick unless editing previous meme in which case return to detail view
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unSubscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:  NSNotification) {
        if bottomTextIsBeingEdited {
            
            view.frame.origin.y = 0
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification:  NSNotification) {
        if bottomTextIsBeingEdited {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let notificationInfo = notification.userInfo!
        let keyboardHeight = notificationInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardHeight.CGRectValue().height
    }
    
    func setMemeTextAttributes() {
        let memeMeTextAttributes : [String : AnyObject]  = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -5.0
        ]
        topTextField.defaultTextAttributes = memeMeTextAttributes
        bottomTextField.defaultTextAttributes = memeMeTextAttributes
        
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        topTextField.attributedPlaceholder = NSAttributedString(string: "Top", attributes: memeMeTextAttributes)
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "Bottom", attributes: memeMeTextAttributes)
    }
    
    
    
    /*
    *   Delegate Functions
    */
    
    // Image Picker Delegate Functions
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        print(picView.bounds)
        let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        picView.image = pickedImage
        dismissViewControllerAnimated(true, completion: nil)
        positionTextFields()
        
        shareButton.enabled = true
        print("end of image picker", picView.bounds)
    }
    
    // Text Field Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        // Tells keyboardWillShow whether to shift view up
        bottomTextIsBeingEdited = (textField == bottomTextField)
        
        return true
    }
}

