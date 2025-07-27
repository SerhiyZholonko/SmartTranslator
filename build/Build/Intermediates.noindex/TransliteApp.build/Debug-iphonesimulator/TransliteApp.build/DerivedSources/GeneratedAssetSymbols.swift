import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AppAccent" asset catalog color resource.
    static let appAccent = DeveloperToolsSupport.ColorResource(name: "AppAccent", bundle: resourceBundle)

    /// The "AppBackground" asset catalog color resource.
    static let appBackground = DeveloperToolsSupport.ColorResource(name: "AppBackground", bundle: resourceBundle)

    /// The "ButtonBackground" asset catalog color resource.
    static let buttonBackground = DeveloperToolsSupport.ColorResource(name: "ButtonBackground", bundle: resourceBundle)

    /// The "ButtonText" asset catalog color resource.
    static let buttonText = DeveloperToolsSupport.ColorResource(name: "ButtonText", bundle: resourceBundle)

    /// The "CardBackground" asset catalog color resource.
    static let cardBackground = DeveloperToolsSupport.ColorResource(name: "CardBackground", bundle: resourceBundle)

    /// The "Divider" asset catalog color resource.
    static let divider = DeveloperToolsSupport.ColorResource(name: "Divider", bundle: resourceBundle)

    /// The "ErrorColor" asset catalog color resource.
    static let error = DeveloperToolsSupport.ColorResource(name: "ErrorColor", bundle: resourceBundle)

    /// The "InputBackground" asset catalog color resource.
    static let inputBackground = DeveloperToolsSupport.ColorResource(name: "InputBackground", bundle: resourceBundle)

    /// The "InputBorder" asset catalog color resource.
    static let inputBorder = DeveloperToolsSupport.ColorResource(name: "InputBorder", bundle: resourceBundle)

    /// The "NavigationBackground" asset catalog color resource.
    static let navigationBackground = DeveloperToolsSupport.ColorResource(name: "NavigationBackground", bundle: resourceBundle)

    /// The "NavigationTint" asset catalog color resource.
    static let navigationTint = DeveloperToolsSupport.ColorResource(name: "NavigationTint", bundle: resourceBundle)

    /// The "PlaceholderText" asset catalog color resource.
    static let placeholderText = DeveloperToolsSupport.ColorResource(name: "PlaceholderText", bundle: resourceBundle)

    /// The "PremiumGradientEnd" asset catalog color resource.
    static let premiumGradientEnd = DeveloperToolsSupport.ColorResource(name: "PremiumGradientEnd", bundle: resourceBundle)

    /// The "PremiumGradientStart" asset catalog color resource.
    static let premiumGradientStart = DeveloperToolsSupport.ColorResource(name: "PremiumGradientStart", bundle: resourceBundle)

    /// The "PrimaryText" asset catalog color resource.
    static let primaryText = DeveloperToolsSupport.ColorResource(name: "PrimaryText", bundle: resourceBundle)

    /// The "SecondaryAccent" asset catalog color resource.
    static let secondaryAccent = DeveloperToolsSupport.ColorResource(name: "SecondaryAccent", bundle: resourceBundle)

    /// The "SecondaryBackground" asset catalog color resource.
    static let secondaryBackground = DeveloperToolsSupport.ColorResource(name: "SecondaryBackground", bundle: resourceBundle)

    /// The "SecondaryText" asset catalog color resource.
    static let secondaryText = DeveloperToolsSupport.ColorResource(name: "SecondaryText", bundle: resourceBundle)

    /// The "Shadow" asset catalog color resource.
    static let shadow = DeveloperToolsSupport.ColorResource(name: "Shadow", bundle: resourceBundle)

    /// The "SuccessColor" asset catalog color resource.
    static let success = DeveloperToolsSupport.ColorResource(name: "SuccessColor", bundle: resourceBundle)

    /// The "TabBarBackground" asset catalog color resource.
    static let tabBarBackground = DeveloperToolsSupport.ColorResource(name: "TabBarBackground", bundle: resourceBundle)

    /// The "TabBarTint" asset catalog color resource.
    static let tabBarTint = DeveloperToolsSupport.ColorResource(name: "TabBarTint", bundle: resourceBundle)

    /// The "TertiaryBackground" asset catalog color resource.
    static let tertiaryBackground = DeveloperToolsSupport.ColorResource(name: "TertiaryBackground", bundle: resourceBundle)

    /// The "TertiaryText" asset catalog color resource.
    static let tertiaryText = DeveloperToolsSupport.ColorResource(name: "TertiaryText", bundle: resourceBundle)

    /// The "TranslationBackground" asset catalog color resource.
    static let translationBackground = DeveloperToolsSupport.ColorResource(name: "TranslationBackground", bundle: resourceBundle)

    /// The "TranslationBorder" asset catalog color resource.
    static let translationBorder = DeveloperToolsSupport.ColorResource(name: "TranslationBorder", bundle: resourceBundle)

    /// The "WarningColor" asset catalog color resource.
    static let warning = DeveloperToolsSupport.ColorResource(name: "WarningColor", bundle: resourceBundle)

    /// The "mainBg" asset catalog color resource.
    static let mainBg = DeveloperToolsSupport.ColorResource(name: "mainBg", bundle: resourceBundle)

    /// The "mainLighteBg" asset catalog color resource.
    static let mainLighteBg = DeveloperToolsSupport.ColorResource(name: "mainLighteBg", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "AC" asset catalog image resource.
    static let AC = DeveloperToolsSupport.ImageResource(name: "AC", bundle: resourceBundle)

    /// The "AD" asset catalog image resource.
    static let AD = DeveloperToolsSupport.ImageResource(name: "AD", bundle: resourceBundle)

    /// The "AE" asset catalog image resource.
    static let AE = DeveloperToolsSupport.ImageResource(name: "AE", bundle: resourceBundle)

    /// The "AF" asset catalog image resource.
    static let AF = DeveloperToolsSupport.ImageResource(name: "AF", bundle: resourceBundle)

    /// The "AG" asset catalog image resource.
    static let AG = DeveloperToolsSupport.ImageResource(name: "AG", bundle: resourceBundle)

    /// The "AI" asset catalog image resource.
    static let AI = DeveloperToolsSupport.ImageResource(name: "AI", bundle: resourceBundle)

    /// The "AL" asset catalog image resource.
    static let AL = DeveloperToolsSupport.ImageResource(name: "AL", bundle: resourceBundle)

    /// The "AM" asset catalog image resource.
    static let AM = DeveloperToolsSupport.ImageResource(name: "AM", bundle: resourceBundle)

    /// The "AO" asset catalog image resource.
    static let AO = DeveloperToolsSupport.ImageResource(name: "AO", bundle: resourceBundle)

    /// The "AQ" asset catalog image resource.
    static let AQ = DeveloperToolsSupport.ImageResource(name: "AQ", bundle: resourceBundle)

    /// The "AR" asset catalog image resource.
    static let AR = DeveloperToolsSupport.ImageResource(name: "AR", bundle: resourceBundle)

    /// The "AS" asset catalog image resource.
    static let AS = DeveloperToolsSupport.ImageResource(name: "AS", bundle: resourceBundle)

    /// The "AT" asset catalog image resource.
    static let AT = DeveloperToolsSupport.ImageResource(name: "AT", bundle: resourceBundle)

    /// The "AU" asset catalog image resource.
    static let AU = DeveloperToolsSupport.ImageResource(name: "AU", bundle: resourceBundle)

    /// The "AW" asset catalog image resource.
    static let AW = DeveloperToolsSupport.ImageResource(name: "AW", bundle: resourceBundle)

    /// The "AX" asset catalog image resource.
    static let AX = DeveloperToolsSupport.ImageResource(name: "AX", bundle: resourceBundle)

    /// The "AZ" asset catalog image resource.
    static let AZ = DeveloperToolsSupport.ImageResource(name: "AZ", bundle: resourceBundle)

    /// The "BA" asset catalog image resource.
    static let BA = DeveloperToolsSupport.ImageResource(name: "BA", bundle: resourceBundle)

    /// The "BB" asset catalog image resource.
    static let BB = DeveloperToolsSupport.ImageResource(name: "BB", bundle: resourceBundle)

    /// The "BD" asset catalog image resource.
    static let BD = DeveloperToolsSupport.ImageResource(name: "BD", bundle: resourceBundle)

    /// The "BE" asset catalog image resource.
    static let BE = DeveloperToolsSupport.ImageResource(name: "BE", bundle: resourceBundle)

    /// The "BF" asset catalog image resource.
    static let BF = DeveloperToolsSupport.ImageResource(name: "BF", bundle: resourceBundle)

    /// The "BG" asset catalog image resource.
    static let BG = DeveloperToolsSupport.ImageResource(name: "BG", bundle: resourceBundle)

    /// The "BH" asset catalog image resource.
    static let BH = DeveloperToolsSupport.ImageResource(name: "BH", bundle: resourceBundle)

    /// The "BI" asset catalog image resource.
    static let BI = DeveloperToolsSupport.ImageResource(name: "BI", bundle: resourceBundle)

    /// The "BJ" asset catalog image resource.
    static let BJ = DeveloperToolsSupport.ImageResource(name: "BJ", bundle: resourceBundle)

    /// The "BL" asset catalog image resource.
    static let BL = DeveloperToolsSupport.ImageResource(name: "BL", bundle: resourceBundle)

    /// The "BM" asset catalog image resource.
    static let BM = DeveloperToolsSupport.ImageResource(name: "BM", bundle: resourceBundle)

    /// The "BN" asset catalog image resource.
    static let BN = DeveloperToolsSupport.ImageResource(name: "BN", bundle: resourceBundle)

    /// The "BO" asset catalog image resource.
    static let BO = DeveloperToolsSupport.ImageResource(name: "BO", bundle: resourceBundle)

    /// The "BQ" asset catalog image resource.
    static let BQ = DeveloperToolsSupport.ImageResource(name: "BQ", bundle: resourceBundle)

    /// The "BR" asset catalog image resource.
    static let BR = DeveloperToolsSupport.ImageResource(name: "BR", bundle: resourceBundle)

    /// The "BS" asset catalog image resource.
    static let BS = DeveloperToolsSupport.ImageResource(name: "BS", bundle: resourceBundle)

    /// The "BT" asset catalog image resource.
    static let BT = DeveloperToolsSupport.ImageResource(name: "BT", bundle: resourceBundle)

    /// The "BV" asset catalog image resource.
    static let BV = DeveloperToolsSupport.ImageResource(name: "BV", bundle: resourceBundle)

    /// The "BW" asset catalog image resource.
    static let BW = DeveloperToolsSupport.ImageResource(name: "BW", bundle: resourceBundle)

    /// The "BY" asset catalog image resource.
    static let BY = DeveloperToolsSupport.ImageResource(name: "BY", bundle: resourceBundle)

    /// The "BZ" asset catalog image resource.
    static let BZ = DeveloperToolsSupport.ImageResource(name: "BZ", bundle: resourceBundle)

    /// The "CA" asset catalog image resource.
    static let CA = DeveloperToolsSupport.ImageResource(name: "CA", bundle: resourceBundle)

    /// The "CC" asset catalog image resource.
    static let CC = DeveloperToolsSupport.ImageResource(name: "CC", bundle: resourceBundle)

    /// The "CD" asset catalog image resource.
    static let CD = DeveloperToolsSupport.ImageResource(name: "CD", bundle: resourceBundle)

    /// The "CF" asset catalog image resource.
    static let CF = DeveloperToolsSupport.ImageResource(name: "CF", bundle: resourceBundle)

    /// The "CG" asset catalog image resource.
    static let CG = DeveloperToolsSupport.ImageResource(name: "CG", bundle: resourceBundle)

    /// The "CH" asset catalog image resource.
    static let CH = DeveloperToolsSupport.ImageResource(name: "CH", bundle: resourceBundle)

    /// The "CI" asset catalog image resource.
    static let CI = DeveloperToolsSupport.ImageResource(name: "CI", bundle: resourceBundle)

    /// The "CK" asset catalog image resource.
    static let CK = DeveloperToolsSupport.ImageResource(name: "CK", bundle: resourceBundle)

    /// The "CL" asset catalog image resource.
    static let CL = DeveloperToolsSupport.ImageResource(name: "CL", bundle: resourceBundle)

    /// The "CM" asset catalog image resource.
    static let CM = DeveloperToolsSupport.ImageResource(name: "CM", bundle: resourceBundle)

    /// The "CN" asset catalog image resource.
    static let CN = DeveloperToolsSupport.ImageResource(name: "CN", bundle: resourceBundle)

    /// The "CO" asset catalog image resource.
    static let CO = DeveloperToolsSupport.ImageResource(name: "CO", bundle: resourceBundle)

    /// The "CR" asset catalog image resource.
    static let CR = DeveloperToolsSupport.ImageResource(name: "CR", bundle: resourceBundle)

    /// The "CU" asset catalog image resource.
    static let CU = DeveloperToolsSupport.ImageResource(name: "CU", bundle: resourceBundle)

    /// The "CV" asset catalog image resource.
    static let CV = DeveloperToolsSupport.ImageResource(name: "CV", bundle: resourceBundle)

    /// The "CW" asset catalog image resource.
    static let CW = DeveloperToolsSupport.ImageResource(name: "CW", bundle: resourceBundle)

    /// The "CX" asset catalog image resource.
    static let CX = DeveloperToolsSupport.ImageResource(name: "CX", bundle: resourceBundle)

    /// The "CY" asset catalog image resource.
    static let CY = DeveloperToolsSupport.ImageResource(name: "CY", bundle: resourceBundle)

    /// The "CZ" asset catalog image resource.
    static let CZ = DeveloperToolsSupport.ImageResource(name: "CZ", bundle: resourceBundle)

    /// The "DE" asset catalog image resource.
    static let DE = DeveloperToolsSupport.ImageResource(name: "DE", bundle: resourceBundle)

    /// The "DJ" asset catalog image resource.
    static let DJ = DeveloperToolsSupport.ImageResource(name: "DJ", bundle: resourceBundle)

    /// The "DK" asset catalog image resource.
    static let DK = DeveloperToolsSupport.ImageResource(name: "DK", bundle: resourceBundle)

    /// The "DM" asset catalog image resource.
    static let DM = DeveloperToolsSupport.ImageResource(name: "DM", bundle: resourceBundle)

    /// The "DO" asset catalog image resource.
    static let DO = DeveloperToolsSupport.ImageResource(name: "DO", bundle: resourceBundle)

    /// The "DZ" asset catalog image resource.
    static let DZ = DeveloperToolsSupport.ImageResource(name: "DZ", bundle: resourceBundle)

    /// The "EC" asset catalog image resource.
    static let EC = DeveloperToolsSupport.ImageResource(name: "EC", bundle: resourceBundle)

    /// The "EE" asset catalog image resource.
    static let EE = DeveloperToolsSupport.ImageResource(name: "EE", bundle: resourceBundle)

    /// The "EG" asset catalog image resource.
    static let EG = DeveloperToolsSupport.ImageResource(name: "EG", bundle: resourceBundle)

    /// The "EH" asset catalog image resource.
    static let EH = DeveloperToolsSupport.ImageResource(name: "EH", bundle: resourceBundle)

    /// The "ER" asset catalog image resource.
    static let ER = DeveloperToolsSupport.ImageResource(name: "ER", bundle: resourceBundle)

    /// The "ES" asset catalog image resource.
    static let ES = DeveloperToolsSupport.ImageResource(name: "ES", bundle: resourceBundle)

    /// The "ET" asset catalog image resource.
    static let ET = DeveloperToolsSupport.ImageResource(name: "ET", bundle: resourceBundle)

    /// The "FI" asset catalog image resource.
    static let FI = DeveloperToolsSupport.ImageResource(name: "FI", bundle: resourceBundle)

    /// The "FJ" asset catalog image resource.
    static let FJ = DeveloperToolsSupport.ImageResource(name: "FJ", bundle: resourceBundle)

    /// The "FK" asset catalog image resource.
    static let FK = DeveloperToolsSupport.ImageResource(name: "FK", bundle: resourceBundle)

    /// The "FM" asset catalog image resource.
    static let FM = DeveloperToolsSupport.ImageResource(name: "FM", bundle: resourceBundle)

    /// The "FO" asset catalog image resource.
    static let FO = DeveloperToolsSupport.ImageResource(name: "FO", bundle: resourceBundle)

    /// The "FR" asset catalog image resource.
    static let FR = DeveloperToolsSupport.ImageResource(name: "FR", bundle: resourceBundle)

    /// The "FX" asset catalog image resource.
    static let FX = DeveloperToolsSupport.ImageResource(name: "FX", bundle: resourceBundle)

    /// The "GA" asset catalog image resource.
    static let GA = DeveloperToolsSupport.ImageResource(name: "GA", bundle: resourceBundle)

    /// The "GB" asset catalog image resource.
    static let GB = DeveloperToolsSupport.ImageResource(name: "GB", bundle: resourceBundle)

    /// The "GD" asset catalog image resource.
    static let GD = DeveloperToolsSupport.ImageResource(name: "GD", bundle: resourceBundle)

    /// The "GE" asset catalog image resource.
    static let GE = DeveloperToolsSupport.ImageResource(name: "GE", bundle: resourceBundle)

    /// The "GF" asset catalog image resource.
    static let GF = DeveloperToolsSupport.ImageResource(name: "GF", bundle: resourceBundle)

    /// The "GG" asset catalog image resource.
    static let GG = DeveloperToolsSupport.ImageResource(name: "GG", bundle: resourceBundle)

    /// The "GH" asset catalog image resource.
    static let GH = DeveloperToolsSupport.ImageResource(name: "GH", bundle: resourceBundle)

    /// The "GI" asset catalog image resource.
    static let GI = DeveloperToolsSupport.ImageResource(name: "GI", bundle: resourceBundle)

    /// The "GL" asset catalog image resource.
    static let GL = DeveloperToolsSupport.ImageResource(name: "GL", bundle: resourceBundle)

    /// The "GM" asset catalog image resource.
    static let GM = DeveloperToolsSupport.ImageResource(name: "GM", bundle: resourceBundle)

    /// The "GN" asset catalog image resource.
    static let GN = DeveloperToolsSupport.ImageResource(name: "GN", bundle: resourceBundle)

    /// The "GP" asset catalog image resource.
    static let GP = DeveloperToolsSupport.ImageResource(name: "GP", bundle: resourceBundle)

    /// The "GQ" asset catalog image resource.
    static let GQ = DeveloperToolsSupport.ImageResource(name: "GQ", bundle: resourceBundle)

    /// The "GR" asset catalog image resource.
    static let GR = DeveloperToolsSupport.ImageResource(name: "GR", bundle: resourceBundle)

    /// The "GS" asset catalog image resource.
    static let GS = DeveloperToolsSupport.ImageResource(name: "GS", bundle: resourceBundle)

    /// The "GT" asset catalog image resource.
    static let GT = DeveloperToolsSupport.ImageResource(name: "GT", bundle: resourceBundle)

    /// The "GU" asset catalog image resource.
    static let GU = DeveloperToolsSupport.ImageResource(name: "GU", bundle: resourceBundle)

    /// The "GW" asset catalog image resource.
    static let GW = DeveloperToolsSupport.ImageResource(name: "GW", bundle: resourceBundle)

    /// The "GY" asset catalog image resource.
    static let GY = DeveloperToolsSupport.ImageResource(name: "GY", bundle: resourceBundle)

    /// The "Group 305" asset catalog image resource.
    static let group305 = DeveloperToolsSupport.ImageResource(name: "Group 305", bundle: resourceBundle)

    /// The "Group 306" asset catalog image resource.
    static let group306 = DeveloperToolsSupport.ImageResource(name: "Group 306", bundle: resourceBundle)

    /// The "HK" asset catalog image resource.
    static let HK = DeveloperToolsSupport.ImageResource(name: "HK", bundle: resourceBundle)

    /// The "HM" asset catalog image resource.
    static let HM = DeveloperToolsSupport.ImageResource(name: "HM", bundle: resourceBundle)

    /// The "HN" asset catalog image resource.
    static let HN = DeveloperToolsSupport.ImageResource(name: "HN", bundle: resourceBundle)

    /// The "HR" asset catalog image resource.
    static let HR = DeveloperToolsSupport.ImageResource(name: "HR", bundle: resourceBundle)

    /// The "HT" asset catalog image resource.
    static let HT = DeveloperToolsSupport.ImageResource(name: "HT", bundle: resourceBundle)

    /// The "HU" asset catalog image resource.
    static let HU = DeveloperToolsSupport.ImageResource(name: "HU", bundle: resourceBundle)

    /// The "ID" asset catalog image resource.
    static let ID = DeveloperToolsSupport.ImageResource(name: "ID", bundle: resourceBundle)

    /// The "IE" asset catalog image resource.
    static let IE = DeveloperToolsSupport.ImageResource(name: "IE", bundle: resourceBundle)

    /// The "IL" asset catalog image resource.
    static let IL = DeveloperToolsSupport.ImageResource(name: "IL", bundle: resourceBundle)

    /// The "IM" asset catalog image resource.
    static let IM = DeveloperToolsSupport.ImageResource(name: "IM", bundle: resourceBundle)

    /// The "IN" asset catalog image resource.
    static let IN = DeveloperToolsSupport.ImageResource(name: "IN", bundle: resourceBundle)

    /// The "IO" asset catalog image resource.
    static let IO = DeveloperToolsSupport.ImageResource(name: "IO", bundle: resourceBundle)

    /// The "IQ" asset catalog image resource.
    static let IQ = DeveloperToolsSupport.ImageResource(name: "IQ", bundle: resourceBundle)

    /// The "IR" asset catalog image resource.
    static let IR = DeveloperToolsSupport.ImageResource(name: "IR", bundle: resourceBundle)

    /// The "IS" asset catalog image resource.
    static let IS = DeveloperToolsSupport.ImageResource(name: "IS", bundle: resourceBundle)

    /// The "IT" asset catalog image resource.
    static let IT = DeveloperToolsSupport.ImageResource(name: "IT", bundle: resourceBundle)

    /// The "JE" asset catalog image resource.
    static let JE = DeveloperToolsSupport.ImageResource(name: "JE", bundle: resourceBundle)

    /// The "JM" asset catalog image resource.
    static let JM = DeveloperToolsSupport.ImageResource(name: "JM", bundle: resourceBundle)

    /// The "JO" asset catalog image resource.
    static let JO = DeveloperToolsSupport.ImageResource(name: "JO", bundle: resourceBundle)

    /// The "JP" asset catalog image resource.
    static let JP = DeveloperToolsSupport.ImageResource(name: "JP", bundle: resourceBundle)

    /// The "KE" asset catalog image resource.
    static let KE = DeveloperToolsSupport.ImageResource(name: "KE", bundle: resourceBundle)

    /// The "KG" asset catalog image resource.
    static let KG = DeveloperToolsSupport.ImageResource(name: "KG", bundle: resourceBundle)

    /// The "KH" asset catalog image resource.
    static let KH = DeveloperToolsSupport.ImageResource(name: "KH", bundle: resourceBundle)

    /// The "KI" asset catalog image resource.
    static let KI = DeveloperToolsSupport.ImageResource(name: "KI", bundle: resourceBundle)

    /// The "KM" asset catalog image resource.
    static let KM = DeveloperToolsSupport.ImageResource(name: "KM", bundle: resourceBundle)

    /// The "KN" asset catalog image resource.
    static let KN = DeveloperToolsSupport.ImageResource(name: "KN", bundle: resourceBundle)

    /// The "KP" asset catalog image resource.
    static let KP = DeveloperToolsSupport.ImageResource(name: "KP", bundle: resourceBundle)

    /// The "KR" asset catalog image resource.
    static let KR = DeveloperToolsSupport.ImageResource(name: "KR", bundle: resourceBundle)

    /// The "KW" asset catalog image resource.
    static let KW = DeveloperToolsSupport.ImageResource(name: "KW", bundle: resourceBundle)

    /// The "KY" asset catalog image resource.
    static let KY = DeveloperToolsSupport.ImageResource(name: "KY", bundle: resourceBundle)

    /// The "KZ" asset catalog image resource.
    static let KZ = DeveloperToolsSupport.ImageResource(name: "KZ", bundle: resourceBundle)

    /// The "LA" asset catalog image resource.
    static let LA = DeveloperToolsSupport.ImageResource(name: "LA", bundle: resourceBundle)

    /// The "LB" asset catalog image resource.
    static let LB = DeveloperToolsSupport.ImageResource(name: "LB", bundle: resourceBundle)

    /// The "LC" asset catalog image resource.
    static let LC = DeveloperToolsSupport.ImageResource(name: "LC", bundle: resourceBundle)

    /// The "LI" asset catalog image resource.
    static let LI = DeveloperToolsSupport.ImageResource(name: "LI", bundle: resourceBundle)

    /// The "LK" asset catalog image resource.
    static let LK = DeveloperToolsSupport.ImageResource(name: "LK", bundle: resourceBundle)

    /// The "LR" asset catalog image resource.
    static let LR = DeveloperToolsSupport.ImageResource(name: "LR", bundle: resourceBundle)

    /// The "LS" asset catalog image resource.
    static let LS = DeveloperToolsSupport.ImageResource(name: "LS", bundle: resourceBundle)

    /// The "LT" asset catalog image resource.
    static let LT = DeveloperToolsSupport.ImageResource(name: "LT", bundle: resourceBundle)

    /// The "LU" asset catalog image resource.
    static let LU = DeveloperToolsSupport.ImageResource(name: "LU", bundle: resourceBundle)

    /// The "LV" asset catalog image resource.
    static let LV = DeveloperToolsSupport.ImageResource(name: "LV", bundle: resourceBundle)

    /// The "LY" asset catalog image resource.
    static let LY = DeveloperToolsSupport.ImageResource(name: "LY", bundle: resourceBundle)

    /// The "MA" asset catalog image resource.
    static let MA = DeveloperToolsSupport.ImageResource(name: "MA", bundle: resourceBundle)

    /// The "MC" asset catalog image resource.
    static let MC = DeveloperToolsSupport.ImageResource(name: "MC", bundle: resourceBundle)

    /// The "MD" asset catalog image resource.
    static let MD = DeveloperToolsSupport.ImageResource(name: "MD", bundle: resourceBundle)

    /// The "ME" asset catalog image resource.
    static let ME = DeveloperToolsSupport.ImageResource(name: "ME", bundle: resourceBundle)

    /// The "MF" asset catalog image resource.
    static let MF = DeveloperToolsSupport.ImageResource(name: "MF", bundle: resourceBundle)

    /// The "MG" asset catalog image resource.
    static let MG = DeveloperToolsSupport.ImageResource(name: "MG", bundle: resourceBundle)

    /// The "MH" asset catalog image resource.
    static let MH = DeveloperToolsSupport.ImageResource(name: "MH", bundle: resourceBundle)

    /// The "MK" asset catalog image resource.
    static let MK = DeveloperToolsSupport.ImageResource(name: "MK", bundle: resourceBundle)

    /// The "ML" asset catalog image resource.
    static let ML = DeveloperToolsSupport.ImageResource(name: "ML", bundle: resourceBundle)

    /// The "MM" asset catalog image resource.
    static let MM = DeveloperToolsSupport.ImageResource(name: "MM", bundle: resourceBundle)

    /// The "MN" asset catalog image resource.
    static let MN = DeveloperToolsSupport.ImageResource(name: "MN", bundle: resourceBundle)

    /// The "MO" asset catalog image resource.
    static let MO = DeveloperToolsSupport.ImageResource(name: "MO", bundle: resourceBundle)

    /// The "MP" asset catalog image resource.
    static let MP = DeveloperToolsSupport.ImageResource(name: "MP", bundle: resourceBundle)

    /// The "MQ" asset catalog image resource.
    static let MQ = DeveloperToolsSupport.ImageResource(name: "MQ", bundle: resourceBundle)

    /// The "MR" asset catalog image resource.
    static let MR = DeveloperToolsSupport.ImageResource(name: "MR", bundle: resourceBundle)

    /// The "MS" asset catalog image resource.
    static let MS = DeveloperToolsSupport.ImageResource(name: "MS", bundle: resourceBundle)

    /// The "MT" asset catalog image resource.
    static let MT = DeveloperToolsSupport.ImageResource(name: "MT", bundle: resourceBundle)

    /// The "MU" asset catalog image resource.
    static let MU = DeveloperToolsSupport.ImageResource(name: "MU", bundle: resourceBundle)

    /// The "MV" asset catalog image resource.
    static let MV = DeveloperToolsSupport.ImageResource(name: "MV", bundle: resourceBundle)

    /// The "MW" asset catalog image resource.
    static let MW = DeveloperToolsSupport.ImageResource(name: "MW", bundle: resourceBundle)

    /// The "MX" asset catalog image resource.
    static let MX = DeveloperToolsSupport.ImageResource(name: "MX", bundle: resourceBundle)

    /// The "MY" asset catalog image resource.
    static let MY = DeveloperToolsSupport.ImageResource(name: "MY", bundle: resourceBundle)

    /// The "MZ" asset catalog image resource.
    static let MZ = DeveloperToolsSupport.ImageResource(name: "MZ", bundle: resourceBundle)

    /// The "NA" asset catalog image resource.
    static let NA = DeveloperToolsSupport.ImageResource(name: "NA", bundle: resourceBundle)

    /// The "NC" asset catalog image resource.
    static let NC = DeveloperToolsSupport.ImageResource(name: "NC", bundle: resourceBundle)

    /// The "NE" asset catalog image resource.
    static let NE = DeveloperToolsSupport.ImageResource(name: "NE", bundle: resourceBundle)

    /// The "NF" asset catalog image resource.
    static let NF = DeveloperToolsSupport.ImageResource(name: "NF", bundle: resourceBundle)

    /// The "NG" asset catalog image resource.
    static let NG = DeveloperToolsSupport.ImageResource(name: "NG", bundle: resourceBundle)

    /// The "NI" asset catalog image resource.
    static let NI = DeveloperToolsSupport.ImageResource(name: "NI", bundle: resourceBundle)

    /// The "NL" asset catalog image resource.
    static let NL = DeveloperToolsSupport.ImageResource(name: "NL", bundle: resourceBundle)

    /// The "NO" asset catalog image resource.
    static let NO = DeveloperToolsSupport.ImageResource(name: "NO", bundle: resourceBundle)

    /// The "NP" asset catalog image resource.
    static let NP = DeveloperToolsSupport.ImageResource(name: "NP", bundle: resourceBundle)

    /// The "NR" asset catalog image resource.
    static let NR = DeveloperToolsSupport.ImageResource(name: "NR", bundle: resourceBundle)

    /// The "NU" asset catalog image resource.
    static let NU = DeveloperToolsSupport.ImageResource(name: "NU", bundle: resourceBundle)

    /// The "NZ" asset catalog image resource.
    static let NZ = DeveloperToolsSupport.ImageResource(name: "NZ", bundle: resourceBundle)

    /// The "OM" asset catalog image resource.
    static let OM = DeveloperToolsSupport.ImageResource(name: "OM", bundle: resourceBundle)

    /// The "PA" asset catalog image resource.
    static let PA = DeveloperToolsSupport.ImageResource(name: "PA", bundle: resourceBundle)

    /// The "PE" asset catalog image resource.
    static let PE = DeveloperToolsSupport.ImageResource(name: "PE", bundle: resourceBundle)

    /// The "PF" asset catalog image resource.
    static let PF = DeveloperToolsSupport.ImageResource(name: "PF", bundle: resourceBundle)

    /// The "PG" asset catalog image resource.
    static let PG = DeveloperToolsSupport.ImageResource(name: "PG", bundle: resourceBundle)

    /// The "PH" asset catalog image resource.
    static let PH = DeveloperToolsSupport.ImageResource(name: "PH", bundle: resourceBundle)

    /// The "PK" asset catalog image resource.
    static let PK = DeveloperToolsSupport.ImageResource(name: "PK", bundle: resourceBundle)

    /// The "PL" asset catalog image resource.
    static let PL = DeveloperToolsSupport.ImageResource(name: "PL", bundle: resourceBundle)

    /// The "PM" asset catalog image resource.
    static let PM = DeveloperToolsSupport.ImageResource(name: "PM", bundle: resourceBundle)

    /// The "PN" asset catalog image resource.
    static let PN = DeveloperToolsSupport.ImageResource(name: "PN", bundle: resourceBundle)

    /// The "PR" asset catalog image resource.
    static let PR = DeveloperToolsSupport.ImageResource(name: "PR", bundle: resourceBundle)

    /// The "PS" asset catalog image resource.
    static let PS = DeveloperToolsSupport.ImageResource(name: "PS", bundle: resourceBundle)

    /// The "PT" asset catalog image resource.
    static let PT = DeveloperToolsSupport.ImageResource(name: "PT", bundle: resourceBundle)

    /// The "PW" asset catalog image resource.
    static let PW = DeveloperToolsSupport.ImageResource(name: "PW", bundle: resourceBundle)

    /// The "PY" asset catalog image resource.
    static let PY = DeveloperToolsSupport.ImageResource(name: "PY", bundle: resourceBundle)

    /// The "Planet" asset catalog image resource.
    static let planet = DeveloperToolsSupport.ImageResource(name: "Planet", bundle: resourceBundle)

    /// The "Planet2" asset catalog image resource.
    static let planet2 = DeveloperToolsSupport.ImageResource(name: "Planet2", bundle: resourceBundle)

    /// The "PlanetRightPS" asset catalog image resource.
    static let planetRightPS = DeveloperToolsSupport.ImageResource(name: "PlanetRightPS", bundle: resourceBundle)

    /// The "Polygon 4" asset catalog image resource.
    static let polygon4 = DeveloperToolsSupport.ImageResource(name: "Polygon 4", bundle: resourceBundle)

    /// The "QA" asset catalog image resource.
    static let QA = DeveloperToolsSupport.ImageResource(name: "QA", bundle: resourceBundle)

    /// The "RE" asset catalog image resource.
    static let RE = DeveloperToolsSupport.ImageResource(name: "RE", bundle: resourceBundle)

    /// The "RO" asset catalog image resource.
    static let RO = DeveloperToolsSupport.ImageResource(name: "RO", bundle: resourceBundle)

    /// The "RS" asset catalog image resource.
    static let RS = DeveloperToolsSupport.ImageResource(name: "RS", bundle: resourceBundle)

    /// The "RU" asset catalog image resource.
    static let RU = DeveloperToolsSupport.ImageResource(name: "RU", bundle: resourceBundle)

    /// The "RW" asset catalog image resource.
    static let RW = DeveloperToolsSupport.ImageResource(name: "RW", bundle: resourceBundle)

    /// The "SA" asset catalog image resource.
    static let SA = DeveloperToolsSupport.ImageResource(name: "SA", bundle: resourceBundle)

    /// The "SB" asset catalog image resource.
    static let SB = DeveloperToolsSupport.ImageResource(name: "SB", bundle: resourceBundle)

    /// The "SC" asset catalog image resource.
    static let SC = DeveloperToolsSupport.ImageResource(name: "SC", bundle: resourceBundle)

    /// The "SD" asset catalog image resource.
    static let SD = DeveloperToolsSupport.ImageResource(name: "SD", bundle: resourceBundle)

    /// The "SE" asset catalog image resource.
    static let SE = DeveloperToolsSupport.ImageResource(name: "SE", bundle: resourceBundle)

    /// The "SG" asset catalog image resource.
    static let SG = DeveloperToolsSupport.ImageResource(name: "SG", bundle: resourceBundle)

    /// The "SH" asset catalog image resource.
    static let SH = DeveloperToolsSupport.ImageResource(name: "SH", bundle: resourceBundle)

    /// The "SI" asset catalog image resource.
    static let SI = DeveloperToolsSupport.ImageResource(name: "SI", bundle: resourceBundle)

    /// The "SJ" asset catalog image resource.
    static let SJ = DeveloperToolsSupport.ImageResource(name: "SJ", bundle: resourceBundle)

    /// The "SK" asset catalog image resource.
    static let SK = DeveloperToolsSupport.ImageResource(name: "SK", bundle: resourceBundle)

    /// The "SL" asset catalog image resource.
    static let SL = DeveloperToolsSupport.ImageResource(name: "SL", bundle: resourceBundle)

    /// The "SM" asset catalog image resource.
    static let SM = DeveloperToolsSupport.ImageResource(name: "SM", bundle: resourceBundle)

    /// The "SN" asset catalog image resource.
    static let SN = DeveloperToolsSupport.ImageResource(name: "SN", bundle: resourceBundle)

    /// The "SO" asset catalog image resource.
    static let SO = DeveloperToolsSupport.ImageResource(name: "SO", bundle: resourceBundle)

    /// The "SR" asset catalog image resource.
    static let SR = DeveloperToolsSupport.ImageResource(name: "SR", bundle: resourceBundle)

    /// The "SS" asset catalog image resource.
    static let SS = DeveloperToolsSupport.ImageResource(name: "SS", bundle: resourceBundle)

    /// The "ST" asset catalog image resource.
    static let ST = DeveloperToolsSupport.ImageResource(name: "ST", bundle: resourceBundle)

    /// The "SV" asset catalog image resource.
    static let SV = DeveloperToolsSupport.ImageResource(name: "SV", bundle: resourceBundle)

    /// The "SX" asset catalog image resource.
    static let SX = DeveloperToolsSupport.ImageResource(name: "SX", bundle: resourceBundle)

    /// The "SY" asset catalog image resource.
    static let SY = DeveloperToolsSupport.ImageResource(name: "SY", bundle: resourceBundle)

    /// The "SZ" asset catalog image resource.
    static let SZ = DeveloperToolsSupport.ImageResource(name: "SZ", bundle: resourceBundle)

    /// The "SpeechVoice" asset catalog image resource.
    static let speechVoice = DeveloperToolsSupport.ImageResource(name: "SpeechVoice", bundle: resourceBundle)

    /// The "TC" asset catalog image resource.
    static let TC = DeveloperToolsSupport.ImageResource(name: "TC", bundle: resourceBundle)

    /// The "TD" asset catalog image resource.
    static let TD = DeveloperToolsSupport.ImageResource(name: "TD", bundle: resourceBundle)

    /// The "TF" asset catalog image resource.
    static let TF = DeveloperToolsSupport.ImageResource(name: "TF", bundle: resourceBundle)

    /// The "TG" asset catalog image resource.
    static let TG = DeveloperToolsSupport.ImageResource(name: "TG", bundle: resourceBundle)

    /// The "TH" asset catalog image resource.
    static let TH = DeveloperToolsSupport.ImageResource(name: "TH", bundle: resourceBundle)

    /// The "TJ" asset catalog image resource.
    static let TJ = DeveloperToolsSupport.ImageResource(name: "TJ", bundle: resourceBundle)

    /// The "TK" asset catalog image resource.
    static let TK = DeveloperToolsSupport.ImageResource(name: "TK", bundle: resourceBundle)

    /// The "TL" asset catalog image resource.
    static let TL = DeveloperToolsSupport.ImageResource(name: "TL", bundle: resourceBundle)

    /// The "TM" asset catalog image resource.
    static let TM = DeveloperToolsSupport.ImageResource(name: "TM", bundle: resourceBundle)

    /// The "TN" asset catalog image resource.
    static let TN = DeveloperToolsSupport.ImageResource(name: "TN", bundle: resourceBundle)

    /// The "TO" asset catalog image resource.
    static let TO = DeveloperToolsSupport.ImageResource(name: "TO", bundle: resourceBundle)

    /// The "TR" asset catalog image resource.
    static let TR = DeveloperToolsSupport.ImageResource(name: "TR", bundle: resourceBundle)

    /// The "TT" asset catalog image resource.
    static let TT = DeveloperToolsSupport.ImageResource(name: "TT", bundle: resourceBundle)

    /// The "TV" asset catalog image resource.
    static let TV = DeveloperToolsSupport.ImageResource(name: "TV", bundle: resourceBundle)

    /// The "TW" asset catalog image resource.
    static let TW = DeveloperToolsSupport.ImageResource(name: "TW", bundle: resourceBundle)

    /// The "TZ" asset catalog image resource.
    static let TZ = DeveloperToolsSupport.ImageResource(name: "TZ", bundle: resourceBundle)

    /// The "UA" asset catalog image resource.
    static let UA = DeveloperToolsSupport.ImageResource(name: "UA", bundle: resourceBundle)

    /// The "UG" asset catalog image resource.
    static let UG = DeveloperToolsSupport.ImageResource(name: "UG", bundle: resourceBundle)

    /// The "UM" asset catalog image resource.
    static let UM = DeveloperToolsSupport.ImageResource(name: "UM", bundle: resourceBundle)

    /// The "US" asset catalog image resource.
    static let US = DeveloperToolsSupport.ImageResource(name: "US", bundle: resourceBundle)

    /// The "UY" asset catalog image resource.
    static let UY = DeveloperToolsSupport.ImageResource(name: "UY", bundle: resourceBundle)

    /// The "UZ" asset catalog image resource.
    static let UZ = DeveloperToolsSupport.ImageResource(name: "UZ", bundle: resourceBundle)

    /// The "VA" asset catalog image resource.
    static let VA = DeveloperToolsSupport.ImageResource(name: "VA", bundle: resourceBundle)

    /// The "VC" asset catalog image resource.
    static let VC = DeveloperToolsSupport.ImageResource(name: "VC", bundle: resourceBundle)

    /// The "VE" asset catalog image resource.
    static let VE = DeveloperToolsSupport.ImageResource(name: "VE", bundle: resourceBundle)

    /// The "VG" asset catalog image resource.
    static let VG = DeveloperToolsSupport.ImageResource(name: "VG", bundle: resourceBundle)

    /// The "VI" asset catalog image resource.
    static let VI = DeveloperToolsSupport.ImageResource(name: "VI", bundle: resourceBundle)

    /// The "VN" asset catalog image resource.
    static let VN = DeveloperToolsSupport.ImageResource(name: "VN", bundle: resourceBundle)

    /// The "VU" asset catalog image resource.
    static let VU = DeveloperToolsSupport.ImageResource(name: "VU", bundle: resourceBundle)

    /// The "WF" asset catalog image resource.
    static let WF = DeveloperToolsSupport.ImageResource(name: "WF", bundle: resourceBundle)

    /// The "WS" asset catalog image resource.
    static let WS = DeveloperToolsSupport.ImageResource(name: "WS", bundle: resourceBundle)

    /// The "XK" asset catalog image resource.
    static let XK = DeveloperToolsSupport.ImageResource(name: "XK", bundle: resourceBundle)

    /// The "YE" asset catalog image resource.
    static let YE = DeveloperToolsSupport.ImageResource(name: "YE", bundle: resourceBundle)

    /// The "YT" asset catalog image resource.
    static let YT = DeveloperToolsSupport.ImageResource(name: "YT", bundle: resourceBundle)

    /// The "YU" asset catalog image resource.
    static let YU = DeveloperToolsSupport.ImageResource(name: "YU", bundle: resourceBundle)

    /// The "ZA" asset catalog image resource.
    static let ZA = DeveloperToolsSupport.ImageResource(name: "ZA", bundle: resourceBundle)

    /// The "ZM" asset catalog image resource.
    static let ZM = DeveloperToolsSupport.ImageResource(name: "ZM", bundle: resourceBundle)

    /// The "ZW" asset catalog image resource.
    static let ZW = DeveloperToolsSupport.ImageResource(name: "ZW", bundle: resourceBundle)

    /// The "ad-Lock" asset catalog image resource.
    static let adLock = DeveloperToolsSupport.ImageResource(name: "ad-Lock", bundle: resourceBundle)

    /// The "asyncArrew" asset catalog image resource.
    static let asyncArrew = DeveloperToolsSupport.ImageResource(name: "asyncArrew", bundle: resourceBundle)

    /// The "backArrow" asset catalog image resource.
    static let backArrow = DeveloperToolsSupport.ImageResource(name: "backArrow", bundle: resourceBundle)

    /// The "blue microfon icon" asset catalog image resource.
    static let blueMicrofonIcon = DeveloperToolsSupport.ImageResource(name: "blue microfon icon", bundle: resourceBundle)

    /// The "closePS" asset catalog image resource.
    static let closePS = DeveloperToolsSupport.ImageResource(name: "closePS", bundle: resourceBundle)

    /// The "emojione-v1_left-check-mark" asset catalog image resource.
    static let emojioneV1LeftCheckMark = DeveloperToolsSupport.ImageResource(name: "emojione-v1_left-check-mark", bundle: resourceBundle)

    /// The "fi-sr-camera" asset catalog image resource.
    static let fiSrCamera = DeveloperToolsSupport.ImageResource(name: "fi-sr-camera", bundle: resourceBundle)

    /// The "fi-sr-comment-alt" asset catalog image resource.
    static let fiSrCommentAlt = DeveloperToolsSupport.ImageResource(name: "fi-sr-comment-alt", bundle: resourceBundle)

    /// The "fi-sr-copy" asset catalog image resource.
    static let fiSrCopy = DeveloperToolsSupport.ImageResource(name: "fi-sr-copy", bundle: resourceBundle)

    /// The "fi-sr-picture" asset catalog image resource.
    static let fiSrPicture = DeveloperToolsSupport.ImageResource(name: "fi-sr-picture", bundle: resourceBundle)

    /// The "fi-sr-share" asset catalog image resource.
    static let fiSrShare = DeveloperToolsSupport.ImageResource(name: "fi-sr-share", bundle: resourceBundle)

    /// The "fi-sr-star" asset catalog image resource.
    static let fiSrStar = DeveloperToolsSupport.ImageResource(name: "fi-sr-star", bundle: resourceBundle)

    /// The "fi-sr-text" asset catalog image resource.
    static let fiSrText = DeveloperToolsSupport.ImageResource(name: "fi-sr-text", bundle: resourceBundle)

    /// The "fi-sr-time-quarter-to" asset catalog image resource.
    static let fiSrTimeQuarterTo = DeveloperToolsSupport.ImageResource(name: "fi-sr-time-quarter-to", bundle: resourceBundle)

    /// The "fi-sr-trash" asset catalog image resource.
    static let fiSrTrash = DeveloperToolsSupport.ImageResource(name: "fi-sr-trash", bundle: resourceBundle)

    /// The "fi-sr-unlock" asset catalog image resource.
    static let fiSrUnlock = DeveloperToolsSupport.ImageResource(name: "fi-sr-unlock", bundle: resourceBundle)

    /// The "fi-sr-volume" asset catalog image resource.
    static let fiSrVolume = DeveloperToolsSupport.ImageResource(name: "fi-sr-volume", bundle: resourceBundle)

    /// The "france" asset catalog image resource.
    static let france = DeveloperToolsSupport.ImageResource(name: "france", bundle: resourceBundle)

    /// The "germany" asset catalog image resource.
    static let germany = DeveloperToolsSupport.ImageResource(name: "germany", bundle: resourceBundle)

    /// The "greece" asset catalog image resource.
    static let greece = DeveloperToolsSupport.ImageResource(name: "greece", bundle: resourceBundle)

    /// The "groupBG" asset catalog image resource.
    static let groupBG = DeveloperToolsSupport.ImageResource(name: "groupBG", bundle: resourceBundle)

    /// The "indonesia" asset catalog image resource.
    static let indonesia = DeveloperToolsSupport.ImageResource(name: "indonesia", bundle: resourceBundle)

    /// The "japan" asset catalog image resource.
    static let japan = DeveloperToolsSupport.ImageResource(name: "japan", bundle: resourceBundle)

    /// The "menuBg" asset catalog image resource.
    static let menuBg = DeveloperToolsSupport.ImageResource(name: "menuBg", bundle: resourceBundle)

    /// The "orbita" asset catalog image resource.
    static let orbita = DeveloperToolsSupport.ImageResource(name: "orbita", bundle: resourceBundle)

    #warning("The \"orbita+\" image asset name resolves to the symbol \"orbita\" which already exists. Try renaming the asset.")

    /// The "planetLeft" asset catalog image resource.
    static let planetLeft = DeveloperToolsSupport.ImageResource(name: "planetLeft", bundle: resourceBundle)

    /// The "planetLeftPS" asset catalog image resource.
    static let planetLeftPS = DeveloperToolsSupport.ImageResource(name: "planetLeftPS", bundle: resourceBundle)

    /// The "planetRight" asset catalog image resource.
    static let planetRight = DeveloperToolsSupport.ImageResource(name: "planetRight", bundle: resourceBundle)

    /// The "reclama" asset catalog image resource.
    static let reclama = DeveloperToolsSupport.ImageResource(name: "reclama", bundle: resourceBundle)

    /// The "russia" asset catalog image resource.
    static let russia = DeveloperToolsSupport.ImageResource(name: "russia", bundle: resourceBundle)

    /// The "spain" asset catalog image resource.
    static let spain = DeveloperToolsSupport.ImageResource(name: "spain", bundle: resourceBundle)

    /// The "starBg" asset catalog image resource.
    static let starBg = DeveloperToolsSupport.ImageResource(name: "starBg", bundle: resourceBundle)

    /// The "trush" asset catalog image resource.
    static let trush = DeveloperToolsSupport.ImageResource(name: "trush", bundle: resourceBundle)

    /// The "ukraine" asset catalog image resource.
    static let ukraine = DeveloperToolsSupport.ImageResource(name: "ukraine", bundle: resourceBundle)

    /// The "united-kingdom" asset catalog image resource.
    static let unitedKingdom = DeveloperToolsSupport.ImageResource(name: "united-kingdom", bundle: resourceBundle)

    /// The "united-states-of-america" asset catalog image resource.
    static let unitedStatesOfAmerica = DeveloperToolsSupport.ImageResource(name: "united-states-of-america", bundle: resourceBundle)

    /// The "voice" asset catalog image resource.
    static let voice = DeveloperToolsSupport.ImageResource(name: "voice", bundle: resourceBundle)

    /// The "windowIcon" asset catalog image resource.
    static let windowIcon = DeveloperToolsSupport.ImageResource(name: "windowIcon", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AppAccent" asset catalog color.
    static var appAccent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appAccent)
#else
        .init()
#endif
    }

    /// The "AppBackground" asset catalog color.
    static var appBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .appBackground)
