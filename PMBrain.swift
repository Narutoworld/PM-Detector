//
//  File.swift
//  Project
//
//  Created by Billy Cai on 2017-07-11.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

import Foundation

struct PMBrain {
    var storedPicture: UIImage!
    var sliderMin: Double!
    var sliderMax: Double!
    
    var red:Double!
    var green:Double!
    var blue:Double!
    
    // 12.067R -14.561G -6.7336B + 0.022703RB + 767.92
    mutating func calculatePM(R:Double, G:Double, B:Double) -> Double{
        //        let PM = 12.067*R - 14.561*G - 6.7336*B + 0.022703*R*B + 767.92
        red = R
        green = G
        blue = B
        let PM = 623.56 - 41.261*R + 155.86*G - 123.37*B - 0.59413*R*G + 0.93567*R*B - 0.31814*G*B
        
        return PM*2
    }
    
    func calculateBC(R:Double, G:Double, B:Double) -> Int{
        let BC = 23.167-0.375*R-0.229*G+0.428*B-0.002*G*B+0.002*R*G
        return Int(BC*2)
    }
    // No.1
    func calculateAQI(pmAverage: Double) -> Double?{
        let parameter = defineParameterFromPMAverage(pmAverage: pmAverage)
        guard parameter != nil else {
            return nil
        }
        
        if let indexHigh = parameter?.indexHigh, let indexLow = parameter?.indexLow,
            let concentrationHigh = parameter?.concentrationHigh,
            let concentrationLow = parameter?.concentrationLow {
            return (indexHigh - indexLow)/(concentrationHigh - concentrationLow)*(pmAverage - concentrationLow)+indexLow
        }
        else{
            return nil
        }
    }
    // No.2
    func defineParameterFromPMAverage(pmAverage: Double) -> ParameterForAQI?{
        switch pmAverage {
        case 0.0...12.0:
            return ParameterForAQI(_indexLow: 0, _indexHeigh: 50, _concentrationLow: 0.0, _concentrationHigh: 12.0)
        case 12.1...35.4:
            return ParameterForAQI(_indexLow: 51, _indexHeigh: 100, _concentrationLow: 12.1, _concentrationHigh: 35.4)
        case 35.5...55.4:
            return ParameterForAQI(_indexLow: 101, _indexHeigh: 150, _concentrationLow: 35.5, _concentrationHigh: 55.4)
        case 55.5...150.4:
            return ParameterForAQI(_indexLow: 151, _indexHeigh: 200, _concentrationLow: 55.5, _concentrationHigh: 150.4)
        case 150.5...250.4:
            return ParameterForAQI(_indexLow: 201, _indexHeigh: 300, _concentrationLow: 150.5, _concentrationHigh: 250.4)
        case 250.5...350.4:
            return ParameterForAQI(_indexLow: 301, _indexHeigh: 400, _concentrationLow: 250.5, _concentrationHigh: 350.4)
        case 350.5...500.4:
            return ParameterForAQI(_indexLow: 401, _indexHeigh: 500, _concentrationLow: 350.5, _concentrationHigh: 500.4)
        default:
            return nil
        }
    }
    //No.3
    func selectAQIInformation(aqi:Double) -> AQIInfo? {
        switch aqi {
        case 0...50:
            return AQIInfo(_color: UIColor.green, _statements: "Good", _description: HealthImpactInfo.good.rawValue)
        case 51...100:
            return AQIInfo(_color: UIColor.yellow, _statements: "Moderate", _description: HealthImpactInfo.moderate.rawValue)
        case 101...150:
            return AQIInfo(_color: UIColor.orange, _statements: "Unhealthy for Sensitive Groups", _description: HealthImpactInfo.unhealthForSensitivePeople.rawValue)
        case 151...200:
            return AQIInfo(_color: UIColor.red, _statements: "Unhealthy", _description: HealthImpactInfo.unhealth.rawValue)
        case 201...300:
            return AQIInfo(_color: UIColor.purple, _statements: "Very Unhealthy", _description: HealthImpactInfo.veryUnhealth.rawValue)
        case 301...400:
            return AQIInfo(_color: UIColor(red: 0.50, green: 0.00, blue: 0.13, alpha: 1.00), _statements: "Hazardous", _description: HealthImpactInfo.Hazardous.rawValue)
        case 401...500:
            return AQIInfo(_color: UIColor(red: 0.50, green: 0.00, blue: 0.13, alpha: 1.00), _statements: "Hazardous", _description: HealthImpactInfo.Hazardous.rawValue)
        default:
            return nil
        }
    }
}

struct AQIInfo {
    init(){
        color = UIColor.gray
        statement = "Debug"
        description = "Debug purpose"
    }
    init(_color:UIColor, _statements: String ,_description: String){
        color = _color
        statement = _statements
        description = _description
    }
    let color:UIColor
    let statement: String
    let description: String
}

struct ParameterForAQI {
    init(_indexLow:Double, _indexHeigh:Double, _concentrationLow:Double, _concentrationHigh:Double){
        indexLow = _indexLow
        indexHigh = _indexHeigh
        concentrationLow = _concentrationLow
        concentrationHigh = _concentrationHigh
    }
    var indexLow:Double
    var indexHigh:Double
    var concentrationLow:Double
    var concentrationHigh:Double
}



enum HealthImpactInfo:String {
    case good = "None"
    case moderate = "Unusually sensitive people should consider reducing prolonged or heavy exertion."
    case unhealthForSensitivePeople = " Increasing likelihood of respiratory symptoms in sensitive individuals, aggravation of heart or lung disease and premature mortality in persons with cardiopulmonary disease and the elderly. "
    case unhealth = "Increased aggravation of heart or lung disease and premature mortality in persons with cardiopulmonary disease and the elderly; increased respiratory effects in general population."
    case veryUnhealth = "Significant aggravation of heart or lung disease and premature mortality in persons with cardiopulmonary disease and the elderly; significant increase in respiratory effects in general population."
    case Hazardous = "Serious aggravation of heart or lung disease and premature mortality in persons with cardiopulmonary disease and the elderly; serious risk of respiratory effects in general population."
}
