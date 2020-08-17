#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ LYCameraBlock)(NSData *data);

@interface LYCamera : NSObject

+(LYCamera *)shareInit;

@property (nonatomic, copy)LYCameraBlock LYCameraBlock;

-(void)openWithView:(UIViewController *)view Block:(LYCameraBlock)block;

@end

NS_ASSUME_NONNULL_END
