//
//  ViewModelTests.swift
//  MarvelAppTests
//

import Testing
import Foundation
@testable import MarvelApp

@MainActor
struct ViewModelTests {

    // MARK: Signup
    @Test func signupRejectsInvalidInput() async {
        let vm = SignupViewModel(auth: DummyAuthService(latency: .zero))
        vm.email = "not-an-email"
        vm.password = "weak"
        #expect(!vm.isFormValid)
        let profile = await vm.signUp()
        #expect(profile == nil)
        #expect(vm.errorMessage != nil)
    }

    @Test func signupSucceedsWithValidInput() async {
        let vm = SignupViewModel(auth: DummyAuthService(latency: .zero))
        vm.email = "fan@marvel.io"
        vm.password = "Avengers1"
        #expect(vm.isFormValid)
        let profile = await vm.signUp()
        #expect(profile?.email == "fan@marvel.io")
        #expect(vm.errorMessage == nil)
    }

    @Test func socialSignInReturnsProfile() async {
        let vm = SignupViewModel(auth: DummyAuthService(latency: .zero))
        let profile = await vm.signIn(with: .google)
        #expect(profile != nil)
    }

    // MARK: Payment formatting + validation
    @Test func cardNumberIsGroupedIntoFours() {
        let vm = PaymentViewModel()
        vm.cardNumber = "4242424242424242"
        #expect(vm.cardNumber == "4242 4242 4242 4242")
    }

    @Test func expiryGetsSlashInserted() {
        let vm = PaymentViewModel()
        vm.expiry = "1230"
        #expect(vm.expiry == "12/30")
    }

    @Test func cvvIsLimitedToDigits() {
        let vm = PaymentViewModel()
        vm.cvv = "12ab34567"
        #expect(vm.cvv == "1234")
    }

    @Test func cardFormValidityAggregates() {
        let vm = PaymentViewModel()
        vm.firstName = "Tony"
        vm.lastName = "Stark"
        vm.cardNumber = "4242 4242 4242 4242"
        vm.expiry = "12/30"
        vm.cvv = "123"
        #expect(vm.isCardFormValid)

        vm.cvv = "1"
        #expect(!vm.isCardFormValid)

        vm.cvv = "123"
        vm.firstName = ""
        #expect(!vm.isCardFormValid)
    }

    // MARK: Plans
    @Test func plansLoadAndDefaultSelection() {
        let vm = PlansViewModel(repository: MockContentRepository())
        vm.load()
        #expect(!vm.plans.isEmpty)
        #expect(vm.selectedPlanID != nil)
        #expect(vm.canContinue)
    }

    // MARK: Home
    @Test func homeLoadsSections() {
        let vm = HomeViewModel(repository: MockContentRepository())
        vm.load()
        #expect(!vm.latestMovies.isEmpty)
        #expect(!vm.latestSeries.isEmpty)
        #expect(!vm.trending.isEmpty)
        #expect(vm.loadError == nil)
    }

    // MARK: Session persistence
    @Test func sessionPersistsAcrossInstances() {
        let store = InMemoryKeyValueStore()
        let first = SessionStore(store: store)
        first.completeOnboarding()
        first.signIn(profile: UserProfile(email: "a@b.io", displayName: "A",
                                          avatarImageName: "avatar_1",
                                          selectedPlanID: "plan_all", paymentMethod: .card))
        // A new store reading the same backing store should see the saved state.
        let second = SessionStore(store: store)
        #expect(second.isOnboardingComplete)
        #expect(second.isAuthenticated)
        #expect(second.profile?.email == "a@b.io")

        second.signOut()
        let third = SessionStore(store: store)
        #expect(!third.isAuthenticated)
    }

    @Test func libraryTogglePersists() {
        let store = InMemoryKeyValueStore()
        let lib = LibraryStore(store: store)
        lib.toggleWatchlist("m1")
        lib.toggleDownload("s1")
        #expect(lib.isInWatchlist("m1"))
        #expect(lib.isDownloaded("s1"))

        let reloaded = LibraryStore(store: store)
        #expect(reloaded.isInWatchlist("m1"))
        #expect(reloaded.isDownloaded("s1"))
    }
}
