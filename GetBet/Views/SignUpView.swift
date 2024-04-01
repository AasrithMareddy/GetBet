//
//  SignUpView.swift
//  GetBet
//
//  Created by Aasrith Mareddy on 27/01/24.
//

// SignInView.swift
// SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var otp: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .padding()
            
            // Name Textfield
            TextField("Name", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Email Textfield
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // OTP Textfield
            TextField("OTP", text: $otp)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Password Textfield
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Confirm Password Textfield
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Sign Up Button
            Button(action: {
                // Handle sign up logic
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
            
            // Sign Up with Google Button
            Button(action: {
                // Handle sign up with Google logic
            }) {
                Image("google") // Replace with the actual Google icon image
                    .resizable()
                    .frame(width: 30, height: 30)
                Text("Sign Up with Google")
            }
            .padding()
        }
        .padding()
    }
}
