//
//  ViewController.swift
//  Izone
//
//  Created by Ahmad Syahir on 07/05/2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var onOffSwitch: UISwitch!
    @IBOutlet var btnMode: UIButton!
    @IBOutlet var btnSpeed: UIButton!
    @IBOutlet var tempStepper: UIStepper!
    @IBOutlet var temperatureLabel: UILabel!
    
    @IBOutlet var loadingOnOff: UIActivityIndicatorView!
    @IBOutlet var loadingMode: UIActivityIndicatorView!
    @IBOutlet var loadingSpeed: UIActivityIndicatorView!
    @IBOutlet var loadingTemp: UIActivityIndicatorView!
    
    var currMode = "COOL"
    var currSpeed = "LOW"
    var currTemp = 15
    var currIsOn = false

    var isLoadingOnOff = false
    var isloadingMode = false
    var isloadingSpeed = false
    var isloadingTemp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let menuMode = {(action: UIAction) in
            self.changeMode(action: action.title)
        }
        btnMode.menu = UIMenu(children: [
            UIAction(title: "COOL", state: .on, handler:
                        menuMode),
            UIAction(title: "HEAT", handler: menuMode),
            UIAction(title: "VENT", handler: menuMode),
            UIAction(title: "DRY", handler: menuMode),

        ])
        btnMode.showsMenuAsPrimaryAction = true
        btnMode.changesSelectionAsPrimaryAction = true

        let menuSpeed = {(action: UIAction) in
            self.changeSpeed(action: action.title)
        }
        
        btnSpeed.menu = UIMenu(children: [
            UIAction(title: "LOW", state: .on, handler:
                        menuSpeed),
            UIAction(title: "MEDIUM", handler: menuSpeed),
            UIAction(title: "HIGH", handler: menuSpeed),
            UIAction(title: "AUTO", handler: menuSpeed),

        ])
        btnSpeed.showsMenuAsPrimaryAction = true
        btnSpeed.changesSelectionAsPrimaryAction = true

   
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getACStatus()
    }
    
    
    
    @IBAction func switchChanged(_ sender: Any) {
        
        if(!isLoadingOnOff){

            self.onOffSwitch.isEnabled = false
            self.isLoadingOnOff = true
            self.loadingOnOff.startAnimating()
            
            currIsOn = onOffSwitch.isOn
            var val = [String: Any]()
            
            if(currIsOn){
                val["SysOn"] = 1
            }else{
                val["SysOn"] = 0
            }

            guard let jsonString = val.toJSONString() else {
               return
            }
            
            ACControllerAPI().setACValue(val: jsonString) { response in
                print(response)
                DispatchQueue.main.async {
                    self.loadingOnOff.stopAnimating()
                    self.isLoadingOnOff = false
                    self.onOffSwitch.isEnabled = true
                }
         
            } onError: { error in
                print(error)
                DispatchQueue.main.async {
                    self.loadingOnOff.stopAnimating()
                    self.isLoadingOnOff = false
                    self.onOffSwitch.isEnabled = true
                    
                    self.currIsOn = !self.onOffSwitch.isOn
                    self.onOffSwitch.setOn(self.currIsOn, animated: true)
                    
                    self.popUpStatusErrorGeneral(message: "Fail to set power. Please try again.")
                }
            }
        }
        

    }
    
    
    @IBAction func tempStepperChanged(_ sender: Any) {
        
        if(!isloadingTemp){
            loadingTemp.startAnimating()
            isloadingTemp = true
            tempStepper.isEnabled = false
            
            let aTemp = Int(tempStepper.value)
            temperatureLabel.text = String(format: "%d", aTemp) + "°C"
            
            var val = [String: Any]()
            val["SysSetpoint"] = aTemp * 100
            
            guard let jsonString = val.toJSONString() else {
               return
            }
            
            ACControllerAPI().setACValue(val: jsonString) { response in
                print(response)
                DispatchQueue.main.async {
                    self.loadingTemp.stopAnimating()
                    self.isloadingTemp = false
                    self.tempStepper.isEnabled = true
                    
                    self.currTemp = aTemp
                }
            } onError: { error in
                print(error)
                DispatchQueue.main.async {
                    self.loadingTemp.stopAnimating()
                    self.isloadingTemp = false
                    self.tempStepper.isEnabled = true
                    
                    self.temperatureLabel.text = String(format: "%d", self.currTemp) + "°C"
                    self.tempStepper.value = Double(self.currTemp)
                    
                    self.popUpStatusErrorGeneral(message: "Fail to set temperature. Please try again.")
                }
            }
            
        }
        
        
      
    }
    
    func changeMode(action:String){
        
        if(!isloadingMode){
            loadingMode.startAnimating()
            isloadingMode = true
            btnMode.isEnabled = false
            
            var val = [String: Any]()
            
            if(action == "COOL"){
                val["SysMode"] = 1
            }else  if(action == "HEAT"){
                val["SysMode"] = 2
            }else if(action == "VENT"){
                val["SysMode"] = 3
            }else if(action == "DRY"){
                val["SysMode"] = 4
            }
            
            guard let jsonString = val.toJSONString() else {
               return
            }
            
            ACControllerAPI().setACValue(val: jsonString) { response in
                print(response)
                DispatchQueue.main.async {
                    self.loadingMode.stopAnimating()
                    self.isloadingMode = false
                    self.btnMode.isEnabled = true
                    
                    self.currMode = action
                }

            } onError: { error in
                print(error)
                DispatchQueue.main.async {
                    self.loadingMode.stopAnimating()
                    self.isloadingMode = false
                    self.btnMode.isEnabled = true
                    
                    if let actionMode = self.btnMode.menu?.children.first(where: { $0.title ==  self.currMode }) as? UIAction {
                        actionMode.state = .on
                    }
                    
                    self.popUpStatusErrorGeneral(message: "Fail to set mode. Please try again.")
                }
            }
        }
        
      
    }
    
    func changeSpeed(action:String){
        
        if(!isloadingSpeed){
            loadingSpeed.startAnimating()
            isloadingSpeed = true
            btnSpeed.isEnabled = false
            
            var val = [String: Any]()
            
            if(action == "LOW"){
                val["SysFan"] = 1
            }else  if(action == "MEDIUM"){
                val["SysFan"] = 2
            }else if(action == "HIGH"){
                val["SysFan"] = 3
            }else if(action == "AUTO"){
                val["SysFan"] = 4
            }
            
            guard let jsonString = val.toJSONString() else {
               return
            }
            
            ACControllerAPI().setACValue(val: jsonString) { response in
                print(response)
                DispatchQueue.main.async {
                    self.loadingSpeed.stopAnimating()
                    self.isloadingSpeed = false
                    self.btnSpeed.isEnabled = true
                    self.currSpeed = action
                }
            } onError: { error in
                print(error)
                DispatchQueue.main.async {
                    self.loadingSpeed.stopAnimating()
                    self.isloadingSpeed = false
                    self.btnSpeed.isEnabled = true
                    
                    if let actionSpeed = self.btnSpeed.menu?.children.first(where: { $0.title ==  self.currSpeed }) as? UIAction {
                        actionSpeed.state = .on
                    }
                    
                    self.popUpStatusErrorGeneral(message: "Fail to set speed. Please try again.")
                }
            }
        }
        
    }
    
    func getACStatus(){
        
        loadingOnOff.startAnimating()
        loadingMode.startAnimating()
        loadingSpeed.startAnimating()
        loadingTemp.startAnimating()
        
        onOffSwitch.isEnabled = false
        btnMode.isEnabled = false
        btnSpeed.isEnabled = false
        tempStepper.isEnabled = false
        
        ACControllerAPI().getStatus { response in
            if let jsonData = response.data(using: .utf8) {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonDictionary = jsonObject as? [String: Any] {
                        // Access the parsed JSON dictionary here
                        self.currIsOn = jsonDictionary["SysOn"] as? Bool ?? false
                        let mode = jsonDictionary["SysMode"] as? Int ?? 1
                        let fanSpeed = jsonDictionary["SysFan"] as? Int ?? 1
                        let point = jsonDictionary["Setpoint"] as? Int ?? 15
                        
                        if(mode == 1){
                            self.currMode = "COOL"
                        }else if(mode == 2){
                            self.currMode = "HEAT"
                        }else if(mode == 3){
                            self.currMode = "VENT"
                        }else if(mode == 4){
                            self.currMode = "DRY"
                        }
                        
                        if(fanSpeed == 1){
                            self.currSpeed = "LOW"
                        }else if(fanSpeed == 2){
                            self.currSpeed = "MEDIUM"
                        }else if(fanSpeed == 3){
                            self.currSpeed = "HIGH"
                        }else if(fanSpeed == 4){
                            self.currSpeed = "AUTO"
                        }
                        
                        self.currTemp = point/100
                       
                        
                        DispatchQueue.main.async {
                            self.onOffSwitch.isOn = self.currIsOn
       
                            if let actionMode = self.btnMode.menu?.children.first(where: { $0.title ==  self.currMode }) as? UIAction {
                                actionMode.state = .on
                            }
                            
                            if let actionSpeed = self.btnSpeed.menu?.children.first(where: { $0.title ==  self.currSpeed }) as? UIAction {
                                actionSpeed.state = .on
                            }
                            
                            self.temperatureLabel.text = String(format: "%d", self.currTemp) + "°C"
                            self.tempStepper.value = Double(self.currTemp)
                            
                            self.loadingOnOff.stopAnimating()
                            self.loadingMode.stopAnimating()
                            self.loadingSpeed.stopAnimating()
                            self.loadingTemp.stopAnimating()
                            
                            self.onOffSwitch.isEnabled = true
                            self.btnMode.isEnabled = true
                            self.btnSpeed.isEnabled = true
                            self.tempStepper.isEnabled = true
                            
                          
                        }
                        
                        
                    }
                } catch {
                    print("Error: \(error)")
                    
                }
            }
            
        } onError: { error in
            print(error)
            DispatchQueue.main.async {
                self.popUpStatusError()
            }
        }

    }
    
    func popUpStatusError(){
        let alert = UIAlertController(title: "Error", message: "Fail to retrieve AC Status.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertAction.Style.default, handler: { _ in
            self.getACStatus()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func popUpStatusErrorGeneral(message:String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}


extension Dictionary {
       
   var jsonData: Data? {
      return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
   }
       
   func toJSONString() -> String? {
      if let jsonData = jsonData {
         let jsonString = String(data: jsonData, encoding: .utf8)
         return jsonString
      }
      return nil
   }
}
