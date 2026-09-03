//
//  PlansViewModel.swift
//  MarvelApp
//

import Foundation

@Observable
@MainActor
final class PlansViewModel {
    private(set) var plans: [Plan] = []
    var selectedPlanID: String?

    @ObservationIgnored private let repository: ContentRepository

    init(repository: ContentRepository = JSONContentRepository()) {
        self.repository = repository
    }

    var selectedPlan: Plan? { plans.first { $0.id == selectedPlanID } }
    var canContinue: Bool { selectedPlanID != nil }

    func load() {
        plans = (try? repository.plans()) ?? []
        if selectedPlanID == nil { selectedPlanID = plans.first?.id }
    }
}
