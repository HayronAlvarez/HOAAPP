//
//  PROGRAMMERS: Hayron Alvarez, Ariel Pentzke
//  PANTHERID'S: 5200111, 1364786
//  CLASS: COP 4655 RH1 & U01 TR 5:00
//  INSTRUCTOR: Steve Luis Online
//  ASSIGNMENT: Deliverable #2
//  DUE: Firday 12/11/20
//
//  This work is licensed under a Creative Commons Attribution 4.0 International License.
//  Details can be found under  https://creativecommons.org/licenses/by/4.0/
import UIKit

class ImageStore {
    
    let cache = NSCache<NSString,UIImage>()

    
    func setImage(_ image: UIImage, forKey key: String){
        cache.setObject(image, forKey: key as NSString)
        let url = imageURL(forKey: key)
        // this turns image into jpeg data
        if let data = image.jpegData(compressionQuality: 0.5){
            // this writes it to a full url
            try? data.write(to: url)
        }
    }
    //gets an image by the name
    func getImage(forKey key: String) ->UIImage? {
        if let existingImage = cache.object(forKey: key as NSString){
            return existingImage
        }
        let url = imageURL(forKey:key)
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
    
    func deleteImage(forKey key:String){
        cache.removeObject(forKey: key as NSString)
        let url = imageURL(forKey: key)
        do{
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk")
        }
    }
    
    func imageURL(forKey key: String) -> URL{
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
}
