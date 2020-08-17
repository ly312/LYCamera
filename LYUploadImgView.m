#import "LYUploadImgView.h"
#import "LYUploadImgViewCell.h"
#import "LYUploadImgModel.h"
#import "LYCamera.h"

static NSString *ident = @"Item";

@interface LYUploadImgView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic) NSInteger maxDefaultCount;//默认最大上传数量，最多5张

@property (nonatomic) NSInteger currentImgCount;//当前上传图片数量
@property (nonatomic, strong) UIButton *buttonUpload;//上传图片按钮
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;//数据源数组
@property (nonatomic, strong) NSMutableArray *imgDataSource;//回调的上传图片数组

@end

@implementation LYUploadImgView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createUI];
        [self initDataSource];
    }
    return self;
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _layout.itemSize = CGSizeMake(self.frame.size.height, self.frame.size.height);
    _collectionView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _buttonUpload.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
}

#pragma mark - 创建UI
-(void)createUI{
    [self addSubview:self.buttonUpload];
    [self addSubview:self.collectionView];
    [self isHideUploadView:NO];
}

#pragma mark - 控制上传按钮和Collection的隐藏与显示
-(void)isHideUploadView:(BOOL)isHide{
    self.buttonUpload.hidden = isHide;
    self.collectionView.hidden = !isHide;
}

#pragma mark - 添加图片按钮
-(UIButton *)buttonUpload{
    
    if (!_buttonUpload) {
        _buttonUpload = [[UIButton alloc] init];
        [_buttonUpload setBackgroundImage:[UIImage imageNamed:@"icon_add_img"] forState:0];
        [_buttonUpload addTarget:self action:@selector(buttonUploadSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonUpload;
    
}

-(void)buttonUploadSelect:(UIButton *)btn{
    
    __weak typeof(self) wSelf = self;
    //调起相机
    [[LYCamera shareInit] openWithView:[self parentController:self] Block:^(NSData *data) {
        
        //判断上传图片数量是否小于最大限制
        if (self.currentImgCount < self.maxDefaultCount) {
            
            LYUploadImgModel *model = [[LYUploadImgModel alloc] init];
            model.img = [UIImage imageWithData:data];
            model.imgType = 0;
            [self.dataSource insertObject:model atIndex:self.dataSource.count-1];//新上传的图片存储位置永远都在默认图片的前面
            
            if (wSelf.block) {
                //图片转码base64，存储并回调出去
                NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                [self.imgDataSource addObject:encodedImageStr];
                wSelf.block(self.imgDataSource);
            }
            
        }
        
        //先把currentImgCount置0，然后遍历手动上传图片的个数，并记录
        self.currentImgCount = 0;
        for (LYUploadImgModel *model in self.dataSource) {
            if (model.imgType == 0) {
                self.currentImgCount ++;
            }
        }
        
        //手动上传图片的个数大于等于最大限制数时，移除最后一个占位图
        if (self.currentImgCount >= self.maxDefaultCount) {
            [self.dataSource removeObjectAtIndex:self.maxDefaultCount];
        }
        
        [self.collectionView reloadData];
        [self isHideUploadView:YES];
        
    }];
    
}

#pragma mark - CollectionView
-(UICollectionView *)collectionView{
    
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumLineSpacing = 10;
        _layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.userInteractionEnabled = YES;
        [_collectionView registerClass:[LYUploadImgViewCell class] forCellWithReuseIdentifier:ident];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
    
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LYUploadImgViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ident forIndexPath:indexPath];
    
    LYUploadImgView *model = self.dataSource[indexPath.row];
    [cell setDataSourceWithModel:model Index:indexPath.row];
    
    //删除已上传图片的回调
    __weak typeof(self) wSelf = self;
    [cell deleteImgSelectWithBlock:^(NSInteger index) {
        
        //移除源数据数组中对应位置的图片
        [self.dataSource removeObjectAtIndex:index];
        
        if (wSelf.block) {
            //从回调数组中移除对应位置的图片，并回调出去
            [wSelf.imgDataSource removeObjectAtIndex:index];
            wSelf.block(wSelf.imgDataSource);
        }
        
        //遍历占位图是否存在，存在立刻结束遍历，并跳出当前方法
        BOOL isCancel = NO;
        for (LYUploadImgModel *model in self.dataSource) {
            if (model.imgType == 1) {
                isCancel = YES;
                break;
            }
        }
        
        //如果占位图不存在，重新添加占位图到源数组中
        if (!isCancel) {
            [self initModel];
        }
        
        [self.collectionView reloadData];
        
        //先把currentImgCount置0，然后遍历手动上传图片的个数，并记录
        self.currentImgCount = 0;
        for (LYUploadImgModel *model in self.dataSource) {
            if (model.imgType == 0) {
                self.currentImgCount ++;
            }
        }
        
        //如果手动上传图片个数为0，恢复初始状态
        if (self.currentImgCount == 0) {
            [self isHideUploadView:NO];
        }
        
    }];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.currentImgCount < self.maxDefaultCount) {
        if (indexPath.row == (self.dataSource.count-1)) {
            [self buttonUploadSelect:nil];
        }
    }
}

#pragma mark - 数据源
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

-(NSMutableArray *)imgDataSource{
    if (!_imgDataSource) {
        _imgDataSource = [NSMutableArray new];
    }
    return _imgDataSource;
}

#pragma mark - 初始化数据源
-(void)initDataSource{
    self.currentImgCount = 0;
    self.maxDefaultCount = 5;
    [self initModel];
}

-(void)initModel{
    LYUploadImgModel *model = [[LYUploadImgModel alloc] init];
    UIImage *img = [UIImage imageNamed:@"icon_add_img"];
    model.img = img;
    model.imgType = 1;
    [self.dataSource addObject:model];
}

-(void)setMaxCount:(NSInteger)maxCount{
    self.maxDefaultCount = maxCount;//最大限制数根据设置重新赋值
}

#pragma mark - 获取父视图
-(UIViewController *)parentController:(UIView *)view{
    
    for (UIView *next = [view superview] ; next ; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
    
}

@end
