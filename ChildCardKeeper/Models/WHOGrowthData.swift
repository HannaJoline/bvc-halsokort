import Foundation

struct WHOReferencePoint {
    let ageMonths: Double
    let minus2SD: Double
    let median: Double
    let plus2SD: Double
}

struct WHOGrowthData {
    // Age intervals in months
    static let ages: [Double] = [0, 1, 2, 3, 4, 6, 9, 12, 15, 18, 24]

    // MARK: - Boys

    static let boysWeight: [WHOReferencePoint] = {
        let med: [Double] = [3300, 4500, 5600, 6400, 7000, 7900, 9200, 10200, 10900, 11500, 12200]
        return zip(ages, med).map { WHOReferencePoint(ageMonths: $0, minus2SD: $1 * 0.85, median: $1, plus2SD: $1 * 1.15) }
    }()

    static let boysLength: [WHOReferencePoint] = {
        let med: [Double] = [49.9, 54.7, 58.4, 61.4, 63.9, 67.6, 72.0, 75.7, 79.1, 82.3, 87.8]
        return zip(ages, med).map { WHOReferencePoint(ageMonths: $0, minus2SD: $1 - 4, median: $1, plus2SD: $1 + 4) }
    }()

    static let boysHead: [WHOReferencePoint] = {
        let med: [Double] = [34.5, 37.3, 39.1, 40.5, 41.6, 43.3, 45.0, 46.1, 46.8, 47.4, 48.3]
        return zip(ages, med).map { WHOReferencePoint(ageMonths: $0, minus2SD: $1 - 2, median: $1, plus2SD: $1 + 2) }
    }()

    // MARK: - Girls

    static let girlsWeight: [WHOReferencePoint] = {
        let med: [Double] = [3200, 4200, 5100, 5800, 6400, 7300, 8600, 9500, 10200, 10800, 11500]
        return zip(ages, med).map { WHOReferencePoint(ageMonths: $0, minus2SD: $1 * 0.85, median: $1, plus2SD: $1 * 1.15) }
    }()

    static let girlsLength: [WHOReferencePoint] = {
        let med: [Double] = [49.1, 53.7, 57.1, 59.8, 62.1, 65.7, 70.1, 73.7, 77.0, 80.1, 86.4]
        return zip(ages, med).map { WHOReferencePoint(ageMonths: $0, minus2SD: $1 - 4, median: $1, plus2SD: $1 + 4) }
    }()

    static let girlsHead: [WHOReferencePoint] = {
        let med: [Double] = [33.9, 36.5, 38.3, 39.5, 40.6, 42.2, 43.8, 44.9, 45.6, 46.2, 47.2]
        return zip(ages, med).map { WHOReferencePoint(ageMonths: $0, minus2SD: $1 - 2, median: $1, plus2SD: $1 + 2) }
    }()

    static func data(for kon: String, metric: GrowthMetric) -> [WHOReferencePoint] {
        let isBoy = kon == "Pojke"
        switch metric {
        case .weight: return isBoy ? boysWeight : girlsWeight
        case .length: return isBoy ? boysLength : girlsLength
        case .head:   return isBoy ? boysHead : girlsHead
        }
    }
}

enum GrowthMetric: String, CaseIterable, Identifiable {
    case weight = "Vikt (g)"
    case length = "Längd (cm)"
    case head = "Huvudomfång (cm)"
    var id: String { rawValue }
}
