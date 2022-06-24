//
//  ViewController.swift
//  Weather
//
//  Created by NakHyun Kim on 2022/06/23.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configureView(weatherInformation: WeatherInformation){
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))°C"
        self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))°C"
    }

    func showAlert(message: String){
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true)
        
    }
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=bc1d36befade851b46c84f928218561f") else { return }
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { [weak self] data, response, error in
            let succesRange = (200..<300)
            
            guard let data = data , error == nil else { return }
            let decoder = JSONDecoder()
            if let response = response as? HTTPURLResponse, succesRange.contains(response.statusCode){
                let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data)
                guard let weatherInformation = weatherInformation else { return }
                DispatchQueue.main.async {
                    self?.stackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            }else{
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
            
        }.resume()
    }

    @IBAction func tapFetchWeatherButton(_ sender: Any) {
        
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
}

