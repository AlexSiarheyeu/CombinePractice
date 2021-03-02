//
//  ViewController.swift
//  ExampleApp-Signup
//
//  Created by Ben Scheirman on 8/19/20.
//

import UIKit
import Combine

// SIGN UP 
// - email address must be valid (contain @ and .)
// - password must be at least 8 characters
// - password cannot be "password"
// - password confirmation must match
// - must agree to terms
// - BONUS: color email field red when invalid, password confirmation field red when it doesn't match the password
// - BONUS: email address must remove spaces, lowercased

class ViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var agreeTermsSwitch: UISwitch!
    @IBOutlet weak var signUpButton: BigButton!
    
    // MARK: - Subjects
    
    private var emailSubject = CurrentValueSubject<String, Never>("")
    private var passwordSubject = CurrentValueSubject<String, Never>("")
    private var passwordConfirmationSubject = CurrentValueSubject<String, Never>("")
    private var agreeTermsSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - View Lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formIsValid
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellables)
        
        setValidColor(emailAddressField, publiser: emailIsValid)
        setValidColor(passwordField, publiser: passwordIsValid)
        setValidColor(passwordConfirmationField, publiser: passwordMathesConfirmation)

        formattedEmailAddress
            .filter { [unowned self] in $0 != self.emailSubject.value}
            .map {$0 as String? }
            .assign(to: \.text, on: emailAddressField)
            .store(in: &cancellables)
    }
    
    private func setValidColor<P: Publisher>(_ textField: UITextField, publiser: P) where P.Output == Bool, P.Failure == Never {
        publiser
            .map {$0 ? UIColor.label : UIColor.systemRed}
            .assign(to: \.textColor, on: textField)
            .store(in: &cancellables)
    }
    
    // MARK: - Publishers
    
    private var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(emailIsValid, passwordValidAndConfirmed, agreeTermsSubject)
            .map {$0.0 && $0.1 && $0.2}
            .eraseToAnyPublisher()
    }
    
    private var passwordValidAndConfirmed: AnyPublisher<Bool, Never> {
        return passwordIsValid.combineLatest(passwordMathesConfirmation)
            .map { valid, confirmed in valid && confirmed }
            .eraseToAnyPublisher()
    }
    
    private var formattedEmailAddress: AnyPublisher<String, Never> {
        emailSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
            .eraseToAnyPublisher()
    }
    
    private var emailIsValid: AnyPublisher<Bool, Never> {
        formattedEmailAddress
            .map {$0.contains("@") && $0.contains(".") }
            .eraseToAnyPublisher()
    }
    
    private var passwordIsValid: AnyPublisher<Bool, Never> {
        passwordSubject
            .map { $0 != "password" && $0.count >= 8}
            .eraseToAnyPublisher()
    }
    
    private var passwordMathesConfirmation: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(passwordConfirmationSubject)
            .map { password, confirmation in
                 password == confirmation
            }
            .eraseToAnyPublisher()
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func emailDidChange(_ sender: Any) {
        emailSubject.send(emailAddressField.text ?? "")
    }
    
    @IBAction func passwordDidChange(_ sender: Any) {
        passwordSubject.send(passwordField.text ?? "")
    }
    
    @IBAction func passwordConfirmationDidChange(_ sender: Any) {
        passwordConfirmationSubject.send(passwordConfirmationField.text ?? "")
    }
    
    @IBAction func agreeSwitchDidChange(_ sender: Any) {
        agreeTermsSubject.send(agreeTermsSwitch.isOn)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
