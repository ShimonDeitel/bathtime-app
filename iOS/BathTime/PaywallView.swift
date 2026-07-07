import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.accent)
                Text("Bath Time Pro")
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.textPrimary)
                Text("Multi-caregiver history, night-feeding stats, and CSV export")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button {
                    Task {
                        await purchases.purchase()
                        if purchases.isPro { dismiss() }
                    }
                } label: {
                    Text("Unlock Pro")
                        .font(Theme.bodyFont.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("purchaseButton")
                .padding(.horizontal, 32)
                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("paywallRestoreButton")
                .foregroundStyle(Theme.textSecondary)
                Button("Not now") { dismiss() }
                    .accessibilityIdentifier("paywallDismissButton")
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
}
