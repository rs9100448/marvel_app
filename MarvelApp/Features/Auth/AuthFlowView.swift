//
//  AuthFlowView.swift
//  MarvelApp
//
//  Hosts the sign-up → plans → payment → profile flow in a single navigation
//  stack driven by `Router.authPath`.
//

import SwiftUI

struct AuthFlowView: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.authPath) {
            SignupView()
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .plans: PlansView()
                    case .paymentMethod: PaymentMethodView()
                    case .cardDetails: CardDetailsView()
                    case .otp: OTPView()
                    case .paymentProcessing: PaymentProcessingView()
                    case .createProfile: CreateProfileView()
                    case .pinSetup: PINSetupView()
                    case .success: ProfileSuccessView()
                    }
                }
        }
        .tint(Theme.Colors.red)
    }
}
