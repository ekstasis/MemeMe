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

    func displayedImageBounds() -> CGRect {
        
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
//    enum AspectMode {
//        case Fill, Fit
//    }
    
    var memeIndex : Int? // Used for editing meme rather than creating one
    var meme : Meme!
    var memedImage : UIImage!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var imageBounds : CGRect? {
        guard picView.image != nil else {
            return nil
        }
        return picView.displayedImageBounds()
    }
    
    // only slide view up when editing bottom text
    var bottomTextIsBeingEdited = false
    
    // used for toggling aspect fit vs fill
//    var aspectMode : AspectMode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        shouldEnableTopButtons(false)
        // picView.clipsToBounds = true
        setMemeTextAttributes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        subscribeToKeyboardNotification()
        if let index = memeIndex {
            meme = appDelegate.allMemes[index]  // otherwise it's a new meme
        }
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotification()
    }
    
    func shouldEnableTopButtons(enabledOrNot: Bool) {
        shareButton.enabled = enabledOrNot
    }
    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func positionTextFields() {
//        topTextField.removeConstraint(topTextVerticalConstraint)
//        let topTextTopOfImageConstraint = NSLayoutConstraint(item: topTextField, attribute: .Top, relatedBy: .Equal, toItem: picView.image!, attribute: .Equal, multiplier: 1, constant: -10)
//        let topTextTopOfImageConstraint = NSLayoutConstraint(item: picView.image!, attribute: .Top, relatedBy: .Equal, toItem: topTextField, attribute: .Top, multiplier: 1, constant: -10)
//        topTextField.addConstraint(topTextTopOfImageConstraint)
//        let newTopTextY = imageBounds!.origin.y + 10
//        let newBottomTextY = imageBounds!.origin.y + imageBounds!.size.height - topTextField.bounds.height - 10
//        topTextField.frame.origin.y = newTopTextY
//        bottomTextField.frame.origin.y = newBottomTextY
        
        topTextVerticalConstraint.constant = 0
        bottomTextVerticalConstraint.constant = 0
        
        topTextVerticalConstraint.constant = imageBounds!.origin.y
        bottomTextVerticalConstraint.constant = -(picView.bounds.height - imageBounds!.height) / 2
        print(bottomTextVerticalConstraint.constant)
        topTextField.hidden = false
        bottomTextField.hidden = false
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
                self.dismissViewControllerAnimated(true, completion: nil)
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
            appDelegate.allMemes[index] = newMeme     // editing meme
        } else {
            appDelegate.allMemes.append(newMeme)      // new meme
        }
        appDelegate.saveMemes()
    }
    
    func renderMeme() -> UIImage {
        
        // Get bounds of album image only
       
        print("image.size:  \(picView.image!.size)")
        print("imagebounds: \(imageBounds)")
        print("picview bounds: \(picView.bounds)")
        
        // take snapshot of image -- returns a UIView, not an image
        let renderedImageView = picView.resizableSnapshotViewFromRect(imageBounds!, afterScreenUpdates: true, withCapInsets:  UIEdgeInsetsZero)
        
        // convert snapshot UIView to UIImage
        UIGraphicsBeginImageContext(imageBounds!.size)
        renderedImageView.drawViewHierarchyInRect(renderedImageView.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("memedimagesize: \(memedImage.size)")
        return memedImage
    }
    
    @IBAction func userCanceledEdit(sender: UIBarButtonItem) {
//        picView.image = nil
//        topTextField.text = nil
//        bottomTextField.text = nil
//        
//        shouldEnableTopButtons(false)
//       navigationController?.popViewControllerAnimated(true)
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
        let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        picView.image = pickedImage
        dismissViewControllerAnimated(true, completion: nil)
        positionTextFields()
        
        shouldEnableTopButtons(true)
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