#else
        .init()
#endif
    }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .buttonBackground)
#else
        .init()
#endif
    }

    /// The "ButtonText" asset catalog color.
    static var buttonText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .buttonText)
#else
        .init()
#endif
    }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cardBackground)
#else
        .init()
#endif
    }

    /// The "Divider" asset catalog color.
    static var divider: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .divider)
#else
        .init()
#endif
    }

    /// The "ErrorColor" asset catalog color.
    static var error: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .error)
#else
        .init()
#endif
    }

    /// The "InputBackground" asset catalog color.
    static var inputBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .inputBackground)
#else
        .init()
#endif
    }

    /// The "InputBorder" asset catalog color.
    static var inputBorder: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .inputBorder)
#else
        .init()
#endif
    }

    /// The "NavigationBackground" asset catalog color.
    static var navigationBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .navigationBackground)
#else
        .init()
#endif
    }

    /// The "NavigationTint" asset catalog color.
    static var navigationTint: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .navigationTint)
#else
        .init()
#endif
    }

    /// The "PlaceholderText" asset catalog color.
    static var placeholderText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .placeholderText)
#else
        .init()
#endif
    }

    /// The "PremiumGradientEnd" asset catalog color.
    static var premiumGradientEnd: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .premiumGradientEnd)
#else
        .init()
