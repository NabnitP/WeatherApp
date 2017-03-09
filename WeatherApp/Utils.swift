//
//  Utils.swift
//  WeatherApp
//
//  Created by Nabnit Patnaik on 3/9/17.
//  Copyright © 2017 Nabnit Patnaik. All rights reserved.
//

import Foundation

class Utils {
    // Creates the URL from the parameters passed
    class func CreateURLFromParameters(parameters:[String: Any]) -> NSURL {
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = Constants.WeatherInfo.apiScheme
        urlComponents.host = Constants.WeatherInfo.apiHostName
        urlComponents.path = Constants.WeatherInfo.apiPath
        urlComponents.queryItems = [NSURLQueryItem]() as [URLQueryItem]?
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems?.append(queryItem as URLQueryItem)
        }
//        NSLog("\(urlComponents.url)")
        return urlComponents.url! as NSURL
    }
    
    // Creates the Image URL from the image name passed
    class func CreateImageURL(withImageName:String) -> NSURL {
        let imageNameFull = "/"+withImageName
        let urlComponents = NSURLComponents()
        urlComponents.scheme = Constants.ImageInfo.apiImgScheme
        urlComponents.host = Constants.ImageInfo.apiImgHostName
        urlComponents.path = Constants.ImageInfo.apiImgPath + (imageNameFull )
        
//        NSLog("\(urlComponents.url)")
        return urlComponents.url! as NSURL
    }
}
