import Foundation
import Combine

public enum MeasurementSystem : Int, Codable, CaseIterable {
    case metric     = 1
    case imperial   = 2
    
    public var name : String {
        switch self {
        case .metric:        return "Metric"
        case .imperial:      return "Imperial"
        }
    }
    
    public var distanceMeasurementAbbreviation: String {
        switch self {
        case .imperial:         return "mi"
        case .metric:           return "km"
        }
    }
    public var speedMeasurementAbbreviation: String {
        switch self {
        case .imperial:         return "mph"
        case .metric:           return "km/h"
        }
    }
}

public enum SpeedDisplayType: Hashable {
    case running
    case rowing
    case natural(Int)               // Number of decimal places
}

final class UnitForce: Dimension {
    public override static func baseUnit() -> UnitForce {  return self.newtons }
    
    static let newtons = UnitForce(symbol: "N", converter: UnitConverterLinear(coefficient: 1.0))
    static let lbf = UnitForce(symbol: "lbf", converter: UnitConverterLinear(coefficient: 1.0 / 0.224808923))
}

final class UnitDensity: Dimension {
    public override static func baseUnit() -> UnitDensity {  return self.kilogramsPerCubicMetre }
    
    static let kilogramsPerCubicMetre = UnitDensity(symbol: "kg/m\u{00B3}", converter: UnitConverterLinear(coefficient: 1.0))
    static let poundPerCubicFoot = UnitDensity(symbol: "lb/ft\u{00B3}", converter: UnitConverterLinear(coefficient: 1.0 / 0.062427962033561))
}

public class Measurements: ObservableObject {
    static public var shared = Measurements()

    // Model : The measurement system in use
    @Published public var measurementSystem: MeasurementSystem = .metric
    
    // MARK: Return the unit to be used for display depending on the current measurement system
    fileprivate var unitLength : UnitLength             { return measurementSystem == .metric ? .kilometers : .miles }
    fileprivate var shortUnitLength : UnitLength        { return measurementSystem == .metric ? .meters : .yards }
    fileprivate var veryShortUnitLength: UnitLength     { return measurementSystem == .metric ? .centimeters : .inches }
    fileprivate var unitInverseSpeed : UnitSpeed        { return measurementSystem == .metric ? .minsPerkm : .minsPerMi }
    fileprivate var unitRowingSpeed: UnitSpeed          { return .minsPer500m }
    fileprivate var unitSpeed : UnitSpeed               { return measurementSystem == .metric ? .kilometersPerHour  : .milesPerHour }
    fileprivate var unitDuration : UnitDuration         { return .hours }
    fileprivate var unitHeight : UnitLength             { return measurementSystem == .metric ? .meters             : .feet }
    fileprivate var unitClimbByTime : UnitSpeed         { return measurementSystem == .metric ? .metresPerHour      : .feetPerHour }
    fileprivate var unitClimbByDistance : UnitLength    { return measurementSystem == .metric ? .metresPer10km      : .feetPer10m }
    fileprivate var unitPower : UnitPower               { return .watts }
    fileprivate var unitEnergy : UnitEnergy             { return .kilojoules }
    fileprivate var unitMass: UnitMass                  { return measurementSystem == .metric ? .kilograms      : .pounds }
    fileprivate var unitForce: UnitForce                { return measurementSystem == .metric ? .newtons      : .lbf }
    fileprivate var unitTemperature: UnitTemperature    { return measurementSystem == .metric ? .celsius : .fahrenheit }
    fileprivate var unitPressure: UnitPressure          { return measurementSystem == .metric ? .hectopascals : .inchesOfMercury }
    fileprivate var unitDensity: UnitDensity            { return measurementSystem == .metric ? .kilogramsPerCubicMetre : .poundPerCubicFoot }
}

// Typealias
public typealias Distance = Double
public typealias Duration = Double
public typealias Height = Double
public typealias Speed = Double
public typealias Power = Double
public typealias Mass = Double
public typealias Force = Double
public typealias Pressure = Double
public typealias Density = Double

// MARK: Measurement

// Computed variables that return Measurement in their base units (as stored in permanent storage in the app)
extension Distance {
    fileprivate var distanceMeasurement : Measurement<UnitLength> {
        return Measurement(value: self, unit: UnitLength.meters)
    }
}

extension Height {
    fileprivate var heightMeasurement : Measurement<UnitLength> {
        return Measurement(value: self, unit: UnitLength.meters)
    }
}

