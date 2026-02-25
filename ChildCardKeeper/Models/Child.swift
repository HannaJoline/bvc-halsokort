import Foundation

// MARK: - Models (Codable, stored as JSON)

struct Child: Identifiable, Codable, Equatable {
    var id = UUID()
    var namn: String = ""
    var kon: String = ""
    var personnummer: String = ""
    var adress: String = ""
    var telefonnummer: String = ""
    
    var bvcAdress: String = ""
    var bvcTelefon: String = ""
    var sjukskoterska: String = ""
    var lakare: String = ""
    
    var sjukdomar: [Sjukdom] = []
    var matningar: [Matning] = []
    
    var fodelseVikt: String = ""
    var fodelseLangd: String = ""
    var fodelseHuvudomfang: String = ""
    var helammadTill: String = ""
    var delvisAmningTill: String = ""
    
    var horsel1Datum: Date?
    var horsel1Ua: Bool = false
    var horsel1Anm: Bool = false
    var horsel2Datum: Date?
    var horsel2Ua: Bool = false
    var horsel2Anm: Bool = false
    
    var syn1Datum: Date?
    var syn1Ua: Bool = false
    var syn1Anm: Bool = false
    var syn2Datum: Date?
    var syn2Ua: Bool = false
    var syn2Anm: Bool = false
    
    var fixerarBlicken: String = ""
    var svarsleende: String = ""
    var jollrarNyanserat: String = ""
    var forstarEnstakaOrd: String = ""
    var talar8_10Ord: String = ""
    var berattarBegripligt: String = ""
    
    var rorArmarBenLiksidigt: String = ""
    var hallerUppHuvudet: String = ""
    var flyttarForemal: String = ""
    var reserSigGar: String = ""
    var garSakert: String = ""
    var hopparPaEttBen: String = ""
    
    var vaccinationer: [Vaccination] = []
    
    var createdAt: Date = Date()
    
    var displayName: String {
        namn.isEmpty ? "Namnlöst barn" : namn
    }
}

struct Sjukdom: Identifiable, Codable, Equatable {
    var id = UUID()
    var sjukdom: String = ""
    var ar: String = ""
}

struct Matning: Identifiable, Codable, Equatable {
    var id = UUID()
    var datum: Date?
    var alderAr: Int?
    var alderMan: Int?
    var vikt: String = ""
    var langd: String = ""
    var huvudomfang: String = ""
    var anteckning: String = ""
}

struct Vaccination: Identifiable, Codable, Equatable {
    var id = UUID()
    var datum: Date?
    var locked: Bool = false
    var vaccinVarunamn: String = ""
    var difteri: Bool = false
    var stelkramp: Bool = false
    var kikhosta: Bool = false
    var polio: Bool = false
    var hemofilusInfB: Bool = false
    var pneumokocker: Bool = false
    var massling: Bool = false
    var rodaHund: Bool = false
    var passjuka: Bool = false
    var tuberkulos: Bool = false
    var hepatitB: Bool = false
    var rotavirus: Bool = false
    var egnaVaccin: [EgetVaccin] = []
    
    var givenVaccines: [String] {
        var list: [String] = []
        if difteri { list.append("Difteri") }
        if stelkramp { list.append("Stelkramp") }
        if kikhosta { list.append("Kikhosta") }
        if polio { list.append("Polio") }
        if hemofilusInfB { list.append("Hemofilus Inf B") }
        if pneumokocker { list.append("Pneumokocker") }
        if massling { list.append("Mässling") }
        if rodaHund { list.append("Röda hund") }
        if passjuka { list.append("Påssjuka") }
        if tuberkulos { list.append("Tuberkulos") }
        if hepatitB { list.append("Hepatit B") }
        if rotavirus { list.append("Rotavirus") }
        list.append(contentsOf: egnaVaccin.map { $0.namn }.filter { !$0.isEmpty })
        return list
    }
}

struct EgetVaccin: Identifiable, Codable, Equatable {
    var id = UUID()
    var namn: String = ""
}
