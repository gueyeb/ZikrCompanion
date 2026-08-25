import SwiftUI

// MARK: - RoutineView (DAK-155)

struct RoutineView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        HStack(spacing: AppTheme.paddingS) {
            ForEach(RoutineType.allCases, id: \.self) { routine in
                RoutineTabButton(
                    routine: routine,
                    isSelected: store.selectedRoutine == routine,
                    action: { store.selectRoutine(routine) }
                )
            }
        }
        .padding(4)
        .background(AppTheme.surfaceAlt)
        .clipShape(.rect(cornerRadius: AppTheme.radiusM))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Choix de la routine")
    }
}

// MARK: - RoutineTabButton

private struct RoutineTabButton: View {
    let routine: RoutineType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: routine.icon)
                    .font(.system(size: 14, weight: .medium))
                Text(routine.displayName)
                    .font(AppTheme.headlineFont)
                Text("×\(routine.target)")
                    .font(AppTheme.captionFont)
                    .opacity(0.7)
            }
            .foregroundStyle(isSelected ? AppTheme.background : AppTheme.textSecondary)
            .padding(.horizontal, AppTheme.paddingM)
            .padding(.vertical, AppTheme.paddingS + 2)
            .background(isSelected ? AppTheme.gold : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusS + 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Routine du \(routine.displayName.lowercased()), objectif \(routine.target)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    RoutineView()
        .environmentObject(SessionStore())
        .padding()
        .background(AppTheme.background)
}