// Return duration as a Measurement
extension Duration {
    fileprivate var durationMeasurement : Measurement<UnitDuration> {
        return Measurement(value: self, unit: UnitDuration.seconds)
    }
}

extension Speed {
    fileprivate var speedMeasurement : Measurement<UnitSpeed> {
        return Measurement(value: self, unit: UnitSpeed.metersPerSecond)
    }
}

extension Power {
    fileprivate var powerMeasurement : Measurement<UnitPower> {
        return Measurement(value: self, unit: UnitPower.watts)
    }
}

extension Mass {
    fileprivate var massMeasurement : Measurement<UnitMass> {
        return Measurement(value: self, unit: UnitMass.kilograms)
    }
}

extension Force {
    fileprivate var forceMeasurement : Measurement<UnitForce> {
        return Measurement(value: self, unit: UnitForce.newtons)
    }
}

extension Pressure {
    fileprivate var pressureMeasurement : Measurement<UnitPressure> {
        return Measurement(value: self, unit: UnitPressure.hectopascals)
    }
}

extension Density {
    fileprivate var densityMeasurement : Measurement<UnitDensity> {
        return Measurement(value: self, unit: UnitDensity.kilogramsPerCubicMetre)
    }
}

extension Double {
    fileprivate var climbRateByTimeMeasurement : Measurement<UnitSpeed> {
        return Measurement(value: self, unit: UnitSpeed.metersPerSecond)
    }
    fileprivate var climbRateByDistanceMeasurement : Measurement<UnitLength> {
        return Measurement(value: self, unit: UnitLength.meters)
    }
    fileprivate var energyMeasurement : Measurement<UnitEnergy> {
        return Measurement(value: self, unit: UnitEnergy.kilojoules)
    }
    fileprivate var temperatureMeasurement : Measurement<UnitTemperature> {
        return Measurement(value: self, unit: UnitTemperature.celsius)
    }
}

// Extensions to definitions to add additional measurements
extension UnitSpeed {
    static public let metresPerHour = UnitSpeed(symbol: "m/hr", converter: UnitConverterLinear(coefficient: 1.0 / Conversions.secondsPerHour))
    static public let feetPerHour = UnitSpeed(symbol: "ft/hr", converter: UnitConverterLinear(coefficient: 1.0 / (Conversions.feetPerMetre * Conversions.secondsPerHour)))
}

extension UnitLength {
    static public let metresPer10km = UnitLength(symbol: "m/10km", converter: UnitConverterLinear(coefficient: 1.0 / (Conversions.metresPerKm * 10)))
    static public let feetPer10m = UnitLength(symbol: "ft/10mi", converter: UnitConverterLinear(coefficient: (1.0 / Conversions.feetPerMetre) / (Conversions.metresPerMile * 10)))
}

extension UnitSpeed {
    static public let minsPerkm        = UnitSpeed(symbol: "/km", converter: TimeForDistanceSpeedConverter(.metric))
    static public let minsPerMi        = UnitSpeed(symbol: "/mi", converter: TimeForDistanceSpeedConverter(.imperial))
    static public let minsPer500m      = UnitSpeed(symbol: "/500m", converter: TimeForDistanceSpeedConverter(.metric, adjustmentFactor: 0.5))
    
}

class TimeForDistanceSpeedConverter: UnitConverter {
    var measurementSystem: MeasurementSystem
    var adjustmentFactor: Double                     // Factor is applied to the distance, so a factor of 0.1 on metric assumes 100m.
    
    init(_ measurementSystem: MeasurementSystem, adjustmentFactor: Double? = nil) {
        self.measurementSystem = measurementSystem
        if let factor = adjustmentFactor {
            self.adjustmentFactor = factor
        } else {
            self.adjustmentFactor = 1.0
        }
    }
    
    // For a given unit, returns the specified value of that unit in terms of the base unit of its dimension
    // Convert 1 min/1k or 1 min/mile to m/s
    override func baseUnitValue(fromValue value: Double) -> Double {
        switch measurementSystem {
        case .metric:
            return ((Conversions.metresPerKm * adjustmentFactor) / Conversions.secondsPerMin) / value
        case .imperial:
            return ((Conversions.metresPerMile * adjustmentFactor) / Conversions.secondsPerMin) / value
        }
    }
    
    // For a given unit, returns the specified value of the base unit in terms of that unit
    // Convert m/s to mins/1k or mins/mile
    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        switch measurementSystem {
        case .metric:
            return ((Conversions.metresPerKm * adjustmentFactor) / Conversions.secondsPerMin) / baseUnitValue
        case .imperial:
            return ((Conversions.metresPerMile * adjustmentFactor) / Conversions.secondsPerMin) / baseUnitValue
        }
    }
}

