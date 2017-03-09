//
//  Constants.swift
//  WeatherApp
//
//  Created by Nabnit Patnaik on 3/8/17.
//  Copyright © 2017 Nabnit Patnaik. All rights reserved.
//

import Foundation

struct Constants {
    struct ImageInfo{
        static let apiImgScheme = "http"
        static let apiImgHostName = "openweathermap.org"
        static let apiImgPath = "/img/w"
    }
    
    struct WeatherInfo {
        static let apiScheme = "http"
        static let apiHostName = "api.openweathermap.org"
        static let apiPath = "/data/2.5/weather"
    }

    struct WeatherInfo_Parameter_Keys {
        static let AppID = "APPID"
        static let CityName = "q"
    }
    
    struct WeatherInfo_Parameter_Values {
        static let AppID = "90d23f2456eb166229890c9ac2e7c33c"
        static let CityName = "London"
    }

}