#endif
    }

    /// The "PremiumGradientStart" asset catalog color.
    static var premiumGradientStart: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .premiumGradientStart)
#else
        .init()
#endif
    }

    /// The "PrimaryText" asset catalog color.
    static var primaryText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .primaryText)
#else
        .init()
#endif
    }

    /// The "SecondaryAccent" asset catalog color.
    static var secondaryAccent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .secondaryAccent)
#else
        .init()
#endif
    }

    /// The "SecondaryBackground" asset catalog color.
    static var secondaryBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .secondaryBackground)
#else
        .init()
#endif
    }

    /// The "SecondaryText" asset catalog color.
    static var secondaryText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .secondaryText)
#else
        .init()
#endif
    }

    /// The "Shadow" asset catalog color.
    static var shadow: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .shadow)
#else
        .init()
#endif
    }

    /// The "SuccessColor" asset catalog color.
    static var success: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .success)
#else
        .init()
#endif
    }

    /// The "TabBarBackground" asset catalog color.
    static var tabBarBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabBarBackground)
#else
        .init()
#endif
    }

    /// The "TabBarTint" asset catalog color.
    static var tabBarTint: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tabBarTint)
#else
        .init()
#endif
    }

    /// The "TertiaryBackground" asset catalog color.
    static var tertiaryBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tertiaryBackground)
