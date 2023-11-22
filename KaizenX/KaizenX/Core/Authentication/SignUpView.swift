import SwiftUI


struct SignUpView: View {
    
    @StateObject private var viewModel = SignUpViewModel()
    @Binding var showSignInView: Bool

    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Parolă...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Confirmă parola...", text: $viewModel.confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    let signUpSuccess = await viewModel.signUp()
                    if signUpSuccess {
                        showSignInView = false
                    }
                }
            } label: {
                Text("Creează cont")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.darkRed)
                    .cornerRadius(12)
            }
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("Creează un cont nou")
    }
}

#Preview {
    NavigationStack{
        SignUpView(showSignInView: .constant(true))
    }
}
