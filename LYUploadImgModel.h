#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LYUploadImgModel : NSObject

@property (nonatomic, strong) UIImage *img;

/**
 0 表示手动上传的图片
 1 表示默认的占位图片
 */
@property (nonatomic) NSInteger imgType;

@end