#else
        .init()
#endif
    }

    /// The "TertiaryText" asset catalog color.
    static var tertiaryText: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tertiaryText)
#else
        .init()
#endif
    }

    /// The "TranslationBackground" asset catalog color.
    static var translationBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .translationBackground)
#else
        .init()
#endif
    }

    /// The "TranslationBorder" asset catalog color.
    static var translationBorder: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .translationBorder)
#else
        .init()
#endif
    }

    /// The "WarningColor" asset catalog color.
    static var warning: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .warning)
#else
        .init()
#endif
    }

    /// The "mainBg" asset catalog color.
    static var mainBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainBg)
#else
        .init()
#endif
    }

    /// The "mainLighteBg" asset catalog color.
    static var mainLighteBg: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mainLighteBg)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AppAccent" asset catalog color.
    static var appAccent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appAccent)
#else
        .init()
#endif
    }

    /// The "AppBackground" asset catalog color.
    static var appBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .appBackground)
#else
        .init()
#endif
    }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .buttonBackground)
#else
        .init()
#endif
    }

    /// The "ButtonText" asset catalog color.
    static var buttonText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .buttonText)
#else
        .init()
#endif
    }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .cardBackground)
#else
        .init()
#endif
    }

    /// The "Divider" asset catalog color.
    static var divider: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .divider)
#else
        .init()
#endif
    }

    /// The "ErrorColor" asset catalog color.
    static var error: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .error)
#else
        .init()
#endif
    }

    /// The "InputBackground" asset catalog color.
    static var inputBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .inputBackground)
#else
        .init()
#endif
    }

    /// The "InputBorder" asset catalog color.
    static var inputBorder: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .inputBorder)
#else
        .init()
#endif
    }

    /// The "NavigationBackground" asset catalog color.
    static var navigationBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .navigationBackground)
#else
        .init()
#endif
    }

    /// The "NavigationTint" asset catalog color.
    static var navigationTint: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .navigationTint)
#else
        .init()
#endif
    }

    #warning("The \"PlaceholderText\" color asset name resolves to a conflicting UIColor symbol \"placeholderText\". Try renaming the asset.")

    /// The "PremiumGradientEnd" asset catalog color.
    static var premiumGradientEnd: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .premiumGradientEnd)
#else
        .init()
#endif
    }

    /// The "PremiumGradientStart" asset catalog color.
    static var premiumGradientStart: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .premiumGradientStart)
#else
        .init()
#endif
    }

    /// The "PrimaryText" asset catalog color.
    static var primaryText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .primaryText)
#else
        .init()
#endif
    }

    /// The "SecondaryAccent" asset catalog color.
    static var secondaryAccent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .secondaryAccent)
#else
        .init()
#endif
    }

    /// The "SecondaryBackground" asset catalog color.
    static var secondaryBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .secondaryBackground)
#else
        .init()
#endif
    }

    /// The "SecondaryText" asset catalog color.
    static var secondaryText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .secondaryText)
#else
        .init()
#endif
    }

    /// The "Shadow" asset catalog color.
    static var shadow: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .shadow)
#else
        .init()
#endif
    }

    /// The "SuccessColor" asset catalog color.
    static var success: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .success)
#else
        .init()
#endif
    }

    /// The "TabBarBackground" asset catalog color.
    static var tabBarBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .tabBarBackground)
#else
        .init()
#endif
    }

    /// The "TabBarTint" asset catalog color.
    static var tabBarTint: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .tabBarTint)
#else
        .init()
#endif
    }

    /// The "TertiaryBackground" asset catalog color.
    static var tertiaryBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .tertiaryBackground)
#else
        .init()
#endif
    }

    /// The "TertiaryText" asset catalog color.
    static var tertiaryText: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .tertiaryText)
#else
        .init()
#endif
    }

    /// The "TranslationBackground" asset catalog color.
    static var translationBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .translationBackground)
#else
        .init()
#endif
    }

    /// The "TranslationBorder" asset catalog color.
    static var translationBorder: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .translationBorder)
#else
        .init()
#endif
    }

    /// The "WarningColor" asset catalog color.
    static var warning: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .warning)
#else
        .init()
#endif
    }

    /// The "mainBg" asset catalog color.
    static var mainBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .mainBg)
#else
        .init()
#endif
    }

    /// The "mainLighteBg" asset catalog color.
    static var mainLighteBg: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .mainLighteBg)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AppAccent" asset catalog color.
    static var appAccent: SwiftUI.Color { .init(.appAccent) }

    /// The "AppBackground" asset catalog color.
    static var appBackground: SwiftUI.Color { .init(.appBackground) }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: SwiftUI.Color { .init(.buttonBackground) }

    /// The "ButtonText" asset catalog color.
    static var buttonText: SwiftUI.Color { .init(.buttonText) }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: SwiftUI.Color { .init(.cardBackground) }

    /// The "Divider" asset catalog color.
    static var divider: SwiftUI.Color { .init(.divider) }

    /// The "ErrorColor" asset catalog color.
    static var error: SwiftUI.Color { .init(.error) }

    /// The "InputBackground" asset catalog color.
    static var inputBackground: SwiftUI.Color { .init(.inputBackground) }

    /// The "InputBorder" asset catalog color.
    static var inputBorder: SwiftUI.Color { .init(.inputBorder) }

    /// The "NavigationBackground" asset catalog color.
    static var navigationBackground: SwiftUI.Color { .init(.navigationBackground) }

    /// The "NavigationTint" asset catalog color.
    static var navigationTint: SwiftUI.Color { .init(.navigationTint) }

    /// The "PlaceholderText" asset catalog color.
    static var placeholderText: SwiftUI.Color { .init(.placeholderText) }

    /// The "PremiumGradientEnd" asset catalog color.
    static var premiumGradientEnd: SwiftUI.Color { .init(.premiumGradientEnd) }

    /// The "PremiumGradientStart" asset catalog color.
    static var premiumGradientStart: SwiftUI.Color { .init(.premiumGradientStart) }

    /// The "PrimaryText" asset catalog color.
    static var primaryText: SwiftUI.Color { .init(.primaryText) }

    /// The "SecondaryAccent" asset catalog color.
    static var secondaryAccent: SwiftUI.Color { .init(.secondaryAccent) }

    /// The "SecondaryBackground" asset catalog color.
    static var secondaryBackground: SwiftUI.Color { .init(.secondaryBackground) }

    /// The "SecondaryText" asset catalog color.
    static var secondaryText: SwiftUI.Color { .init(.secondaryText) }

    /// The "Shadow" asset catalog color.
    static var shadow: SwiftUI.Color { .init(.shadow) }

    /// The "SuccessColor" asset catalog color.
    static var success: SwiftUI.Color { .init(.success) }

    /// The "TabBarBackground" asset catalog color.
    static var tabBarBackground: SwiftUI.Color { .init(.tabBarBackground) }

    /// The "TabBarTint" asset catalog color.
    static var tabBarTint: SwiftUI.Color { .init(.tabBarTint) }

    /// The "TertiaryBackground" asset catalog color.
    static var tertiaryBackground: SwiftUI.Color { .init(.tertiaryBackground) }

    /// The "TertiaryText" asset catalog color.
    static var tertiaryText: SwiftUI.Color { .init(.tertiaryText) }

    /// The "TranslationBackground" asset catalog color.
    static var translationBackground: SwiftUI.Color { .init(.translationBackground) }

    /// The "TranslationBorder" asset catalog color.
    static var translationBorder: SwiftUI.Color { .init(.translationBorder) }

    /// The "WarningColor" asset catalog color.
    static var warning: SwiftUI.Color { .init(.warning) }

    /// The "mainBg" asset catalog color.
    static var mainBg: SwiftUI.Color { .init(.mainBg) }

    /// The "mainLighteBg" asset catalog color.
    static var mainLighteBg: SwiftUI.Color { .init(.mainLighteBg) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AppAccent" asset catalog color.
    static var appAccent: SwiftUI.Color { .init(.appAccent) }

    /// The "AppBackground" asset catalog color.
    static var appBackground: SwiftUI.Color { .init(.appBackground) }

    /// The "ButtonBackground" asset catalog color.
    static var buttonBackground: SwiftUI.Color { .init(.buttonBackground) }

    /// The "ButtonText" asset catalog color.
    static var buttonText: SwiftUI.Color { .init(.buttonText) }

    /// The "CardBackground" asset catalog color.
    static var cardBackground: SwiftUI.Color { .init(.cardBackground) }

    /// The "Divider" asset catalog color.
    static var divider: SwiftUI.Color { .init(.divider) }

    /// The "ErrorColor" asset catalog color.
    static var error: SwiftUI.Color { .init(.error) }

    /// The "InputBackground" asset catalog color.
    static var inputBackground: SwiftUI.Color { .init(.inputBackground) }

    /// The "InputBorder" asset catalog color.
    static var inputBorder: SwiftUI.Color { .init(.inputBorder) }

    /// The "NavigationBackground" asset catalog color.
    static var navigationBackground: SwiftUI.Color { .init(.navigationBackground) }

    /// The "NavigationTint" asset catalog color.
    static var navigationTint: SwiftUI.Color { .init(.navigationTint) }

    /// The "PlaceholderText" asset catalog color.
    static var placeholderText: SwiftUI.Color { .init(.placeholderText) }

    /// The "PremiumGradientEnd" asset catalog color.
    static var premiumGradientEnd: SwiftUI.Color { .init(.premiumGradientEnd) }

    /// The "PremiumGradientStart" asset catalog color.
    static var premiumGradientStart: SwiftUI.Color { .init(.premiumGradientStart) }

    /// The "PrimaryText" asset catalog color.
    static var primaryText: SwiftUI.Color { .init(.primaryText) }

    /// The "SecondaryAccent" asset catalog color.
    static var secondaryAccent: SwiftUI.Color { .init(.secondaryAccent) }

    /// The "SecondaryBackground" asset catalog color.
    static var secondaryBackground: SwiftUI.Color { .init(.secondaryBackground) }

    /// The "SecondaryText" asset catalog color.
    static var secondaryText: SwiftUI.Color { .init(.secondaryText) }

    /// The "Shadow" asset catalog color.
    static var shadow: SwiftUI.Color { .init(.shadow) }

    /// The "SuccessColor" asset catalog color.
    static var success: SwiftUI.Color { .init(.success) }

    /// The "TabBarBackground" asset catalog color.
    static var tabBarBackground: SwiftUI.Color { .init(.tabBarBackground) }

    /// The "TabBarTint" asset catalog color.
    static var tabBarTint: SwiftUI.Color { .init(.tabBarTint) }

    /// The "TertiaryBackground" asset catalog color.
    static var tertiaryBackground: SwiftUI.Color { .init(.tertiaryBackground) }

    /// The "TertiaryText" asset catalog color.
    static var tertiaryText: SwiftUI.Color { .init(.tertiaryText) }

    /// The "TranslationBackground" asset catalog color.
    static var translationBackground: SwiftUI.Color { .init(.translationBackground) }

    /// The "TranslationBorder" asset catalog color.
    static var translationBorder: SwiftUI.Color { .init(.translationBorder) }

    /// The "WarningColor" asset catalog color.
    static var warning: SwiftUI.Color { .init(.warning) }

    /// The "mainBg" asset catalog color.
    static var mainBg: SwiftUI.Color { .init(.mainBg) }

    /// The "mainLighteBg" asset catalog color.
    static var mainLighteBg: SwiftUI.Color { .init(.mainLighteBg) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "AC" asset catalog image.
    static var AC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AC)
#else
        .init()
#endif
    }

    /// The "AD" asset catalog image.
    static var AD: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AD)
