//
//  ViewController.swift
//  ExampleApp-Signup
//
//  Created by Ben Scheirman on 8/19/20.
//

import UIKit
import Combine

// SIGN UP FORM RULES
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
    
    // Subjects
    private var emailSubject = CurrentValueSubject<String, Never>("")
    private var passwordSubject = CurrentValueSubject<String, Never>("")
    private var passwordConfirmation = CurrentValueSubject<String, Never>("")
    private var agreeTerms = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formattedEmailAddress
            .filter { [unowned self] in emailSubject.value != $0 }
            .map { $0 as String? }
            .assign(to: \.text, on: emailAddressField)
            .store(in: &cancellables)
        
        formIsValid
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellables)
        
        validEmailAddress.map { $0 ? UIColor.label : UIColor.systemRed }
            .assign(to: \.textColor, on: emailAddressField)
            .store(in: &cancellables)
        
        validPassword.map { $0 ? UIColor.label : UIColor.systemRed }
            .assign(to: \.textColor, on: passwordField)
            .store(in: &cancellables)
        
        passwordMatchesConfirmation.map { $0 ? UIColor.label : UIColor.systemRed }
            .assign(to: \.textColor, on: passwordConfirmationField)
            .store(in: &cancellables)
    }
    
    private var formattedEmailAddress: AnyPublisher<String, Never> {
        emailSubject
            .map {
                $0.lowercased()
                    .replacingOccurrences(of: " ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .eraseToAnyPublisher()
    }
    
    private var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(
            validEmailAddress, validAndConfirmedPassword, agreeTerms
        ).map { email, pw, terms in
            email && pw && terms
        }
        .eraseToAnyPublisher()
    }
    
    private var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(passwordConfirmation)
            .map { pass, confirm in
                pass == confirm
            }
            .eraseToAnyPublisher()
    }
    
    private var validPassword: AnyPublisher<Bool, Never> {
        passwordSubject
            .map {
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    private var validAndConfirmedPassword: AnyPublisher<Bool, Never> {
        validPassword.combineLatest(passwordMatchesConfirmation)
            .map { $0.0 && $0.1}
            .eraseToAnyPublisher()
    }
    
    private var validEmailAddress: AnyPublisher<Bool, Never> {
        emailSubject
            .map { [unowned self] in
                isValidEmailAddress($0)
            }
            .eraseToAnyPublisher()
    }
    
    private func isValidEmailAddress(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    // MARK: - Actions
    
    @IBAction func emailDidChange(_ sender: Any) {
        emailSubject.send(emailAddressField.text ?? "")
    }
    
    @IBAction func passwordDidChange(_ sender: Any) {
        passwordSubject.send(passwordField.text ?? "")
    }
    
    @IBAction func passwordConfirmationDidChange(_ sender: Any) {
        passwordConfirmation.send(passwordConfirmationField.text ?? "")
    }
    
    @IBAction func agreeSwitchDidChange(_ sender: Any) {
        agreeTerms.send(agreeTermsSwitch.isOn)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
