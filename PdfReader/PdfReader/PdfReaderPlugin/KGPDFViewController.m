//
//  KGPDFViewController.m
//  iAppPDFPlugin
//
//  Created by apple on 2017/5/23.
//
//

#import "KGPDFViewController.h"
#import "iAppPDFView.h"

// 屏幕的绝对宽度
#define kScreenWidth        MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
// 屏幕的绝对高度
#define kScreenHeight       MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
// 判断是否为iPad
#define kIsiPad             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
// 判断是否为iPhone X
#define kIsiPhoneX          (812.0 == kScreenHeight)
// 状态栏和导航栏总高度
#define kNavBarMaxHeight    (kIsiPhoneX ? 88.0 : 64.0)


/********************* KGNavigationController *********************/
@implementation KGNavigationController
- (BOOL)shouldAutorotate { return [self.visibleViewController shouldAutorotate]; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.visibleViewController supportedInterfaceOrientations];
}
@end
/******************************************************************/

@interface KGPDFViewController () <iAppPDFViewDelegate>
@property (nonatomic, weak) UIView *headerView;         // 头部视图
@property (nonatomic, weak) iAppPDFView *fileViewer;    // 文档查看器
@property (nonatomic, assign) NSUInteger currentPage;   // 当前页
@end

@implementation KGPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KGNavigationController *nav = [[KGNavigationController alloc] initWithRootViewController:self];
    nav.navigationBarHidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.fileViewer.hidden = NO;
    self.headerView.hidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 转向控制
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 关闭按钮的点击事件
- (void)onCloseBtnClicked {
    [self.fileViewer saveDocument];
    [self.fileViewer movePageWithZoomScale:1.0 offset:CGPointZero isLoadTile:YES];
    [self.fileViewer closeDocument];
    __weak KGPDFViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didClosedPDFFile:)]) {
            [weakSelf.delegate didClosedPDFFile:weakSelf.filePath];
        }
        [weakSelf.fileViewer removeFromSuperview];
    }];
}
#pragma mark - 签名按钮的点击事件
- (void)onSignBtnClicked {
    // 设置签名的尺寸
    CGSize signatureSize = CGSizeMake(100, 50);
    // 设置签名的位置（相对于目标文本位置的偏移量）
    CGPoint offset = CGPointMake(0, 0);
    [self.fileViewer openAnnotationSignatureWithText:self.destText signatureSize:signatureSize offset:offset];
    
}
#pragma mark - 删除按钮的点击事件
- (void)onDeleteBtnClicked {
    for (int i = 0; i < self.fileViewer.pageCount; i++) {
        [self.fileViewer deleteAllAnnotationWithType:KGAnnotationTypeSign pageIndex:i];
    }
}
#pragma mark - iAppPDFViewDelegate
// 当前页索引
- (void)iAppPDFView:(iAppPDFView *)pdfView pageIndexDidChange:(NSUInteger)pageIndex {
    self.currentPage = pageIndex;
    //NSLog(@"1");
}
// 批注结束/关闭的代理
- (void)iAppPDFView:(iAppPDFView *)pdfView annotationDidFinish:(BOOL)isSave annotationType:(KGAnnotationType)annotationType {
    //NSLog(@"2");
}
// 页面移动的代理
- (void)iAppPDFView:(iAppPDFView *)pdfView pageDidMoveWithInfo:(NSDictionary *)info {
    //NSLog(@"3");
}
// 域开始编辑的代理
- (CGFloat)iAppPDFView:(iAppPDFView *)pdfView fieldDidBeginEditingWithInfo:(NSDictionary *)info {
    //NSDLog(@"4");
    return 100.0;
}

