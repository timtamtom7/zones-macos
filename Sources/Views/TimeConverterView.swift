import SwiftUI

struct TimeConverterView: View {
    let cities: [City]
    @StateObject private var converterService = TimeConverterService()
    @State private var selectedCity: City?
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Time Converter")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)

            VStack(spacing: 16) {
                Picker("From", selection: $selectedCity) {
                    Text("Select city").tag(nil as City?)
                    ForEach(cities) { city in
                        Text(city.name).tag(city as City?)
                    }
                }
                .labelsHidden()

                DatePicker("", selection: $selectedDate)
                    .labelsHidden()

                Rectangle()
                    .fill(.secondary.opacity(0.2))
                    .frame(height: 1)

                if let source = selectedCity, let sourceTz = source.timezone {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("In other zones:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(converterService.convert(time: selectedDate, in: sourceTz, to: cities)) { result in
                            if result.city.id != source.id {
                                HStack {
                                    Text(result.city.name)
                                        .font(.caption)
                                    Spacer()
                                    Text(result.formattedTime)
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    if result.isNextDay {
                                        Text("+1 day")
                                            .font(.caption2)
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Select a city to convert from")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(16)
        }
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
        .frame(width: 300, height: 350)
    }
}
