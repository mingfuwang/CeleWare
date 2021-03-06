

#import <UIKit/UIKit.h>


//
@interface UIImage (ImageEx)
+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)stretchableImage;
- (UIImage *)scaleImageToSize:(CGSize)size;
- (UIImage *)cropImageInRect:(CGRect)rect;
//- (UIImage *)cropImageToRect:(CGRect)rect;
- (UIImage *)maskImageWithImage:(UIImage *)mask;
- (CGAffineTransform)orientationTransform:(CGSize *)newSize;
- (UIImage *)straightenAndScaleImage:(NSUInteger)maxDimension;

@end


//
@interface UIView (ViewEx)
- (void)removeSubviews;

- (void)hideKeyboard;
- (UIView *)findFirstResponder;
- (UIView *)findSubview:(NSString *)cls;

- (UIActivityIndicatorView *)showActivityIndicator:(BOOL)show;

- (void)fadeForAction:(SEL)action target:(id)target;
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration;
- (void)fadeForAction:(SEL)action target:(id)target duration:(CGFloat)duration delay:(CGFloat)delay;

- (void)shakeAnimatingWithCompletion:(void (^)(BOOL finished))completion;
- (void)shakeAnimating;

- (UIImage*)screenshot;
- (UIImage*)screenshotWithOptimization:(BOOL)optimized;

@end


//
@protocol AlertViewExDelegate
@required
- (void)taskForAlertView:(UIAlertView *)alertView;
@end

//
@interface UIAlertView (AlertViewEx)

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ...;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (id)alertWithTitle:(NSString *)title;
+ (id)alertWithTask:(id/*<AlertViewExDelegate>*/)delegate title:(NSString *)title;

//
- (UITextField *)textField;
- (UIActivityIndicatorView *)activityIndicator;
- (void)dismissOnMainThread;
- (void)dismiss;

@end


//
@interface UITabBarController (TabBarControllerEx)
- (UIViewController *)currentViewController;
@end


//
@interface UIViewController (ViewControllerEx)
- (void)dismissModalViewController;
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated dismissButtonTitle:(NSString *)dismissButtonTitle;
@end


// 
@interface SolidNavigationController: UINavigationController
{
}
@end


//
#define UIButtonTypeNavigationBack		(UIButtonType)100
#define UIButtonTypeNavigationItem		(UIButtonType)101
#define UIButtonTypeNavigationDone		(UIButtonType)102
@interface UIButton (UIButtonEx)
@property(nonatomic,retain) UIColor *tintColor;
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name width:(CGFloat)width font:(UIFont *)font;
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name width:(CGFloat)width;
+ (id)buttonWithTitle:(NSString *)title name:(NSString *)name;
+ (id)buttonWithTitle:(NSString *)title width:(CGFloat)width;
+ (id)buttonWithTitle:(NSString *)title;
+ (id)longButtonWithTitle:(NSString *)title;
+ (id)minorButtonWithTitle:(NSString *)title width:(CGFloat)width;
+ (id)minorButtonWithTitle:(NSString *)title;
+ (id)longMinorButtonWithTitle:(NSString *)title;
+ (id)buttonWithImage:(UIImage *)image;
+ (id)buttonWithImageNamed:(NSString *)imageName;
@end



//
@interface UIBarButtonItem (BarButtonItemEx)
+ (id)barButtonItemWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action;
+ (id)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)action;
@end

@interface UILabel (LabelEx)

//
+ (id)labelAtPoint:(CGPoint)point
		 withText:(NSString *)text
		   withWidth:(float)width
		   withColor:(UIColor *)color
			withFont:(UIFont*)font
	   withAlignment:(NSTextAlignment)alignment;
//
+ (id)labelWithFrame:(CGRect)frame
		 withText:(NSString *)text
		   withColor:(UIColor *)color
			withFont:(UIFont *)font
	   withAlignment:(NSTextAlignment)alignment;
@end

