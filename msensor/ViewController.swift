//
//  ViewController.swift
//  msensor
//
//  Created by Ronaldo II Dorado on 15/9/17.
//  Copyright © 2017 Ronaldo II Dorado. All rights reserved.
//
import UIKit
import Firebase
import SnapKit

enum MoistureStatus: String {
    case wet, dry, unknown
}

class ViewController: UIViewController, UITextFieldDelegate, WaitViewPresentable {
    
    let email: String = "ronaldo.dorado.ii@gmail.com"
    let password: String = "test1234"
    var ref: DatabaseReference?
    var currentMoistureStatus: MoistureStatus = .unknown
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Moisture Status"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: label.font.fontName, size: 100)
        return label
    }()
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var waitView:UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "clear"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintImageColor(color: .white)
        return imageView
    }()
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "clear"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    
    deinit {
        timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
        buildConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.isLoggedIn() {
            self.signinComplete(animated: false)
        }
        ref = Database.database().reference()
        login()
    }
    
    private func login() {
        self.showWaitView()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            self.hideWaitView()
            guard let user = user, error == nil else {
                self.showMessagePrompt(error!.localizedDescription)
                return
            }
            
            self.ref?.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard snapshot.exists() else {
                    self.showMessagePrompt("Email or Password is invalid.")
                    return
                }
                self.signinComplete(animated: true)
            })
        })
    }
    
    private func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func buildView() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        buildWaitView(inside: view)
        view.backgroundColor = .white
        self.hideWaitView()
    }
    
    private func buildConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.imageView.snp.top).inset(-30)
        }
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(200)
            make.width.equalTo(200)
        }
    }
    
    private func signinComplete(animated: Bool) {
        timer = nil
        readMoistureStatus()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(readMoistureStatus), userInfo: nil, repeats: true)
    }

    func readMoistureStatus() {
        DispatchQueue.global(qos: .background).async {
            guard let statusReference = self.ref?.child("moisture").child("status") else {
                return
            }
            let _ = statusReference.observe(.value, with: { snapshot in
                guard let moistureStatusString = snapshot.value as? String else {
                    self.updateView(status: .unknown)
                    return
                }
                let moistureStatus: MoistureStatus = moistureStatusString == "wet" ? .wet : .dry
                self.updateView(status: moistureStatus)
            })
        }
    }
    
    private func updateView(status: MoistureStatus) {
        
        print("moisture status: \(status)    current: \(currentMoistureStatus)")
        if currentMoistureStatus == status {
            return
        }
        currentMoistureStatus = status
        DispatchQueue.main.async {
            switch status {
            case .unknown:
                self.imageView.image = UIImage(named: "clear")
                self.backgroundImageView.image = UIImage(named: "clear")
                self.imageView.tintImageColor(color: .white)
                self.titleLabel.text = ""
            case .wet:
                self.imageView.image = UIImage(named: "wet")
                self.backgroundImageView.image = UIImage(named: "wetBackground")
                self.imageView.tintImageColor(color: .white)
                self.titleLabel.text = "Wet"
            case .dry:
                self.imageView.image = UIImage(named: "dry")
                self.backgroundImageView.image = UIImage(named: "dryBackground")
                self.titleLabel.text = "Dry"
            }
            self.imageView.tintImageColor(color: .white)
        }
    }
}
