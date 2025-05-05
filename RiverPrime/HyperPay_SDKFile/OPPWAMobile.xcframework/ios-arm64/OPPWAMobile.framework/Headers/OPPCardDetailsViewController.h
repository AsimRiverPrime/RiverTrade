//  © Copyright ACI Worldwide, Inc. 2018, 2025

@import UIKit;
#import "OPPRootViewController.h"
@class OPPToken;

NS_ASSUME_NONNULL_BEGIN
extern NSString *const OPPCardDetailsViewControllerPlusSign;
extern NSString *const OPPCardDetailsViewControllerExpiryDateSeparator;

@interface OPPCardDetailsViewController : OPPRootViewController
//designated initializer
- (nullable instancetype)initWithCheckoutProvider:(OPPCheckoutProvider *)checkoutProvider paymentBrand:(NSString *)paymentBrand;
- (nullable instancetype)initWithCheckoutProvider:(OPPCheckoutProvider *)checkoutProvider token:(OPPToken *)token;
- (instancetype)init NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