#else
        .init()
#endif
    }

    /// The "AE" asset catalog image.
    static var AE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AE)
#else
        .init()
#endif
    }

    /// The "AF" asset catalog image.
    static var AF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AF)
#else
        .init()
#endif
    }

    /// The "AG" asset catalog image.
    static var AG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AG)
#else
        .init()
#endif
    }

    /// The "AI" asset catalog image.
    static var AI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AI)
#else
        .init()
#endif
    }

    /// The "AL" asset catalog image.
    static var AL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AL)
#else
        .init()
#endif
    }

    /// The "AM" asset catalog image.
    static var AM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AM)
#else
        .init()
#endif
    }

    /// The "AO" asset catalog image.
    static var AO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AO)
#else
        .init()
#endif
    }

    /// The "AQ" asset catalog image.
    static var AQ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AQ)
#else
        .init()
#endif
    }

    /// The "AR" asset catalog image.
    static var AR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AR)
#else
        .init()
#endif
    }

    /// The "AS" asset catalog image.
    static var AS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AS)
#else
        .init()
#endif
    }

    /// The "AT" asset catalog image.
    static var AT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AT)
#else
        .init()
#endif
    }

    /// The "AU" asset catalog image.
    static var AU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AU)
#else
        .init()
#endif
    }

    /// The "AW" asset catalog image.
    static var AW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AW)
#else
        .init()
#endif
    }

    /// The "AX" asset catalog image.
    static var AX: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AX)
#else
        .init()
#endif
    }

    /// The "AZ" asset catalog image.
    static var AZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .AZ)
#else
        .init()
#endif
    }

    /// The "BA" asset catalog image.
    static var BA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BA)
#else
        .init()
#endif
    }

    /// The "BB" asset catalog image.
    static var BB: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BB)
#else
        .init()
#endif
    }

    /// The "BD" asset catalog image.
    static var BD: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BD)
#else
        .init()
#endif
    }

    /// The "BE" asset catalog image.
    static var BE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BE)
#else
        .init()
#endif
    }

    /// The "BF" asset catalog image.
    static var BF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BF)
#else
        .init()
#endif
    }

    /// The "BG" asset catalog image.
    static var BG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BG)
#else
        .init()
#endif
    }

    /// The "BH" asset catalog image.
    static var BH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BH)
#else
        .init()
#endif
    }

    /// The "BI" asset catalog image.
    static var BI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BI)
#else
        .init()
#endif
    }

    /// The "BJ" asset catalog image.
    static var BJ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BJ)
#else
        .init()
#endif
    }

    /// The "BL" asset catalog image.
    static var BL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BL)
#else
        .init()
#endif
    }

    /// The "BM" asset catalog image.
    static var BM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BM)
#else
        .init()
#endif
    }

    /// The "BN" asset catalog image.
    static var BN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BN)
#else
        .init()
#endif
    }

    /// The "BO" asset catalog image.
    static var BO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BO)
#else
        .init()
#endif
    }

    /// The "BQ" asset catalog image.
    static var BQ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BQ)
#else
        .init()
#endif
    }

    /// The "BR" asset catalog image.
    static var BR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BR)
#else
        .init()
#endif
    }

    /// The "BS" asset catalog image.
    static var BS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BS)
#else
        .init()
#endif
    }

    /// The "BT" asset catalog image.
    static var BT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BT)
#else
        .init()
#endif
    }

    /// The "BV" asset catalog image.
    static var BV: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BV)
#else
        .init()
#endif
    }

    /// The "BW" asset catalog image.
    static var BW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BW)
#else
        .init()
#endif
    }

    /// The "BY" asset catalog image.
    static var BY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BY)
#else
        .init()
#endif
    }

    /// The "BZ" asset catalog image.
    static var BZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .BZ)
#else
        .init()
#endif
    }

    /// The "CA" asset catalog image.
    static var CA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CA)
#else
        .init()
#endif
    }

    /// The "CC" asset catalog image.
    static var CC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CC)
#else
        .init()
#endif
    }

    /// The "CD" asset catalog image.
    static var CD: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CD)
#else
        .init()
#endif
    }

    /// The "CF" asset catalog image.
    static var CF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CF)
#else
        .init()
#endif
    }

    /// The "CG" asset catalog image.
    static var CG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CG)
#else
        .init()
#endif
    }

    /// The "CH" asset catalog image.
    static var CH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CH)
#else
        .init()
#endif
    }

    /// The "CI" asset catalog image.
    static var CI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CI)
#else
        .init()
#endif
    }

    /// The "CK" asset catalog image.
    static var CK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CK)
#else
        .init()
#endif
    }

    /// The "CL" asset catalog image.
    static var CL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CL)
#else
        .init()
#endif
    }

    /// The "CM" asset catalog image.
    static var CM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CM)
#else
        .init()
#endif
    }

    /// The "CN" asset catalog image.
    static var CN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CN)
#else
        .init()
#endif
    }

    /// The "CO" asset catalog image.
    static var CO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CO)
#else
        .init()
#endif
    }

    /// The "CR" asset catalog image.
    static var CR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CR)
#else
        .init()
#endif
    }

    /// The "CU" asset catalog image.
    static var CU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CU)
#else
        .init()
#endif
    }

    /// The "CV" asset catalog image.
    static var CV: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CV)
#else
        .init()
#endif
    }

    /// The "CW" asset catalog image.
    static var CW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CW)
#else
        .init()
#endif
    }

    /// The "CX" asset catalog image.
    static var CX: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CX)
#else
        .init()
#endif
    }

    /// The "CY" asset catalog image.
    static var CY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CY)
#else
        .init()
#endif
    }

    /// The "CZ" asset catalog image.
    static var CZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .CZ)
#else
        .init()
#endif
    }

    /// The "DE" asset catalog image.
    static var DE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .DE)
#else
        .init()
#endif
    }

    /// The "DJ" asset catalog image.
    static var DJ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .DJ)
#else
        .init()
#endif
    }

    /// The "DK" asset catalog image.
    static var DK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .DK)
#else
        .init()
#endif
    }

    /// The "DM" asset catalog image.
    static var DM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .DM)
#else
        .init()
#endif
    }

    /// The "DO" asset catalog image.
    static var DO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .DO)
#else
        .init()
#endif
    }

    /// The "DZ" asset catalog image.
    static var DZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .DZ)
#else
        .init()
#endif
    }

    /// The "EC" asset catalog image.
    static var EC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .EC)
#else
        .init()
#endif
    }

    /// The "EE" asset catalog image.
    static var EE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .EE)
#else
        .init()
#endif
    }

    /// The "EG" asset catalog image.
    static var EG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .EG)
#else
        .init()
#endif
    }

    /// The "EH" asset catalog image.
    static var EH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .EH)
#else
        .init()
#endif
    }

    /// The "ER" asset catalog image.
    static var ER: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ER)
#else
        .init()
#endif
    }

    /// The "ES" asset catalog image.
    static var ES: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ES)
#else
        .init()
#endif
    }

    /// The "ET" asset catalog image.
    static var ET: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ET)
#else
        .init()
#endif
    }

    /// The "FI" asset catalog image.
    static var FI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FI)
#else
        .init()
#endif
    }

    /// The "FJ" asset catalog image.
    static var FJ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FJ)
#else
        .init()
#endif
    }

    /// The "FK" asset catalog image.
    static var FK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FK)
#else
        .init()
#endif
    }

    /// The "FM" asset catalog image.
    static var FM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FM)
#else
        .init()
#endif
    }

    /// The "FO" asset catalog image.
    static var FO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FO)
#else
        .init()
#endif
    }

    /// The "FR" asset catalog image.
    static var FR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FR)
#else
        .init()
#endif
    }

    /// The "FX" asset catalog image.
    static var FX: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .FX)
#else
        .init()
#endif
    }

    /// The "GA" asset catalog image.
    static var GA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GA)
#else
        .init()
#endif
    }

    /// The "GB" asset catalog image.
    static var GB: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GB)
#else
        .init()
#endif
    }

    /// The "GD" asset catalog image.
    static var GD: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GD)
#else
        .init()
#endif
    }

    /// The "GE" asset catalog image.
    static var GE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GE)
#else
        .init()
#endif
    }

    /// The "GF" asset catalog image.
    static var GF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GF)
#else
        .init()
#endif
    }

    /// The "GG" asset catalog image.
    static var GG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GG)
#else
        .init()
#endif
    }

    /// The "GH" asset catalog image.
    static var GH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GH)
#else
        .init()
#endif
    }

    /// The "GI" asset catalog image.
    static var GI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GI)
#else
        .init()
#endif
    }

    /// The "GL" asset catalog image.
    static var GL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GL)
#else
        .init()
#endif
    }

    /// The "GM" asset catalog image.
    static var GM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GM)
#else
        .init()
#endif
    }

    /// The "GN" asset catalog image.
    static var GN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GN)
#else
        .init()
#endif
    }

    /// The "GP" asset catalog image.
    static var GP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GP)
#else
        .init()
#endif
    }

    /// The "GQ" asset catalog image.
    static var GQ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GQ)
#else
        .init()
#endif
    }

    /// The "GR" asset catalog image.
    static var GR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GR)
#else
        .init()
#endif
    }

    /// The "GS" asset catalog image.
    static var GS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GS)
#else
        .init()
#endif
    }

    /// The "GT" asset catalog image.
    static var GT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GT)
#else
        .init()
#endif
    }

    /// The "GU" asset catalog image.
    static var GU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GU)
#else
        .init()
#endif
    }

    /// The "GW" asset catalog image.
    static var GW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GW)
#else
        .init()
#endif
    }

    /// The "GY" asset catalog image.
    static var GY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .GY)
#else
        .init()
#endif
    }

    /// The "Group 305" asset catalog image.
    static var group305: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .group305)
#else
        .init()
#endif
    }

    /// The "Group 306" asset catalog image.
    static var group306: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .group306)
#else
        .init()
#endif
    }

    /// The "HK" asset catalog image.
    static var HK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .HK)
#else
        .init()
#endif
    }

    /// The "HM" asset catalog image.
    static var HM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .HM)
#else
        .init()
#endif
    }

    /// The "HN" asset catalog image.
    static var HN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .HN)
#else
        .init()
#endif
    }

    /// The "HR" asset catalog image.
    static var HR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .HR)
#else
        .init()
#endif
    }

    /// The "HT" asset catalog image.
    static var HT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .HT)
#else
        .init()
#endif
    }

    /// The "HU" asset catalog image.
    static var HU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .HU)
#else
        .init()
#endif
    }

    /// The "ID" asset catalog image.
    static var ID: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ID)
#else
        .init()
#endif
    }

    /// The "IE" asset catalog image.
    static var IE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IE)
#else
        .init()
#endif
    }

    /// The "IL" asset catalog image.
    static var IL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IL)
#else
        .init()
#endif
    }

    /// The "IM" asset catalog image.
    static var IM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IM)
#else
        .init()
#endif
    }

    /// The "IN" asset catalog image.
    static var IN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IN)
#else
        .init()
#endif
    }

    /// The "IO" asset catalog image.
    static var IO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IO)
#else
        .init()
#endif
    }

    /// The "IQ" asset catalog image.
    static var IQ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IQ)
#else
        .init()
#endif
    }

    /// The "IR" asset catalog image.
    static var IR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IR)
#else
        .init()
#endif
    }

    /// The "IS" asset catalog image.
    static var IS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IS)
#else
        .init()
#endif
    }

    /// The "IT" asset catalog image.
    static var IT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .IT)
#else
        .init()
#endif
    }

    /// The "JE" asset catalog image.
    static var JE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .JE)
#else
        .init()
#endif
    }

    /// The "JM" asset catalog image.
    static var JM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .JM)
#else
        .init()
#endif
    }

    /// The "JO" asset catalog image.
    static var JO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .JO)
#else
        .init()
#endif
    }

    /// The "JP" asset catalog image.
    static var JP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .JP)
#else
        .init()
#endif
    }

    /// The "KE" asset catalog image.
    static var KE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KE)
#else
        .init()
#endif
    }

    /// The "KG" asset catalog image.
    static var KG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KG)
#else
        .init()
#endif
    }

    /// The "KH" asset catalog image.
    static var KH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KH)
#else
        .init()
#endif
    }

    /// The "KI" asset catalog image.
    static var KI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KI)
#else
        .init()
#endif
    }

    /// The "KM" asset catalog image.
    static var KM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KM)
#else
        .init()
#endif
    }

    /// The "KN" asset catalog image.
    static var KN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KN)
#else
        .init()
#endif
    }

    /// The "KP" asset catalog image.
    static var KP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KP)
#else
        .init()
#endif
    }

    /// The "KR" asset catalog image.
    static var KR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KR)
#else
        .init()
#endif
    }

    /// The "KW" asset catalog image.
    static var KW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KW)
#else
        .init()
#endif
    }

    /// The "KY" asset catalog image.
    static var KY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KY)
#else
        .init()
#endif
    }

    /// The "KZ" asset catalog image.
    static var KZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .KZ)
#else
        .init()
#endif
    }

    /// The "LA" asset catalog image.
    static var LA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LA)
#else
        .init()
#endif
    }

    /// The "LB" asset catalog image.
    static var LB: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LB)
#else
        .init()
#endif
    }

    /// The "LC" asset catalog image.
    static var LC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LC)
#else
        .init()
#endif
    }

    /// The "LI" asset catalog image.
    static var LI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LI)
#else
        .init()
#endif
    }

    /// The "LK" asset catalog image.
    static var LK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LK)
#else
        .init()
#endif
    }

    /// The "LR" asset catalog image.
    static var LR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LR)
#else
        .init()
#endif
    }

    /// The "LS" asset catalog image.
    static var LS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LS)
#else
        .init()
#endif
    }

    /// The "LT" asset catalog image.
    static var LT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LT)
#else
        .init()
#endif
    }

    /// The "LU" asset catalog image.
    static var LU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LU)
#else
        .init()
#endif
    }

    /// The "LV" asset catalog image.
    static var LV: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LV)
#else
        .init()
#endif
    }

    /// The "LY" asset catalog image.
    static var LY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .LY)
#else
        .init()
#endif
    }

    /// The "MA" asset catalog image.
    static var MA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MA)
#else
        .init()
#endif
    }

    /// The "MC" asset catalog image.
    static var MC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MC)
#else
        .init()
#endif
    }

    /// The "MD" asset catalog image.
    static var MD: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MD)
#else
        .init()
#endif
    }

    /// The "ME" asset catalog image.
    static var ME: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ME)
#else
        .init()
#endif
    }

    /// The "MF" asset catalog image.
    static var MF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MF)
#else
        .init()
#endif
    }

    /// The "MG" asset catalog image.
    static var MG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MG)
#else
        .init()
#endif
    }

    /// The "MH" asset catalog image.
    static var MH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MH)
#else
        .init()
#endif
    }

    /// The "MK" asset catalog image.
    static var MK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MK)
