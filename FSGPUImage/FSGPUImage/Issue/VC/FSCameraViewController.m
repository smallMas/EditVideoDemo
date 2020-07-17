//
//  FSCameraViewController.m
//  FSGPUImage
//
//  Created by 燕来秋 on 2020/7/14.
//  Copyright © 2020 燕来秋. All rights reserved.
//

#import "FSCameraViewController.h"
#import "DNLiveWindow.h"
#import "TZImagePickerController.h"
#import "FSEditVideoController.h"
#import "FSClipVideoController.h"

@interface FSCameraViewController () <TZImagePickerControllerDelegate>
@property (nonatomic, strong) DNLiveWindow *liveWindow;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *uploadButton;
@end

@implementation FSCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    [self layoutUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setupView {
    [self.view addSubview:self.liveWindow];
    [self.view addSubview:self.recordButton];
    [self.recordButton setBackgroundColor:[UIColor redColor]];
    [self.recordButton setRoundRadius:40 borderColor:[UIColor clearColor]];
    [self.recordButton addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.uploadButton];
    [self.uploadButton setBackgroundColor:[UIColor blueColor]];
    [self.uploadButton setRoundRadius:40 borderColor:[UIColor clearColor]];
    [self.uploadButton addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutUI {
    CGFloat recordWH = 80;
    CGFloat uploadWH = 80;
    CGFloat spaceW = (self.view.bounds.size.width-(recordWH+uploadWH+uploadWH))/4.0;
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(recordWH);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).inset(App_SafeBottom_H+40);
    }];
    
    [self.uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(uploadWH);
        make.bottom.mas_equalTo(self.recordButton);
        make.left.mas_equalTo(self.recordButton.mas_right).inset(spaceW);
    }];
}

#pragma mark - 懒加载
- (DNLiveWindow *)liveWindow {
    if (!_liveWindow) {
        _liveWindow = [[DNLiveWindow alloc] initWithFrame:self.view.bounds];
    }
    return _liveWindow;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _recordButton;
}

- (UIButton *)uploadButton {
    if (!_uploadButton) {
        _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _uploadButton;
}

#pragma mark - btn action
- (void)recordAction:(id)sender {
    
}

- (void)uploadAction:(id)sender {
    [self localPhotoWithTag];
}

// 相册
-(void)localPhotoWithTag
{
    TZImagePickerController *_imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    
    // 3. 设置是否可以选择视频/图片/原图
    _imagePickerVc.allowPickingVideo = YES; // 是否允许选择视频
    _imagePickerVc.allowPickingImage = NO; //是否允许选择图片
    _imagePickerVc.allowPickingOriginalPhoto = NO;// 是否允许选择原片
    _imagePickerVc.allowPickingGif = NO;  //是否允许选择GIF
    _imagePickerVc.allowCrop = YES;
    _imagePickerVc.timeout = 2;
    _imagePickerVc.cropRect = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH);
    _imagePickerVc.cropRectPortrait = CGRectMake(0, 0, SCREENWIDTH, SCREENWIDTH);
    // 4. 照片排列按修改时间升序
    _imagePickerVc.sortAscendingByModificationDate = YES;
    _imagePickerVc.showSelectBtn = NO;
    _imagePickerVc.needCircleCrop = NO;
//    _imagePickerVc.photoWidth = SCREENWIDTH*2;
    _imagePickerVc.circleCropRadius = SCREENWIDTH/2;
    _imagePickerVc.statusBarStyle = UIStatusBarStyleDefault;
//    _imagePickerVc.barItemTextColor = DSColorFromHex(0x323232);
//    _imagePickerVc.naviTitleColor = DSColorFromHex(0x323232);
    _imagePickerVc.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];

    _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
//           _imagePickerVc.navigationBar.tintColor = DSColorFromHex(0x323232);
           UIBarButtonItem *tzBarItem, *BarItem;
               tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
               BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
    //设置返回图片，防止图片被渲染变蓝，以原图显示
    _imagePickerVc.navigationBar.backIndicatorTransitionMaskImage = [[UIImage imageNamed:@"public_icon_white_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _imagePickerVc.navigationBar.backIndicatorImage = [[UIImage imageNamed:@"public_icon_white_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
           NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
           [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    _imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:_imagePickerVc animated:YES completion:nil];
    // 监听TZImagePickerController导航栏的显示与否
    [_imagePickerVc addObserver:self forKeyPath:@"navigationBar.hidden" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    NSLog(@"asset >>> %@",asset);
    
    DN_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DN_STRONG_SELF
        [FSVideoImageTool getVideoURL:asset block:^(NSURL * _Nonnull URL) {
            DN_STRONG_SELF
            dispatch_async(dispatch_get_main_queue(), ^{
                if (URL) {
                    [self gotoClipVideoURL:URL];
                }
            });
        }];
    });
}

- (void)gotoEditURL:(NSURL *)URL {
    FSRecordingInfo *info = [FSRecordingInfo new];
    info.recordingURL = URL;
    
    FSEditVideoController *vc = [FSEditVideoController new];
    vc.recordingInfo = info;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoClipVideoURL:(NSURL *)URL {
    FSRecordingInfo *info = [FSRecordingInfo new];
    info.recordingURL = URL;
    
    FSClipVideoController *vc = [FSClipVideoController new];
    vc.recordingInfo = info;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
