import SwiftUI

struct TimeConverterView: View {
    let cities: [City]
    @StateObject private var converterService = TimeConverterService()
    @State private var selectedCity: City?
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 16) {
            Text("Time Converter")
                .font(.headline)

            // Source city picker
            Picker("From", selection: $selectedCity) {
                Text("Select city").tag(nil as City?)
                ForEach(cities) { city in
                    Text(city.name).tag(city as City?)
                }
            }
            .labelsHidden()

            // Date/time picker
            DatePicker("", selection: $selectedDate)
                .labelsHidden()

            Divider()

            // Conversion results
            if let source = selectedCity {
                VStack(alignment: .leading, spacing: 8) {
                    Text("In other zones:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(converterService.convert(time: selectedDate, in: source.timezone!, to: cities)) { result in
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
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Select a city to convert from")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(width: 300, height: 350)
    }
}
