//  © Copyright ACI Worldwide, Inc. 2018, 2025

#import <UIKit/UIKit.h>
@import SafariServices;
@class OPPCheckoutProvider;
@class OPPCustomPresentationControllerDelegate;
@class OPPPaymentFormHeaderView;
@class OPPStorePaymentDetailsView;

/// :nodoc:
@interface OPPRootViewController : UIViewController <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>
- (nullable instancetype)initWithCheckoutProvider:(nonnull OPPCheckoutProvider<SFSafariViewControllerDelegate> *)checkoutProvider;
@property (nonatomic, readonly, weak) OPPCheckoutProvider<SFSafariViewControllerDelegate> * _Nullable checkoutProvider;
@property (nonatomic, readwrite, weak) OPPCustomPresentationControllerDelegate * _Nullable presentationControllerDelegate;

/// :nodoc:
- (void)configureUI;
/// :nodoc:
- (void)cancelButtonAction;
/// :nodoc:
- (void)adaptScrollView:(nonnull UIScrollView *)scrollView keyboardRect:(CGRect)keyboardRect visibleRect:(CGRect)visibleRect;
/// :nodoc:
- (void)configurePaymentFormHeaderView:(nonnull OPPPaymentFormHeaderView *)formHeaderView;
/// :nodoc:
- (void)focusOnTextField:(nonnull UITextField *)textField;
/// :nodoc:
- (void)configurePaymentButton:(nonnull UIButton *)paymentButton;
/// :nodoc:
- (void)popToRootOrDismissViewController;
/// :nodoc:
- (void)didEnterBackground:(NSNotification *_Nonnull)notification;
/// :nodoc:
- (void)didBecomeActive:(NSNotification *_Nonnull)notification;
/// :nodoc:
- (BOOL)autoSpacingTextField:(nonnull UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
           replacementString:(nonnull NSString *)string
                     pattern:(nonnull NSString *)pattern;
/// :nodoc:
- (BOOL)expiryDateTextField:(nonnull UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
          replacementString:(nonnull NSString *)string;
- (void)configureStorePaymentDetailsView:(OPPStorePaymentDetailsView *_Nonnull)storePaymentDetailsView;
/// :nodoc:
- (CGFloat)preferredPresentationHeight;
@end
