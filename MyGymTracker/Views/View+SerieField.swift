import SwiftUI

extension View {
    func serieField() -> some View {
        self
            .padding(10)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange.opacity(0.6), lineWidth: 1)
            )
    }
}
