import SwiftUI

struct EditCitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var city: City
    
    @State private var nickname: String = ""
    @State private var selectedColor: Color = .blue
    @State private var useCustomColor: Bool = false
    
    private let presetColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .teal, .indigo, .mint
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit City")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(city.flagEmoji)
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text(city.name)
                            .font(.headline)
                        Text(city.country)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                TextField("Nickname", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                
                Toggle("Use Custom Color", isOn: $useCustomColor)
                
                if useCustomColor {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(presetColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
            }
            .padding()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save") {
                    saveChanges()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 320, height: 380)
        .onAppear {
            nickname = city.nickname ?? ""
            useCustomColor = city.colorHex != nil
            if let hex = city.colorHex, let color = Color(hex: hex) {
                selectedColor = color
            }
        }
    }
    
    private func saveChanges() {
        city.nickname = nickname.isEmpty ? nil : nickname
        city.colorHex = useCustomColor ? selectedColor.hexString : nil
    }
}

struct EditCitySheet_Previews: PreviewProvider {
    static var previews: some View {
        EditCitySheet(city: .constant(City(
            id: UUID(),
            name: "New York",
            country: "United States",
            timezoneIdentifier: "America/New_York",
            sortOrder: 0,
            isLocal: false,
            isFavorite: false,
            nickname: nil,
            colorHex: nil
        )))
    }
}