#else
        .init()
#endif
    }

    /// The "ML" asset catalog image.
    static var ML: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ML)
#else
        .init()
#endif
    }

    /// The "MM" asset catalog image.
    static var MM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MM)
#else
        .init()
#endif
    }

    /// The "MN" asset catalog image.
    static var MN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MN)
#else
        .init()
#endif
    }

    /// The "MO" asset catalog image.
    static var MO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MO)
#else
        .init()
#endif
    }

    /// The "MP" asset catalog image.
    static var MP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MP)
#else
        .init()
#endif
    }

    /// The "MQ" asset catalog image.
    static var MQ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MQ)
#else
        .init()
#endif
    }

    /// The "MR" asset catalog image.
    static var MR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MR)
#else
        .init()
#endif
    }

    /// The "MS" asset catalog image.
    static var MS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MS)
#else
        .init()
#endif
    }

    /// The "MT" asset catalog image.
    static var MT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MT)
#else
        .init()
#endif
    }

    /// The "MU" asset catalog image.
    static var MU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MU)
#else
        .init()
#endif
    }

    /// The "MV" asset catalog image.
    static var MV: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MV)
#else
        .init()
#endif
    }

    /// The "MW" asset catalog image.
    static var MW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MW)
#else
        .init()
#endif
    }

    /// The "MX" asset catalog image.
    static var MX: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MX)
#else
        .init()
#endif
    }

    /// The "MY" asset catalog image.
    static var MY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MY)
#else
        .init()
#endif
    }

    /// The "MZ" asset catalog image.
    static var MZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .MZ)
#else
        .init()
#endif
    }

    /// The "NA" asset catalog image.
    static var NA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NA)
#else
        .init()
#endif
    }

    /// The "NC" asset catalog image.
    static var NC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NC)
#else
        .init()
#endif
    }

    /// The "NE" asset catalog image.
    static var NE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NE)
#else
        .init()
#endif
    }

    /// The "NF" asset catalog image.
    static var NF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NF)
#else
        .init()
#endif
    }

    /// The "NG" asset catalog image.
    static var NG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NG)
#else
        .init()
#endif
    }

    /// The "NI" asset catalog image.
    static var NI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NI)
#else
        .init()
#endif
    }

    /// The "NL" asset catalog image.
    static var NL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NL)
#else
        .init()
#endif
    }

    /// The "NO" asset catalog image.
    static var NO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NO)
#else
        .init()
#endif
    }

    /// The "NP" asset catalog image.
    static var NP: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NP)
#else
        .init()
#endif
    }

    /// The "NR" asset catalog image.
    static var NR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NR)
#else
        .init()
#endif
    }

    /// The "NU" asset catalog image.
    static var NU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NU)
#else
        .init()
#endif
    }

    /// The "NZ" asset catalog image.
    static var NZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .NZ)
#else
        .init()
#endif
    }

    /// The "OM" asset catalog image.
    static var OM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .OM)
#else
        .init()
#endif
    }

    /// The "PA" asset catalog image.
    static var PA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PA)
#else
        .init()
#endif
    }

    /// The "PE" asset catalog image.
    static var PE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PE)
#else
        .init()
#endif
    }

    /// The "PF" asset catalog image.
    static var PF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PF)
#else
        .init()
#endif
    }

    /// The "PG" asset catalog image.
    static var PG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PG)
#else
        .init()
#endif
    }

    /// The "PH" asset catalog image.
    static var PH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PH)
#else
        .init()
#endif
    }

    /// The "PK" asset catalog image.
    static var PK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PK)
#else
        .init()
#endif
    }

    /// The "PL" asset catalog image.
    static var PL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PL)
#else
        .init()
#endif
    }

    /// The "PM" asset catalog image.
    static var PM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PM)
#else
        .init()
#endif
    }

    /// The "PN" asset catalog image.
    static var PN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PN)
#else
        .init()
#endif
    }

    /// The "PR" asset catalog image.
    static var PR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PR)
#else
        .init()
#endif
    }

    /// The "PS" asset catalog image.
    static var PS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PS)
#else
        .init()
#endif
    }

    /// The "PT" asset catalog image.
    static var PT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PT)
#else
        .init()
#endif
    }

    /// The "PW" asset catalog image.
    static var PW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PW)
#else
        .init()
#endif
    }

    /// The "PY" asset catalog image.
    static var PY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .PY)
#else
        .init()
#endif
    }

    /// The "Planet" asset catalog image.
    static var planet: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planet)
#else
        .init()
#endif
    }

    /// The "Planet2" asset catalog image.
    static var planet2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planet2)
#else
        .init()
#endif
    }

    /// The "PlanetRightPS" asset catalog image.
    static var planetRightPS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planetRightPS)
#else
        .init()
#endif
    }

    /// The "Polygon 4" asset catalog image.
    static var polygon4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polygon4)
#else
        .init()
#endif
    }

    /// The "QA" asset catalog image.
    static var QA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .QA)
#else
        .init()
#endif
    }

    /// The "RE" asset catalog image.
    static var RE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .RE)
#else
        .init()
#endif
    }

    /// The "RO" asset catalog image.
    static var RO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .RO)
#else
        .init()
#endif
    }

    /// The "RS" asset catalog image.
    static var RS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .RS)
#else
        .init()
#endif
    }

    /// The "RU" asset catalog image.
    static var RU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .RU)
#else
        .init()
#endif
    }

    /// The "RW" asset catalog image.
    static var RW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .RW)
#else
        .init()
#endif
    }

    /// The "SA" asset catalog image.
    static var SA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SA)
#else
        .init()
#endif
    }

    /// The "SB" asset catalog image.
    static var SB: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SB)
#else
        .init()
#endif
    }

    /// The "SC" asset catalog image.
    static var SC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SC)
#else
        .init()
#endif
    }

    /// The "SD" asset catalog image.
    static var SD: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SD)
#else
        .init()
#endif
    }

    /// The "SE" asset catalog image.
    static var SE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SE)
#else
        .init()
#endif
    }

    /// The "SG" asset catalog image.
    static var SG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SG)
#else
        .init()
#endif
    }

    /// The "SH" asset catalog image.
    static var SH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SH)
#else
        .init()
#endif
    }

    /// The "SI" asset catalog image.
    static var SI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SI)
#else
        .init()
#endif
    }

    /// The "SJ" asset catalog image.
    static var SJ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SJ)
#else
        .init()
#endif
    }

    /// The "SK" asset catalog image.
    static var SK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SK)
#else
        .init()
#endif
    }

    /// The "SL" asset catalog image.
    static var SL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SL)
#else
        .init()
#endif
    }

    /// The "SM" asset catalog image.
    static var SM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SM)
#else
        .init()
#endif
    }

    /// The "SN" asset catalog image.
    static var SN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SN)
#else
        .init()
#endif
    }

    /// The "SO" asset catalog image.
    static var SO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SO)
#else
        .init()
#endif
    }

    /// The "SR" asset catalog image.
    static var SR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SR)
#else
        .init()
#endif
    }

    /// The "SS" asset catalog image.
    static var SS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SS)
#else
        .init()
#endif
    }

    /// The "ST" asset catalog image.
    static var ST: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ST)
#else
        .init()
#endif
    }

    /// The "SV" asset catalog image.
    static var SV: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SV)
#else
        .init()
#endif
    }

    /// The "SX" asset catalog image.
    static var SX: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SX)
#else
        .init()
#endif
    }

    /// The "SY" asset catalog image.
    static var SY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SY)
#else
        .init()
#endif
    }

    /// The "SZ" asset catalog image.
    static var SZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .SZ)
#else
        .init()
#endif
    }

    /// The "SpeechVoice" asset catalog image.
    static var speechVoice: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speechVoice)
#else
        .init()
#endif
    }

    /// The "TC" asset catalog image.
    static var TC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TC)
#else
        .init()
#endif
    }

    /// The "TD" asset catalog image.
    static var TD: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TD)
#else
        .init()
#endif
    }

    /// The "TF" asset catalog image.
    static var TF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TF)
#else
        .init()
#endif
    }

    /// The "TG" asset catalog image.
    static var TG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TG)
#else
        .init()
#endif
    }

    /// The "TH" asset catalog image.
    static var TH: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TH)
#else
        .init()
#endif
    }

    /// The "TJ" asset catalog image.
    static var TJ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TJ)
#else
        .init()
#endif
    }

    /// The "TK" asset catalog image.
    static var TK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TK)
#else
        .init()
#endif
    }

    /// The "TL" asset catalog image.
    static var TL: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TL)
#else
        .init()
#endif
    }

    /// The "TM" asset catalog image.
    static var TM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TM)
#else
        .init()
#endif
    }

    /// The "TN" asset catalog image.
    static var TN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TN)
#else
        .init()
#endif
    }

    /// The "TO" asset catalog image.
    static var TO: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TO)
#else
        .init()
#endif
    }

    /// The "TR" asset catalog image.
    static var TR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TR)
#else
        .init()
#endif
    }

    /// The "TT" asset catalog image.
    static var TT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TT)
#else
        .init()
#endif
    }

    /// The "TV" asset catalog image.
    static var TV: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TV)
#else
        .init()
#endif
    }

    /// The "TW" asset catalog image.
    static var TW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TW)
#else
        .init()
#endif
    }

    /// The "TZ" asset catalog image.
    static var TZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .TZ)
#else
        .init()
#endif
    }

    /// The "UA" asset catalog image.
    static var UA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .UA)
#else
        .init()
#endif
    }

    /// The "UG" asset catalog image.
    static var UG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .UG)
#else
        .init()
#endif
    }

    /// The "UM" asset catalog image.
    static var UM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .UM)
#else
        .init()
#endif
    }

    /// The "US" asset catalog image.
    static var US: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .US)
#else
        .init()
#endif
    }

    /// The "UY" asset catalog image.
    static var UY: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .UY)
#else
        .init()
#endif
    }

    /// The "UZ" asset catalog image.
    static var UZ: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .UZ)
#else
        .init()
#endif
    }

    /// The "VA" asset catalog image.
    static var VA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VA)
#else
        .init()
#endif
    }

    /// The "VC" asset catalog image.
    static var VC: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VC)
#else
        .init()
#endif
    }

    /// The "VE" asset catalog image.
    static var VE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VE)
#else
        .init()
#endif
    }

    /// The "VG" asset catalog image.
    static var VG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VG)
#else
        .init()
#endif
    }

    /// The "VI" asset catalog image.
    static var VI: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VI)
#else
        .init()
#endif
    }

    /// The "VN" asset catalog image.
    static var VN: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VN)
#else
        .init()
#endif
    }

    /// The "VU" asset catalog image.
    static var VU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .VU)
#else
        .init()
#endif
    }

    /// The "WF" asset catalog image.
    static var WF: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .WF)
#else
        .init()
#endif
    }

    /// The "WS" asset catalog image.
    static var WS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .WS)
#else
        .init()
#endif
    }

    /// The "XK" asset catalog image.
    static var XK: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .XK)
#else
        .init()
#endif
    }

    /// The "YE" asset catalog image.
    static var YE: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .YE)
#else
        .init()
#endif
    }

    /// The "YT" asset catalog image.
    static var YT: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .YT)
#else
        .init()
#endif
    }

    /// The "YU" asset catalog image.
    static var YU: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .YU)
#else
        .init()
#endif
    }

    /// The "ZA" asset catalog image.
    static var ZA: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ZA)
#else
        .init()
#endif
    }

    /// The "ZM" asset catalog image.
    static var ZM: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ZM)
#else
        .init()
#endif
    }

    /// The "ZW" asset catalog image.
    static var ZW: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ZW)
#else
        .init()
#endif
    }

    /// The "ad-Lock" asset catalog image.
    static var adLock: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .adLock)
#else
        .init()
#endif
    }

    /// The "asyncArrew" asset catalog image.
    static var asyncArrew: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .asyncArrew)
#else
        .init()
#endif
    }

    /// The "backArrow" asset catalog image.
    static var backArrow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .backArrow)
#else
        .init()
#endif
    }

    /// The "blue microfon icon" asset catalog image.
    static var blueMicrofonIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .blueMicrofonIcon)
#else
        .init()
#endif
    }

    /// The "closePS" asset catalog image.
    static var closePS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .closePS)
#else
        .init()
#endif
    }

    /// The "emojione-v1_left-check-mark" asset catalog image.
    static var emojioneV1LeftCheckMark: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .emojioneV1LeftCheckMark)
#else
        .init()
#endif
    }

    /// The "fi-sr-camera" asset catalog image.
    static var fiSrCamera: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrCamera)
#else
        .init()
#endif
    }

    /// The "fi-sr-comment-alt" asset catalog image.
    static var fiSrCommentAlt: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrCommentAlt)
#else
        .init()
#endif
    }

    /// The "fi-sr-copy" asset catalog image.
    static var fiSrCopy: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrCopy)
#else
        .init()
#endif
    }

    /// The "fi-sr-picture" asset catalog image.
    static var fiSrPicture: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrPicture)
#else
        .init()
#endif
    }

    /// The "fi-sr-share" asset catalog image.
    static var fiSrShare: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrShare)
#else
        .init()
#endif
    }

    /// The "fi-sr-star" asset catalog image.
    static var fiSrStar: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrStar)
#else
        .init()
#endif
    }

    /// The "fi-sr-text" asset catalog image.
    static var fiSrText: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrText)
#else
        .init()
#endif
    }

    /// The "fi-sr-time-quarter-to" asset catalog image.
    static var fiSrTimeQuarterTo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrTimeQuarterTo)
#else
        .init()
#endif
    }

    /// The "fi-sr-trash" asset catalog image.
    static var fiSrTrash: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrTrash)
#else
        .init()
#endif
    }

    /// The "fi-sr-unlock" asset catalog image.
    static var fiSrUnlock: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrUnlock)
#else
        .init()
#endif
    }

    /// The "fi-sr-volume" asset catalog image.
    static var fiSrVolume: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fiSrVolume)
#else
        .init()
#endif
    }

    /// The "france" asset catalog image.
    static var france: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .france)
#else
        .init()
#endif
    }

    /// The "germany" asset catalog image.
    static var germany: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .germany)
#else
        .init()
#endif
    }

    /// The "greece" asset catalog image.
    static var greece: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .greece)
#else
        .init()
#endif
    }

    /// The "groupBG" asset catalog image.
    static var groupBG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .groupBG)
#else
        .init()
#endif
    }

    /// The "indonesia" asset catalog image.
    static var indonesia: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .indonesia)
#else
        .init()
#endif
    }

    /// The "japan" asset catalog image.
    static var japan: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .japan)
#else
        .init()
#endif
    }

    /// The "menuBg" asset catalog image.
    static var menuBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .menuBg)
#else
        .init()
#endif
    }

    /// The "orbita" asset catalog image.
    static var orbita: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .orbita)
#else
        .init()
#endif
    }

    /// The "planetLeft" asset catalog image.
    static var planetLeft: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planetLeft)
#else
        .init()
#endif
    }

    /// The "planetLeftPS" asset catalog image.
    static var planetLeftPS: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planetLeftPS)
#else
        .init()
#endif
    }

    /// The "planetRight" asset catalog image.
    static var planetRight: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .planetRight)
#else
        .init()
#endif
    }

    /// The "reclama" asset catalog image.
    static var reclama: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .reclama)
#else
        .init()
#endif
    }

    /// The "russia" asset catalog image.
    static var russia: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .russia)
#else
        .init()
#endif
    }

    /// The "spain" asset catalog image.
    static var spain: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .spain)
#else
        .init()
#endif
    }

    /// The "starBg" asset catalog image.
    static var starBg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .starBg)
#else
        .init()
#endif
    }

    /// The "trush" asset catalog image.
    static var trush: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .trush)
#else
        .init()
#endif
    }

    /// The "ukraine" asset catalog image.
    static var ukraine: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ukraine)
#else
        .init()
#endif
    }

    /// The "united-kingdom" asset catalog image.
    static var unitedKingdom: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .unitedKingdom)
