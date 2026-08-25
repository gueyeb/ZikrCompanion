import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        Group {
            if store.history.isEmpty {
                ContentUnavailableView(
                    "Aucune session",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Les routines terminées apparaîtront ici, uniquement sur cet appareil.")
                )
            } else {
                List(store.history) { record in
                    HStack(spacing: AppTheme.paddingM) {
                        Image(systemName: record.routineType.icon)
                            .foregroundStyle(AppTheme.gold)
                            .frame(width: 32, height: 32)
                            .background(AppTheme.gold.opacity(0.12))
                            .clipShape(.circle)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.routineType.displayName)
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(record.completedAt, format: .dateTime.day().month(.wide).year())
                                .font(AppTheme.captionFont)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(record.completedCount) répétitions")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.gold)
                    }
                    .padding(.vertical, AppTheme.paddingS)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        "Routine du \(record.routineType.displayName.lowercased()), "
                            + "\(record.completedCount) répétitions"
                    )
                }
                .listRowBackground(AppTheme.surfaceAlt)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.background)
        .navigationTitle("Historique")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(SessionStore())
    }
}