#pragma mark - Getter
- (UIView *)headerView {
    if (_headerView == nil) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavBarMaxHeight)];
        headerView.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:236.0/255.0 blue:245.0/255.0 alpha:255.0/255.0];// 月白
        [self.view addSubview:headerView];
        _headerView = headerView;
        
        CGFloat buttonWidth = 44.0;
        UIFont *buttonFont = [UIFont systemFontOfSize:10.0];
        UIEdgeInsets titleEdgeInsets = UIEdgeInsetsMake(30, -(buttonWidth - 4), 0, 0);
        UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(0, 7, 14, 7);
        // 关闭按钮
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(45 * 0, CGRectGetHeight(headerView.bounds) - buttonWidth, buttonWidth, buttonWidth)];
        //closeBtn.backgroundColor = [UIColor redColor];
        closeBtn.titleLabel.font = buttonFont;
        [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [closeBtn setTitleEdgeInsets:titleEdgeInsets];
        [closeBtn setImage:[UIImage imageNamed:@"kinggrid-delete-fullText-sign"] forState:UIControlStateNormal];
        [closeBtn setImageEdgeInsets:imageEdgeInsets];
        [closeBtn addTarget:self action:@selector(onCloseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:closeBtn];
        
        if (!self.isReadonly) {// 允许编辑时才显示签名和删除按钮
            // 签名按钮
            UIButton *signBtn = [[UIButton alloc] initWithFrame:CGRectMake(45 * 1, 20, buttonWidth, buttonWidth)];
            //signBtn.backgroundColor = [UIColor greenColor];
            signBtn.titleLabel.font = buttonFont;
            [signBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [signBtn setTitle:@"签名" forState:UIControlStateNormal];
            [signBtn setTitleEdgeInsets:titleEdgeInsets];
            [signBtn setImage:[UIImage imageNamed:@"kinggrid-fullText-sign"] forState:UIControlStateNormal];
            [signBtn setImageEdgeInsets:imageEdgeInsets];
            [signBtn addTarget:self action:@selector(onSignBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:signBtn];
            // 清除签名按钮
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(45 * 2, 20, buttonWidth, buttonWidth)];
            //deleteBtn.backgroundColor = [UIColor blueColor];
            deleteBtn.titleLabel.font = buttonFont;
            [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [deleteBtn setTitleEdgeInsets:titleEdgeInsets];
            [deleteBtn setImage:[UIImage imageNamed:@"kinggrid-clean"] forState:UIControlStateNormal];
            [deleteBtn setImageEdgeInsets:imageEdgeInsets];
            [deleteBtn addTarget:self action:@selector(onDeleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:deleteBtn];
        }
    }
    return _headerView;
}
- (iAppPDFView *)fileViewer {
    if (_fileViewer == nil) {
        // NSLog(@"%@", self.filePath);
        // 解析加密文档的密码
        NSData *data = [[NSData alloc] initWithContentsOfFile:self.filePath];
        
        NSData *fileData = data;
        NSString *password = nil;
        if (self.isEncrypted) { // 加密了
            if (data.length > 4) {
                int passLength = CFSwapInt32BigToHost(((int *)data.bytes)[0]);// 转为小端模式
                // NSLog(@"passLength: %d", passLength);
                if (data.length > 4 + passLength) {
                    NSData *passData = [data subdataWithRange:NSMakeRange(4, passLength)];
                    password = [[NSString alloc] initWithData:passData encoding:NSUTF8StringEncoding];
                    // NSLog(@"password: %@", password);
                    NSUInteger fileDataLength = data.length - 4 - passLength;
                    fileData = [data subdataWithRange:NSMakeRange(4 + passLength, fileDataLength)];
                }
            }
        }
        
        // 创建PDF视图
        iAppPDFView *fileViewer = [[iAppPDFView alloc] initWithFrame:CGRectMake(0, kNavBarMaxHeight, kScreenWidth, kScreenHeight - kNavBarMaxHeight) fileData:fileData password:password];
        fileViewer.userName = self.username;
        fileViewer.delegate = self;
        fileViewer.isEdit = !self.isReadonly;
        fileViewer.isVectorPreferred = NO; //矢量优先
        fileViewer.isAutoSave = YES;  //自动保存文档
        
        [fileViewer setAnnotationSignatureViewBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        [fileViewer setAnnotationSignatureViewSeparatorLine:NO];
        
        [self.view addSubview:fileViewer];
        _fileViewer = fileViewer;
    }
    return _fileViewer;
}

@end
