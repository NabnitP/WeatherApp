//
//  ViewController.swift
//  WeatherApp
//
//  Created by Nabnit Patnaik on 3/8/17.
//  Copyright © 2017 Nabnit Patnaik. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblCityNameTitle: UILabel!
    @IBOutlet weak var lblImgDescription: UILabel!
    @IBOutlet weak var imgWeatherIcon: UIImageView!
    @IBOutlet weak var lblCurrentTemperature: UILabel!
    @IBOutlet weak var txtCityName: UITextField!
    
    let MESSAGE_EMPTY_CITYNAME = "Please Enter the City Name to Search"
    let MESSAGE_INVALID_CITYNAME = "City Name is invalid. Please enter a valid City Name"
    
    var sharedSession = URLSession.shared
    var imgDesc = ""
    var minTemp = ""
    var maxTemp = ""
    var humidity = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        txtCityName.delegate = self
        preloadLastSearchedData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showAlert(msg:String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /*
     AutoLoad the data for the last searched city(if any)
     */
    func preloadLastSearchedData(){
        if let str = UserDefaults.standard.value(forKey: "cityName") as? String{
            txtCityName.text = str
            searchWeatherConditions(cityName: txtCityName.text!)
        }
     }

    @IBAction func onClickSearch(_ sender: Any) {
        // Checks for leading and trailing whitespaces
        let cityName = self.txtCityName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Checks for special characters and numbers. Only alphabets are allowed
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        if cityName == "" {
            showAlert(msg: MESSAGE_EMPTY_CITYNAME)
        }
        else if cityName?.rangeOfCharacter(from: characterset.inverted) != nil {
            showAlert(msg: MESSAGE_INVALID_CITYNAME)
        }
        else {
            self.searchWeatherConditions(cityName: cityName!)
            
        }
        self.txtCityName.text = ""
    }
    
    // Fetches the weather conditions for the CityName
    // Parameter cityName : name of the city for which the weather data is to be searched
    func searchWeatherConditions(cityName: String){

        //List of Paramters to be passed in the url request - Array of dictionaries [Parameterkey: Parameter_Values]
        // Added US after the city name by default
        let parameters:[String: Any] = [
            Constants.WeatherInfo_Parameter_Keys.CityName: cityName + ",US",
            Constants.WeatherInfo_Parameter_Keys.AppID: Constants.WeatherInfo_Parameter_Values.AppID]
        
        let request = NSURLRequest(url: Utils.CreateURLFromParameters(parameters: parameters) as URL)
        
        let task = self.sharedSession.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            guard error == nil else {
                NSLog("Error occured")
                return
            }
            guard let status = (response as? HTTPURLResponse)?.statusCode, status >= 200 && status < 300 else {
                NSLog("Bad response")
                DispatchQueue.main.async {
                    self.showAlert(msg: self.MESSAGE_INVALID_CITYNAME)
                }
                return
            }
            guard let data = data else {
                NSLog("bad data")
                return
            }
            // Start parsing the data received
            do {
                let parseResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let result = parseResult as? NSDictionary{
                        var countryName = "US"
                        if let sys = result["sys"] as? NSDictionary{
                            if let country = sys["country"] as? String{
                                countryName = country
                                if let name = result["name"] as? String{
                                    DispatchQueue.main.async {
                                        self.lblCityNameTitle.text = "Showing the Weather conditions in " + name + "," + countryName
                                    }

                            }
                        }
                                             }
                    if let mainDict = result["main"] as? NSDictionary{
                        if let currTemp = mainDict["temp"] as? Float, let minTemp = mainDict["temp_min"] as? Float, let maxTemp = mainDict["temp_max"] as? Float, let humidity = mainDict["humidity"] as? Float{
                            DispatchQueue.main.async {
                                self.lblCurrentTemperature.text = String(format:"%.1f",currTemp - 273.15)+" ºC"
                                self.minTemp = String(format:"%.1f",minTemp - 273.15)+" ºC"
                                self.maxTemp = String(format:"%.1f",maxTemp - 273.15)+" ºC"
                                self.humidity = String(format:"%.1f",humidity) + " %"

                                // Save the city name in user defaults
                                UserDefaults.standard.set(cityName, forKey: "cityName")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    }
                    else{
                        NSLog("Invalid response")
                    }
                    
                    // Get the weather description and weather icon
                    if let weatherInfoArray = result["weather"] as? NSArray{
                        if weatherInfoArray.count > 0{
                            // Only taking the 1st object of the array by default
                            if let weatherInfoDict = weatherInfoArray[0] as? NSDictionary{
                                if let desc = weatherInfoDict["description"] as? String{
                                    self.imgDesc = desc
                                }
                                if let iconName = weatherInfoDict["icon"] as? String{
                                    // Create the image url to download the image
                                    let imgURL = Utils.CreateImageURL(withImageName: iconName+".png") as URL
                                    self.downloadImage(url: imgURL)
                                }
                            }
                        }
                    }
                    else{
                        NSLog("Invalid response")
                    }
                }
                else{
                    NSLog("Invalid response")
                }
            }
            catch{
                return
            }
        })
        
        task.resume()
    }
    
    //MARK: Image download related methods
    // Download the image and set it as the icon image
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else {
                return
            }
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imgWeatherIcon.image = UIImage(data: data)
                self.lblImgDescription.text = self.imgDesc.capitalized + "\n \n" + "Minimum Temperature:    " + self.minTemp + "\n" + "Maximum Temperature:    " + self.maxTemp + "\n" + "Humidity:    " + self.humidity
            }
        }
    }

    // Get the Image data from the URL
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    //MARK:  - TextField delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }



}

