//
//  ViewController.swift
//  CustomAlbumSwift
//
//  Created by Priyal Jain on 1/10/17.
//  Copyright © 2017 Priyal. All rights reserved.
//

/*
   Chat Link : http://chat.stackoverflow.com/rooms/132769/discussion-between-priyal-and-ricardopereira
 
   Question Link : http://stackoverflow.com/questions/12152430/iphone-how-to-create-a-custom-album-and-give-custom-names-to-photos-in-camera
 
 */

import UIKit
import Photos

class ViewController: UIViewController {
    let albumName = "CustomAlbum"
    var image = #imageLiteral(resourceName: "temp")
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // working once -->     self.createPhotoLibrary()
        self.requestAccess()
    }
    
    //MARK: Request Access
    func requestAccess() -> Void {
        PHPhotoLibrary.requestAuthorization {
            status  in
            switch(status) {
            case .notDetermined, .denied :
                print("Access not provided")
                break
                
            case .authorized , .restricted :
                print("Access provided")
                self.savePhoto()
                break
            }
        }
    }
    
    //MARK: Create Album
    func createPhotoLibrary() -> Void {
        var albumPlaceholder : PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges(
        {
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
            
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        },  completionHandler: { success, error in
            guard let placeholder = albumPlaceholder else {
                assert(false, "Album placeholder is nil")
            }
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
            guard (fetchResult.firstObject as  PHAssetCollection!) != nil else {
                    assert(false, "FetchResult has no PHAssetCollection")
                }
            print("Photo Library named " + self.albumName + " created successfully!!")
                self.savePhoto()
        })
    }
    
    // MARK: Fetch Album -->Working
    
    func fetchAlbum() -> PHAssetCollection? {
        let collection =  PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        
        //Check return value - If found, then get the first album out
        if let _: PHAssetCollection = collection.firstObject {
            print("In FetchAlbum method-- Album named :\(self.albumName) fetched succesfully")
           return collection.firstObject
        } else {
            print("In FetchAlbum method-- Album named :\(self.albumName) couldn't be fetched")
            return nil
        }

    }
    
    func savePhoto() -> Void {
        // check if album exists
        let album = self.fetchAlbum()
        if album != nil { // if exists then add photo
         self.savePhotoToAlbum(photo: self.image, album: album!)
        } else { // else create new album and add photo
            self.createPhotoLibrary()
        }
    }
    
    func savePhotoToAlbum(photo: UIImage, album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                // Album change request has failed
                return
            }
            // Get a placeholder for the new asset and add it to the album editing request
            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                // Photo Placeholder is nil
                return
            }
            albumChangeRequest.addAssets([photoPlaceholder] as NSArray)
        }, completionHandler: { success, error in
            if success {
                // Saved successfully!
                print("Saved Succesfully")
            }
            else if let e = error {
                // Save photo failed with error
                print("Error : ",e.localizedDescription)
            }
            else {
                // Save photo failed with no error
                print("Save failed")
            }
        })
    }
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        self.savePhoto()
    }
    
    /*
    // from :  http://stackoverflow.com/questions/27008641/save-images-with-phimagemanager-to-custom-album
     */
    
}



/*
 
 // Not useful
 

 func addImage() -> Void {
 let collection = self.fetchAlbum()
 if collection != nil {
 PHPhotoLibrary.shared().performChanges({
 let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: self.image!)
 let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection!)
 let objectPlaceholder = [assetChangeRequest.placeholderForCreatedAsset]
 albumChangeRequest?.addAssets(objectPlaceholder as NSFastEnumeration)
 }, completionHandler: { success, error in
 if success {
 print("Image added succesfully")
 } else {
 print("Error while saving image :", error!.localizedDescription)
 }
 })
 }  else {
 self.createPhotoLibrary()
 }
 
 }

 func saveImage(){
 self.image = UIImage.init(named: "xyz")
 
 PHPhotoLibrary.shared().performChanges({
 let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: self.image!)
 let assetPlaceholder = assetRequest.placeholderForCreatedAsset
 let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.fetchAlbum()!)
 albumChangeRequest?.addAssets([assetPlaceholder!] as NSArray)
 }, completionHandler: { success, error in
 if success {
 print("added image to album")
 } else {
 print("Couldn't fetch image --> ",error.debugDescription)
 }
 })
 }

 
 
 
 */