// Convert distance & time to speed
fileprivate func / (lhs: Measurement<UnitLength>, rhs: Measurement<UnitDuration>) -> Measurement<UnitSpeed> {
    let quantity = lhs.converted(to: Measurements.shared.unitLength).value / rhs.converted(to: Measurements.shared.unitDuration).value
    return Measurement(value: quantity, unit: Measurements.shared.unitSpeed)
}

// MARK: Conversion factors
public struct Conversions {
    static public let feetPerMetre     = Measurement(value: 1, unit: UnitLength.meters).converted(to: .feet).value
    static public let metresPerYard    = Measurement(value: 1, unit: UnitLength.yards).converted(to: .meters).value
    static public let metresPerMile    = Measurement(value: 1, unit: UnitLength.miles).converted(to: .meters).value
    static public let secondsPerHour   = 3600.0
    static public let metresPerKm      = 1000.0
    static public let secondsPerMin    = 60.0
    
    static public let milesPerKm       = metresPerKm / metresPerMile
    
    static public let metresPerMarathon = 42195.0
}

// MARK: Formatting
// Format mins and decimal as mm:ss
class MinsNumberFormatter: NumberFormatter {
    override func string(from number: NSNumber) -> String? {
        let tenthSeconds = Int((number.doubleValue * 600).rounded())        // Convert to tenth seconds
        let (mins, tenths) = tenthSeconds.quotientAndRemainder(dividingBy: 600)
//        return String(format: "%d:%02d.%1d", mins, tenths / 10, tenths % 10)
        return String(format: "%d:%02d", mins, tenths / 10)
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
        obj?.pointee = nil
    }
}


// Standard formatting
fileprivate extension Measurement  {
    func displayFormatter(unitStyle : MeasurementFormatter.UnitStyle = .medium,  fractionDigits : Int = 0)  -> MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.unitStyle = unitStyle
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.maximumFractionDigits = fractionDigits
        measurementFormatter.numberFormatter = numberFormatter
        return measurementFormatter
    }

    func minsDisplayFormatter()  -> MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit

        let numberFormatter = MinsNumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        measurementFormatter.numberFormatter = numberFormatter

        return measurementFormatter
    }
}

fileprivate extension TimeInterval {
    func format(using units: NSCalendar.Unit, style: DateComponentsFormatter.UnitsStyle = .brief) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .default

        return formatter.string(from: self)
    }
}

public enum MeasurementDisplayStyle {
    case normal
    case compact
}

/// Public view of measurements as strings for display
extension Double {
    
    public var distanceDisplayString: String {
        if self == 0 {
            switch Measurements.shared.measurementSystem {
            case .imperial:         return "0mi"
            case .metric:           return "0km"
            }
        } else if self < 10 {                // If very short: < 10m / 10yd
            return self.distanceMeasurement.displayFormatter(fractionDigits: 1).string(from: self.distanceMeasurement.converted(to: Measurements.shared.veryShortUnitLength))
        } else if self < (Measurements.shared.measurementSystem == .metric ? Conversions.metresPerKm : Conversions.metresPerMile / 4) {            // If short distance (< 1km / 0.5 mile)
            return self.distanceMeasurement.displayFormatter(fractionDigits: 0).string(from: self.distanceMeasurement.converted(to: Measurements.shared.shortUnitLength))
        } else if self > (Measurements.shared.measurementSystem == .metric ? Conversions.metresPerKm * 1000 : Conversions.metresPerMile * 1000) {            // If very long distance (> 1000km/mi)
            return self.longDistanceDisplayString
        } else {
            return self.distanceMeasurement.displayFormatter(fractionDigits: 2).string(from: self.distanceMeasurement.converted(to: Measurements.shared.unitLength))
        }
    }
    public var longDistanceDisplayString : String {
        return self.distanceMeasurement.displayFormatter(fractionDigits: 0).string(from: self.distanceMeasurement.converted(to: Measurements.shared.unitLength))
    }
    public var heightDisplayString : String {
        return self.heightMeasurement.displayFormatter(fractionDigits: 0).string(from: self.heightMeasurement.converted(to: Measurements.shared.unitHeight))
    }
    