#else
        .init()
#endif
    }

    /// The "united-states-of-america" asset catalog image.
    static var unitedStatesOfAmerica: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .unitedStatesOfAmerica)
#else
        .init()
#endif
    }

    /// The "voice" asset catalog image.
    static var voice: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .voice)
#else
        .init()
#endif
    }

    /// The "windowIcon" asset catalog image.
    static var windowIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .windowIcon)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "AC" asset catalog image.
    static var AC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AC)
#else
        .init()
#endif
    }

    /// The "AD" asset catalog image.
    static var AD: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AD)
#else
        .init()
#endif
    }

    /// The "AE" asset catalog image.
    static var AE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AE)
#else
        .init()
#endif
    }

    /// The "AF" asset catalog image.
    static var AF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AF)
#else
        .init()
#endif
    }

    /// The "AG" asset catalog image.
    static var AG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AG)
#else
        .init()
#endif
    }

    /// The "AI" asset catalog image.
    static var AI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AI)
#else
        .init()
#endif
    }

    /// The "AL" asset catalog image.
    static var AL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AL)
#else
        .init()
#endif
    }

    /// The "AM" asset catalog image.
    static var AM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AM)
#else
        .init()
#endif
    }

    /// The "AO" asset catalog image.
    static var AO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AO)
#else
        .init()
#endif
    }

    /// The "AQ" asset catalog image.
    static var AQ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AQ)
#else
        .init()
#endif
    }

    /// The "AR" asset catalog image.
    static var AR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AR)
#else
        .init()
#endif
    }

    /// The "AS" asset catalog image.
    static var AS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AS)
#else
        .init()
#endif
    }

    /// The "AT" asset catalog image.
    static var AT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AT)
#else
        .init()
#endif
    }

    /// The "AU" asset catalog image.
    static var AU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AU)
#else
        .init()
#endif
    }

    /// The "AW" asset catalog image.
    static var AW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AW)
#else
        .init()
#endif
    }

    /// The "AX" asset catalog image.
    static var AX: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AX)
#else
        .init()
#endif
    }

    /// The "AZ" asset catalog image.
    static var AZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .AZ)
#else
        .init()
#endif
    }

    /// The "BA" asset catalog image.
    static var BA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BA)
#else
        .init()
#endif
    }

    /// The "BB" asset catalog image.
    static var BB: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BB)
#else
        .init()
#endif
    }

    /// The "BD" asset catalog image.
    static var BD: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BD)
#else
        .init()
#endif
    }

    /// The "BE" asset catalog image.
    static var BE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BE)
#else
        .init()
#endif
    }

    /// The "BF" asset catalog image.
    static var BF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BF)
#else
        .init()
#endif
    }

    /// The "BG" asset catalog image.
    static var BG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BG)
#else
        .init()
#endif
    }

    /// The "BH" asset catalog image.
    static var BH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BH)
#else
        .init()
#endif
    }

    /// The "BI" asset catalog image.
    static var BI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BI)
#else
        .init()
#endif
    }

    /// The "BJ" asset catalog image.
    static var BJ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BJ)
#else
        .init()
#endif
    }

    /// The "BL" asset catalog image.
    static var BL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BL)
#else
        .init()
#endif
    }

    /// The "BM" asset catalog image.
    static var BM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BM)
#else
        .init()
#endif
    }

    /// The "BN" asset catalog image.
    static var BN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BN)
#else
        .init()
#endif
    }

    /// The "BO" asset catalog image.
    static var BO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BO)
#else
        .init()
#endif
    }

    /// The "BQ" asset catalog image.
    static var BQ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BQ)
#else
        .init()
#endif
    }

    /// The "BR" asset catalog image.
    static var BR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BR)
#else
        .init()
#endif
    }

    /// The "BS" asset catalog image.
    static var BS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BS)
#else
        .init()
#endif
    }

    /// The "BT" asset catalog image.
    static var BT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BT)
#else
        .init()
#endif
    }

    /// The "BV" asset catalog image.
    static var BV: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BV)
#else
        .init()
#endif
    }

    /// The "BW" asset catalog image.
    static var BW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BW)
#else
        .init()
#endif
    }

    /// The "BY" asset catalog image.
    static var BY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BY)
#else
        .init()
#endif
    }

    /// The "BZ" asset catalog image.
    static var BZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .BZ)
#else
        .init()
#endif
    }

    /// The "CA" asset catalog image.
    static var CA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CA)
#else
        .init()
#endif
    }

    /// The "CC" asset catalog image.
    static var CC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CC)
#else
        .init()
#endif
    }

    /// The "CD" asset catalog image.
    static var CD: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CD)
#else
        .init()
#endif
    }

    /// The "CF" asset catalog image.
    static var CF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CF)
#else
        .init()
#endif
    }

    /// The "CG" asset catalog image.
    static var CG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CG)
#else
        .init()
#endif
    }

    /// The "CH" asset catalog image.
    static var CH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CH)
#else
        .init()
#endif
    }

    /// The "CI" asset catalog image.
    static var CI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CI)
#else
        .init()
#endif
    }

    /// The "CK" asset catalog image.
    static var CK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CK)
#else
        .init()
#endif
    }

    /// The "CL" asset catalog image.
    static var CL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CL)
#else
        .init()
#endif
    }

    /// The "CM" asset catalog image.
    static var CM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CM)
#else
        .init()
#endif
    }

    /// The "CN" asset catalog image.
    static var CN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CN)
#else
        .init()
#endif
    }

    /// The "CO" asset catalog image.
    static var CO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CO)
#else
        .init()
#endif
    }

    /// The "CR" asset catalog image.
    static var CR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CR)
#else
        .init()
#endif
    }

    /// The "CU" asset catalog image.
    static var CU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CU)
#else
        .init()
#endif
    }

    /// The "CV" asset catalog image.
    static var CV: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CV)
#else
        .init()
#endif
    }

    /// The "CW" asset catalog image.
    static var CW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CW)
#else
        .init()
#endif
    }

    /// The "CX" asset catalog image.
    static var CX: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CX)
#else
        .init()
#endif
    }

    /// The "CY" asset catalog image.
    static var CY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CY)
#else
        .init()
#endif
    }

    /// The "CZ" asset catalog image.
    static var CZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .CZ)
#else
        .init()
#endif
    }

    /// The "DE" asset catalog image.
    static var DE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .DE)
#else
        .init()
#endif
    }

    /// The "DJ" asset catalog image.
    static var DJ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .DJ)
#else
        .init()
#endif
    }

    /// The "DK" asset catalog image.
    static var DK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .DK)
#else
        .init()
#endif
    }

    /// The "DM" asset catalog image.
    static var DM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .DM)
#else
        .init()
#endif
    }

    /// The "DO" asset catalog image.
    static var DO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .DO)
#else
        .init()
#endif
    }

    /// The "DZ" asset catalog image.
    static var DZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .DZ)
#else
        .init()
#endif
    }

    /// The "EC" asset catalog image.
    static var EC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .EC)
#else
        .init()
#endif
    }

    /// The "EE" asset catalog image.
    static var EE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .EE)
#else
        .init()
#endif
    }

    /// The "EG" asset catalog image.
    static var EG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .EG)
#else
        .init()
#endif
    }

    /// The "EH" asset catalog image.
    static var EH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .EH)
#else
        .init()
#endif
    }

    /// The "ER" asset catalog image.
    static var ER: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ER)
#else
        .init()
#endif
    }

    /// The "ES" asset catalog image.
    static var ES: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ES)
#else
        .init()
#endif
    }

    /// The "ET" asset catalog image.
    static var ET: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ET)
#else
        .init()
#endif
    }

    /// The "FI" asset catalog image.
    static var FI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FI)
#else
        .init()
#endif
    }

    /// The "FJ" asset catalog image.
    static var FJ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FJ)
#else
        .init()
#endif
    }

    /// The "FK" asset catalog image.
    static var FK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FK)
#else
        .init()
#endif
    }

    /// The "FM" asset catalog image.
    static var FM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FM)
#else
        .init()
#endif
    }

    /// The "FO" asset catalog image.
    static var FO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FO)
#else
        .init()
#endif
    }

    /// The "FR" asset catalog image.
    static var FR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FR)
#else
        .init()
#endif
    }

    /// The "FX" asset catalog image.
    static var FX: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .FX)
#else
        .init()
#endif
    }

    /// The "GA" asset catalog image.
    static var GA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GA)
#else
        .init()
#endif
    }

    /// The "GB" asset catalog image.
    static var GB: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GB)
#else
        .init()
#endif
    }

    /// The "GD" asset catalog image.
    static var GD: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GD)
#else
        .init()
#endif
    }

    /// The "GE" asset catalog image.
    static var GE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GE)
#else
        .init()
#endif
    }

    /// The "GF" asset catalog image.
    static var GF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GF)
#else
        .init()
#endif
    }

    /// The "GG" asset catalog image.
    static var GG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GG)
#else
        .init()
#endif
    }

    /// The "GH" asset catalog image.
    static var GH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GH)
#else
        .init()
#endif
    }

    /// The "GI" asset catalog image.
    static var GI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GI)
#else
        .init()
#endif
    }

    /// The "GL" asset catalog image.
    static var GL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GL)
#else
        .init()
#endif
    }

    /// The "GM" asset catalog image.
    static var GM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GM)
#else
        .init()
#endif
    }

    /// The "GN" asset catalog image.
    static var GN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GN)
#else
        .init()
#endif
    }

    /// The "GP" asset catalog image.
    static var GP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GP)
#else
        .init()
#endif
    }

    /// The "GQ" asset catalog image.
    static var GQ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GQ)
#else
        .init()
#endif
    }

    /// The "GR" asset catalog image.
    static var GR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GR)
#else
        .init()
#endif
    }

    /// The "GS" asset catalog image.
    static var GS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GS)
#else
        .init()
#endif
    }

    /// The "GT" asset catalog image.
    static var GT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GT)
#else
        .init()
#endif
    }

    /// The "GU" asset catalog image.
    static var GU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GU)
#else
        .init()
#endif
    }

    /// The "GW" asset catalog image.
    static var GW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GW)
#else
        .init()
#endif
    }

    /// The "GY" asset catalog image.
    static var GY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .GY)
#else
        .init()
#endif
    }

    /// The "Group 305" asset catalog image.
    static var group305: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .group305)
#else
        .init()
#endif
    }

    /// The "Group 306" asset catalog image.
    static var group306: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .group306)
#else
        .init()
#endif
    }

    /// The "HK" asset catalog image.
    static var HK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .HK)
#else
        .init()
#endif
    }

    /// The "HM" asset catalog image.
    static var HM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .HM)
#else
        .init()
#endif
    }

    /// The "HN" asset catalog image.
    static var HN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .HN)
#else
        .init()
#endif
    }

    /// The "HR" asset catalog image.
    static var HR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .HR)
#else
        .init()
#endif
    }

    /// The "HT" asset catalog image.
    static var HT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .HT)
#else
        .init()
#endif
    }

    /// The "HU" asset catalog image.
    static var HU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .HU)
#else
        .init()
#endif
    }

    /// The "ID" asset catalog image.
    static var ID: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ID)
#else
        .init()
#endif
    }

    /// The "IE" asset catalog image.
    static var IE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IE)
#else
        .init()
#endif
    }

    /// The "IL" asset catalog image.
    static var IL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IL)
#else
        .init()
#endif
    }

    /// The "IM" asset catalog image.
    static var IM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IM)
#else
        .init()
#endif
    }

    /// The "IN" asset catalog image.
    static var IN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IN)
#else
        .init()
#endif
    }

    /// The "IO" asset catalog image.
    static var IO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IO)
#else
        .init()
#endif
    }

    /// The "IQ" asset catalog image.
    static var IQ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IQ)
#else
        .init()
#endif
    }

    /// The "IR" asset catalog image.
    static var IR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IR)
#else
        .init()
#endif
    }

    /// The "IS" asset catalog image.
    static var IS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IS)
#else
        .init()
#endif
    }

    /// The "IT" asset catalog image.
    static var IT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .IT)
#else
        .init()
#endif
    }

    /// The "JE" asset catalog image.
    static var JE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .JE)
#else
        .init()
#endif
    }

    /// The "JM" asset catalog image.
    static var JM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .JM)
#else
        .init()
#endif
    }

    /// The "JO" asset catalog image.
    static var JO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .JO)
#else
        .init()
#endif
    }

    /// The "JP" asset catalog image.
    static var JP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .JP)
#else
        .init()
#endif
    }

    /// The "KE" asset catalog image.
    static var KE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KE)
#else
        .init()
#endif
    }

    /// The "KG" asset catalog image.
    static var KG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KG)
#else
        .init()
#endif
    }

    /// The "KH" asset catalog image.
    static var KH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KH)
#else
        .init()
#endif
    }

    /// The "KI" asset catalog image.
    static var KI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KI)
#else
        .init()
#endif
    }

    /// The "KM" asset catalog image.
    static var KM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KM)
#else
        .init()
#endif
    }

    /// The "KN" asset catalog image.
    static var KN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KN)
#else
        .init()
#endif
    }

    /// The "KP" asset catalog image.
    static var KP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KP)
#else
        .init()
#endif
    }

    /// The "KR" asset catalog image.
    static var KR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KR)
#else
        .init()
#endif
    }

    /// The "KW" asset catalog image.
    static var KW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KW)
#else
        .init()
#endif
    }

    /// The "KY" asset catalog image.
    static var KY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KY)
#else
        .init()
#endif
    }

    /// The "KZ" asset catalog image.
    static var KZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .KZ)
#else
        .init()
#endif
    }

    /// The "LA" asset catalog image.
    static var LA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LA)
#else
        .init()
#endif
    }

    /// The "LB" asset catalog image.
    static var LB: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LB)
#else
        .init()
#endif
    }

    /// The "LC" asset catalog image.
    static var LC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LC)
#else
        .init()
#endif
    }

    /// The "LI" asset catalog image.
    static var LI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LI)
#else
        .init()
#endif
    }

    /// The "LK" asset catalog image.
    static var LK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LK)
#else
        .init()
#endif
    }

    /// The "LR" asset catalog image.
    static var LR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LR)
#else
        .init()
#endif
    }

    /// The "LS" asset catalog image.
    static var LS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LS)
#else
        .init()
#endif
    }

    /// The "LT" asset catalog image.
    static var LT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LT)
#else
        .init()
#endif
    }

    /// The "LU" asset catalog image.
    static var LU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LU)
#else
        .init()
#endif
    }

    /// The "LV" asset catalog image.
    static var LV: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LV)
#else
        .init()
#endif
    }

    /// The "LY" asset catalog image.
    static var LY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .LY)
#else
        .init()
#endif
    }

    /// The "MA" asset catalog image.
    static var MA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MA)
#else
        .init()
#endif
    }

    /// The "MC" asset catalog image.
    static var MC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MC)
#else
        .init()
#endif
    }

    /// The "MD" asset catalog image.
    static var MD: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MD)
#else
        .init()
#endif
    }

    /// The "ME" asset catalog image.
    static var ME: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ME)
#else
        .init()
#endif
    }

    /// The "MF" asset catalog image.
    static var MF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MF)
#else
        .init()
#endif
    }

    /// The "MG" asset catalog image.
    static var MG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MG)
#else
        .init()
#endif
    }

    /// The "MH" asset catalog image.
    static var MH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MH)
#else
        .init()
#endif
    }

    /// The "MK" asset catalog image.
    static var MK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MK)
#else
        .init()
#endif
    }

    /// The "ML" asset catalog image.
    static var ML: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ML)
#else
        .init()
#endif
    }

    /// The "MM" asset catalog image.
    static var MM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MM)
#else
        .init()
#endif
    }

    /// The "MN" asset catalog image.
    static var MN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MN)
#else
        .init()
#endif
    }

    /// The "MO" asset catalog image.
    static var MO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MO)
#else
        .init()
