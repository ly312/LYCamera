#import <UIKit/UIKit.h>

@class LYUploadImgView;

@interface LYUploadImgViewCell : UICollectionViewCell

-(void)setDataSourceWithModel:(LYUploadImgView *)model Index:(NSInteger)index;

-(void)deleteImgSelectWithBlock:(void (^)(NSInteger index))block;

@end
