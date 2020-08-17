#import "LYUploadImgViewCell.h"
#import "LYUploadImgModel.h"

typedef void(^ DeleteBlock)(NSInteger);

@interface LYUploadImgViewCell ()

@property (nonatomic, strong) UIImageView *ivImg;
@property (nonatomic, strong) UIButton *bDelete;
@property (nonatomic) NSInteger index;

@property (nonatomic, copy) DeleteBlock block;

@end

@implementation LYUploadImgViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        //图片
        self.ivImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.ivImg.backgroundColor = [UIColor whiteColor];
        self.ivImg.layer.cornerRadius = 5;
        self.ivImg.layer.masksToBounds = YES;
        [self addSubview:self.ivImg];
        
        //删除按钮
        CGFloat btnWidth = 15;
        self.bDelete = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - btnWidth, 0, btnWidth, btnWidth)];
        [self.bDelete setImage:[UIImage imageNamed:@"icon_delete_img"] forState:UIControlStateNormal];
        self.bDelete.backgroundColor = [UIColor whiteColor];
        self.bDelete.layer.cornerRadius = btnWidth / 2;
        self.bDelete.layer.masksToBounds = YES;
        [self.bDelete addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bDelete];
        
    }
    
    return self;
}

-(void)deleteAction{
    if (_block) {
        _block(_index);
    }
}

-(void)deleteImgSelectWithBlock:(void (^)(NSInteger))block{
    _block = block;
}

-(void)setDataSourceWithModel:(LYUploadImgModel *)model Index:(NSInteger)index{
    
    _index = index;
    [self.ivImg setImage:model.img];
    
    //占位图的时候不显示删除按钮
    if (model.imgType == 1) {
        self.ivImg.layer.cornerRadius = 0;
        self.bDelete.hidden = YES;
    }
    //非占位图的时候显示删除按钮
    else{
        self.ivImg.layer.cornerRadius = 5;
        self.bDelete.hidden = NO;
    }
    
}

@end