#endif
    }

    /// The "MP" asset catalog image.
    static var MP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MP)
#else
        .init()
#endif
    }

    /// The "MQ" asset catalog image.
    static var MQ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MQ)
#else
        .init()
#endif
    }

    /// The "MR" asset catalog image.
    static var MR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MR)
#else
        .init()
#endif
    }

    /// The "MS" asset catalog image.
    static var MS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MS)
#else
        .init()
#endif
    }

    /// The "MT" asset catalog image.
    static var MT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MT)
#else
        .init()
#endif
    }

    /// The "MU" asset catalog image.
    static var MU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MU)
#else
        .init()
#endif
    }

    /// The "MV" asset catalog image.
    static var MV: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MV)
#else
        .init()
#endif
    }

    /// The "MW" asset catalog image.
    static var MW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MW)
#else
        .init()
#endif
    }

    /// The "MX" asset catalog image.
    static var MX: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MX)
#else
        .init()
#endif
    }

    /// The "MY" asset catalog image.
    static var MY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MY)
#else
        .init()
#endif
    }

    /// The "MZ" asset catalog image.
    static var MZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .MZ)
#else
        .init()
#endif
    }

    /// The "NA" asset catalog image.
    static var NA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NA)
#else
        .init()
#endif
    }

    /// The "NC" asset catalog image.
    static var NC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NC)
#else
        .init()
#endif
    }

    /// The "NE" asset catalog image.
    static var NE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NE)
#else
        .init()
#endif
    }

    /// The "NF" asset catalog image.
    static var NF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NF)
#else
        .init()
#endif
    }

    /// The "NG" asset catalog image.
    static var NG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NG)
#else
        .init()
#endif
    }

    /// The "NI" asset catalog image.
    static var NI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NI)
#else
        .init()
#endif
    }

    /// The "NL" asset catalog image.
    static var NL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NL)
#else
        .init()
#endif
    }

    /// The "NO" asset catalog image.
    static var NO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NO)
#else
        .init()
#endif
    }

    /// The "NP" asset catalog image.
    static var NP: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NP)
#else
        .init()
#endif
    }

    /// The "NR" asset catalog image.
    static var NR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NR)
#else
        .init()
#endif
    }

    /// The "NU" asset catalog image.
    static var NU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NU)
#else
        .init()
#endif
    }

    /// The "NZ" asset catalog image.
    static var NZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .NZ)
#else
        .init()
#endif
    }

    /// The "OM" asset catalog image.
    static var OM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .OM)
#else
        .init()
#endif
    }

    /// The "PA" asset catalog image.
    static var PA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PA)
#else
        .init()
#endif
    }

    /// The "PE" asset catalog image.
    static var PE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PE)
#else
        .init()
#endif
    }

    /// The "PF" asset catalog image.
    static var PF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PF)
#else
        .init()
#endif
    }

    /// The "PG" asset catalog image.
    static var PG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PG)
#else
        .init()
#endif
    }

    /// The "PH" asset catalog image.
    static var PH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PH)
#else
        .init()
#endif
    }

    /// The "PK" asset catalog image.
    static var PK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PK)
#else
        .init()
#endif
    }

    /// The "PL" asset catalog image.
    static var PL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PL)
#else
        .init()
#endif
    }

    /// The "PM" asset catalog image.
    static var PM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PM)
#else
        .init()
#endif
    }

    /// The "PN" asset catalog image.
    static var PN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PN)
#else
        .init()
#endif
    }

    /// The "PR" asset catalog image.
    static var PR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PR)
#else
        .init()
#endif
    }

    /// The "PS" asset catalog image.
    static var PS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PS)
#else
        .init()
#endif
    }

    /// The "PT" asset catalog image.
    static var PT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PT)
#else
        .init()
#endif
    }

    /// The "PW" asset catalog image.
    static var PW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PW)
#else
        .init()
#endif
    }

    /// The "PY" asset catalog image.
    static var PY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .PY)
#else
        .init()
#endif
    }

    /// The "Planet" asset catalog image.
    static var planet: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planet)
#else
        .init()
#endif
    }

    /// The "Planet2" asset catalog image.
    static var planet2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planet2)
#else
        .init()
#endif
    }

    /// The "PlanetRightPS" asset catalog image.
    static var planetRightPS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planetRightPS)
#else
        .init()
#endif
    }

    /// The "Polygon 4" asset catalog image.
    static var polygon4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polygon4)
#else
        .init()
#endif
    }

    /// The "QA" asset catalog image.
    static var QA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .QA)
#else
        .init()
#endif
    }

    /// The "RE" asset catalog image.
    static var RE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .RE)
#else
        .init()
#endif
    }

    /// The "RO" asset catalog image.
    static var RO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .RO)
#else
        .init()
#endif
    }

    /// The "RS" asset catalog image.
    static var RS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .RS)
#else
        .init()
#endif
    }

    /// The "RU" asset catalog image.
    static var RU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .RU)
#else
        .init()
#endif
    }

    /// The "RW" asset catalog image.
    static var RW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .RW)
#else
        .init()
#endif
    }

    /// The "SA" asset catalog image.
    static var SA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SA)
#else
        .init()
#endif
    }

    /// The "SB" asset catalog image.
    static var SB: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SB)
#else
        .init()
#endif
    }

    /// The "SC" asset catalog image.
    static var SC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SC)
#else
        .init()
#endif
    }

    /// The "SD" asset catalog image.
    static var SD: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SD)
#else
        .init()
#endif
    }

    /// The "SE" asset catalog image.
    static var SE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SE)
#else
        .init()
#endif
    }

    /// The "SG" asset catalog image.
    static var SG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SG)
#else
        .init()
#endif
    }

    /// The "SH" asset catalog image.
    static var SH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SH)
#else
        .init()
#endif
    }

    /// The "SI" asset catalog image.
    static var SI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SI)
#else
        .init()
#endif
    }

    /// The "SJ" asset catalog image.
    static var SJ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SJ)
#else
        .init()
#endif
    }

    /// The "SK" asset catalog image.
    static var SK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SK)
#else
        .init()
#endif
    }

    /// The "SL" asset catalog image.
    static var SL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SL)
#else
        .init()
#endif
    }

    /// The "SM" asset catalog image.
    static var SM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SM)
#else
        .init()
#endif
    }

    /// The "SN" asset catalog image.
    static var SN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SN)
#else
        .init()
#endif
    }

    /// The "SO" asset catalog image.
    static var SO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SO)
#else
        .init()
#endif
    }

    /// The "SR" asset catalog image.
    static var SR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SR)
#else
        .init()
#endif
    }

    /// The "SS" asset catalog image.
    static var SS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SS)
#else
        .init()
#endif
    }

    /// The "ST" asset catalog image.
    static var ST: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ST)
#else
        .init()
#endif
    }

    /// The "SV" asset catalog image.
    static var SV: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SV)
#else
        .init()
#endif
    }

    /// The "SX" asset catalog image.
    static var SX: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SX)
#else
        .init()
#endif
    }

    /// The "SY" asset catalog image.
    static var SY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SY)
#else
        .init()
#endif
    }

    /// The "SZ" asset catalog image.
    static var SZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .SZ)
#else
        .init()
#endif
    }

    /// The "SpeechVoice" asset catalog image.
    static var speechVoice: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speechVoice)
#else
        .init()
#endif
    }

    /// The "TC" asset catalog image.
    static var TC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TC)
#else
        .init()
#endif
    }

    /// The "TD" asset catalog image.
    static var TD: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TD)
#else
        .init()
#endif
    }

    /// The "TF" asset catalog image.
    static var TF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TF)
#else
        .init()
#endif
    }

    /// The "TG" asset catalog image.
    static var TG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TG)
#else
        .init()
#endif
    }

    /// The "TH" asset catalog image.
    static var TH: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TH)
#else
        .init()
#endif
    }

    /// The "TJ" asset catalog image.
    static var TJ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TJ)
#else
        .init()
#endif
    }

    /// The "TK" asset catalog image.
    static var TK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TK)
#else
        .init()
#endif
    }

    /// The "TL" asset catalog image.
    static var TL: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TL)
#else
        .init()
#endif
    }

    /// The "TM" asset catalog image.
    static var TM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TM)
#else
        .init()
#endif
    }

    /// The "TN" asset catalog image.
    static var TN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TN)
#else
        .init()
#endif
    }

    /// The "TO" asset catalog image.
    static var TO: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TO)
#else
        .init()
#endif
    }

    /// The "TR" asset catalog image.
    static var TR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TR)
#else
        .init()
#endif
    }

    /// The "TT" asset catalog image.
    static var TT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TT)
#else
        .init()
#endif
    }

    /// The "TV" asset catalog image.
    static var TV: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TV)
#else
        .init()
#endif
    }

    /// The "TW" asset catalog image.
    static var TW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TW)
#else
        .init()
#endif
    }

    /// The "TZ" asset catalog image.
    static var TZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .TZ)
#else
        .init()
#endif
    }

    /// The "UA" asset catalog image.
    static var UA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .UA)
#else
        .init()
#endif
    }

    /// The "UG" asset catalog image.
    static var UG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .UG)
#else
        .init()
#endif
    }

    /// The "UM" asset catalog image.
    static var UM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .UM)
#else
        .init()
#endif
    }

    /// The "US" asset catalog image.
    static var US: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .US)
#else
        .init()
#endif
    }

    /// The "UY" asset catalog image.
    static var UY: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .UY)
#else
        .init()
#endif
    }

    /// The "UZ" asset catalog image.
    static var UZ: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .UZ)
#else
        .init()
#endif
    }

    /// The "VA" asset catalog image.
    static var VA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VA)
#else
        .init()
#endif
    }

    /// The "VC" asset catalog image.
    static var VC: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VC)
#else
        .init()
#endif
    }

    /// The "VE" asset catalog image.
    static var VE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VE)
#else
        .init()
#endif
    }

    /// The "VG" asset catalog image.
    static var VG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VG)
#else
        .init()
#endif
    }

    /// The "VI" asset catalog image.
    static var VI: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VI)
#else
        .init()
#endif
    }

    /// The "VN" asset catalog image.
    static var VN: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VN)
#else
        .init()
#endif
    }

    /// The "VU" asset catalog image.
    static var VU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .VU)
#else
        .init()
#endif
    }

    /// The "WF" asset catalog image.
    static var WF: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .WF)
#else
        .init()
#endif
    }

    /// The "WS" asset catalog image.
    static var WS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .WS)
#else
        .init()
#endif
    }

    /// The "XK" asset catalog image.
    static var XK: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .XK)
#else
        .init()
#endif
    }

    /// The "YE" asset catalog image.
    static var YE: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .YE)
#else
        .init()
#endif
    }

    /// The "YT" asset catalog image.
    static var YT: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .YT)
#else
        .init()
#endif
    }

    /// The "YU" asset catalog image.
    static var YU: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .YU)
#else
        .init()
#endif
    }

    /// The "ZA" asset catalog image.
    static var ZA: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ZA)
#else
        .init()
#endif
    }

    /// The "ZM" asset catalog image.
    static var ZM: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ZM)
#else
        .init()
#endif
    }

    /// The "ZW" asset catalog image.
    static var ZW: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ZW)
#else
        .init()
#endif
    }

    /// The "ad-Lock" asset catalog image.
    static var adLock: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .adLock)
#else
        .init()
#endif
    }

    /// The "asyncArrew" asset catalog image.
    static var asyncArrew: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .asyncArrew)
#else
        .init()
#endif
    }

    /// The "backArrow" asset catalog image.
    static var backArrow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .backArrow)
#else
        .init()
#endif
    }

    /// The "blue microfon icon" asset catalog image.
    static var blueMicrofonIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .blueMicrofonIcon)
#else
        .init()
#endif
    }

    /// The "closePS" asset catalog image.
    static var closePS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .closePS)
#else
        .init()
#endif
    }

    /// The "emojione-v1_left-check-mark" asset catalog image.
    static var emojioneV1LeftCheckMark: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .emojioneV1LeftCheckMark)
#else
        .init()
#endif
    }

    /// The "fi-sr-camera" asset catalog image.
    static var fiSrCamera: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrCamera)
#else
        .init()
#endif
    }

    /// The "fi-sr-comment-alt" asset catalog image.
    static var fiSrCommentAlt: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrCommentAlt)
#else
        .init()
#endif
    }

    /// The "fi-sr-copy" asset catalog image.
    static var fiSrCopy: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrCopy)
#else
        .init()
#endif
    }

    /// The "fi-sr-picture" asset catalog image.
    static var fiSrPicture: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrPicture)
#else
        .init()
#endif
    }

    /// The "fi-sr-share" asset catalog image.
    static var fiSrShare: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrShare)
#else
        .init()
#endif
    }

    /// The "fi-sr-star" asset catalog image.
    static var fiSrStar: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrStar)
#else
        .init()
#endif
    }

    /// The "fi-sr-text" asset catalog image.
    static var fiSrText: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrText)
#else
        .init()
#endif
    }

    /// The "fi-sr-time-quarter-to" asset catalog image.
    static var fiSrTimeQuarterTo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrTimeQuarterTo)
#else
        .init()
#endif
    }

    /// The "fi-sr-trash" asset catalog image.
    static var fiSrTrash: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrTrash)
#else
        .init()
#endif
    }

    /// The "fi-sr-unlock" asset catalog image.
    static var fiSrUnlock: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrUnlock)
#else
        .init()
#endif
    }

    /// The "fi-sr-volume" asset catalog image.
    static var fiSrVolume: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fiSrVolume)
#else
        .init()
#endif
    }

    /// The "france" asset catalog image.
    static var france: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .france)
#else
        .init()
#endif
    }

    /// The "germany" asset catalog image.
    static var germany: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .germany)
#else
        .init()
#endif
    }

    /// The "greece" asset catalog image.
    static var greece: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .greece)
#else
        .init()
#endif
    }

    /// The "groupBG" asset catalog image.
    static var groupBG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .groupBG)
#else
        .init()
#endif
    }

    /// The "indonesia" asset catalog image.
    static var indonesia: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .indonesia)
#else
        .init()
#endif
    }

    /// The "japan" asset catalog image.
    static var japan: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .japan)
#else
        .init()
#endif
    }

    /// The "menuBg" asset catalog image.
    static var menuBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .menuBg)
#else
        .init()
#endif
    }

    /// The "orbita" asset catalog image.
    static var orbita: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .orbita)
#else
        .init()
#endif
    }

    /// The "planetLeft" asset catalog image.
    static var planetLeft: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planetLeft)
#else
        .init()
#endif
    }

    /// The "planetLeftPS" asset catalog image.
    static var planetLeftPS: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planetLeftPS)
#else
        .init()
#endif
    }

    /// The "planetRight" asset catalog image.
    static var planetRight: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .planetRight)
#else
        .init()
#endif
    }

    /// The "reclama" asset catalog image.
    static var reclama: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .reclama)
#else
        .init()
#endif
    }

    /// The "russia" asset catalog image.
    static var russia: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .russia)
#else
        .init()
#endif
    }

    /// The "spain" asset catalog image.
    static var spain: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .spain)
#else
        .init()
#endif
    }

    /// The "starBg" asset catalog image.
    static var starBg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .starBg)
#else
        .init()
#endif
    }

    /// The "trush" asset catalog image.
    static var trush: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .trush)
#else
        .init()
#endif
    }

    /// The "ukraine" asset catalog image.
    static var ukraine: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ukraine)
#else
        .init()
#endif
    }

    /// The "united-kingdom" asset catalog image.
    static var unitedKingdom: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .unitedKingdom)
#else
        .init()
#endif
    }

    /// The "united-states-of-america" asset catalog image.
    static var unitedStatesOfAmerica: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .unitedStatesOfAmerica)
#else
        .init()
#endif
    }

    /// The "voice" asset catalog image.
    static var voice: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .voice)
#else
        .init()
#endif
    }

    /// The "windowIcon" asset catalog image.
    static var windowIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .windowIcon)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