    public func speedDisplayString(displayType: SpeedDisplayType = .natural(1)) -> String {
        switch displayType {
        case .natural(let digits):
            return self.speedMeasurement.displayFormatter(fractionDigits: digits).string(from: self.speedMeasurement.converted(to: Measurements.shared.unitSpeed))
        case .running:
            return self == 0 ? "" : self.speedMeasurement.minsDisplayFormatter().string(from: self.speedMeasurement.converted(to: Measurements.shared.unitInverseSpeed))
        case .rowing:
            return self == 0 ? "" : self.speedMeasurement.minsDisplayFormatter().string(from: self.speedMeasurement.converted(to: Measurements.shared.unitRowingSpeed))
        }
    }
      
    public var abbreviatedDurationDisplayString: String {
        guard !self.isNaN && self.isFinite && self >= 0 else { return "" }

        switch self {
        case 0 ..< 3600:
            return self.format(using: [.minute, .second], style: .positional) ?? ""
        case 3600 ..< 86400 * 7:
            return self.format(using: [.hour, .minute], style: .positional) ?? ""
        default:
            return self.format(using: [.day, .hour], style: .positional) ?? ""
        }
    }
    
    public var durationDisplayString: String {
        guard !self.isNaN && self.isFinite && self >= 0 else { return "" }

        switch self {
        case 0 ..< 3600:
            return self.format(using: [.minute, .second]) ?? ""
        case 3600 ..< 86400 * 7:
            return self.format(using: [.hour, .minute]) ?? ""
        default:
            return self.format(using: [.day, .hour]) ?? ""
        }
    }
    

    public func powerDisplayString(withUnit: Bool = true) -> String {
        if withUnit {
            return self.powerMeasurement.displayFormatter(fractionDigits: 0).string(from: self.powerMeasurement.converted(to: Measurements.shared.unitPower))
        } else {
            return self.powerMeasurement.converted(to: Measurements.shared.unitPower).value.fixedFraction(digits: 0)
        }
    }
    
    public var massDisplayString : String {
        return self.massMeasurement.displayFormatter(fractionDigits: 0).string(from: self.massMeasurement.converted(to: Measurements.shared.unitMass))
    }
    
    public var forceDisplayString : String {
        return self.forceMeasurement.displayFormatter(fractionDigits: 1).string(from: self.forceMeasurement.converted(to: Measurements.shared.unitForce))
    }

    public var energyDisplayString : String {
        return self.energyMeasurement.displayFormatter(fractionDigits: 0).string(from: self.energyMeasurement.converted(to: Measurements.shared.unitEnergy))
    }
    
    public var temperatureDisplayString : String {
        return self.temperatureMeasurement.displayFormatter(fractionDigits: 0).string(from: self.temperatureMeasurement.converted(to: Measurements.shared.unitTemperature))
    }

    public var pressureDisplayString : String {
        let digits = Measurements.shared.measurementSystem == .metric ? 0 : 2
        return self.pressureMeasurement.displayFormatter(fractionDigits: digits).string(from: self.pressureMeasurement.converted(to: Measurements.shared.unitPressure))
    }

    public var densityDisplayString : String {
        return self.densityMeasurement.displayFormatter(fractionDigits: 3).string(from: self.densityMeasurement.converted(to: Measurements.shared.unitDensity))
    }

    public var elevationTimeDisplayString : String {
        // Raw value is metres / second
        return self.speedMeasurement.displayFormatter(fractionDigits: 0).string(from: self.climbRateByTimeMeasurement.converted(to: Measurements.shared.unitClimbByTime))
    }
    
    public var elevationDistanceDisplayString : String {
        // Raw value is metres climbed / metres distance
        return self.distanceMeasurement.displayFormatter(fractionDigits: 0).string(from: self.climbRateByDistanceMeasurement.converted(to: Measurements.shared.unitClimbByDistance))
    }
    
    public var latLongDisplayString: String {
        return DegreeFormatter().string(from: self)
    }
    
    public func percentDisplayString(withFraction: Bool = true) -> String {
        return (self * 100).fixedFraction(digits: withFraction ? 2 : 0) + "%"
    }
}

extension Int {
    public func heartRateDisplayString(withUnit: Bool = true) -> String {
        return "\(self)" + (withUnit ? " bpm" : "")
    }
}

extension FloatingPoint {
    public func fixedFraction(digits: Int = 0) -> String {
        return String(format: "%.\(digits)f", self as! CVarArg)
    }
}



class DegreeFormatter : NumberFormatter {
    func string(from degree: Double) -> String {
        var remaining = degree

        let degree = remaining.rounded(.towardZero)
        remaining -= degree
        remaining *= 60.0

        return "\(degree.fixedFraction(digits: 0))º \(abs(remaining).fixedFraction(digits: 2))"
    }
}
