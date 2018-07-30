//
//  KGPDFViewController.h
//  iAppPDFPlugin
//
//  Created by apple on 2017/5/23.
//
//

#import <UIKit/UIKit.h>

/********************* KGNavigationController *********************/
@interface KGNavigationController : UINavigationController
@end
/******************************************************************/

@protocol KGPDFVCDelegate <NSObject>
/** 关闭文档的回调 */
- (void)didClosedPDFFile:(NSString *)filePath;
@end


@interface KGPDFViewController : UIViewController

@property (nonatomic, assign) BOOL isReadonly;// 是否为只读模式
@property (nonatomic, assign) BOOL isEncrypted;// 是否为加密文档
@property (nonatomic, weak) id <KGPDFVCDelegate> delegate;// 代理对象
@property (nonatomic, strong) NSString *username;// 用户名
@property (nonatomic, strong) NSString *filePath;// 文档路径
@property (nonatomic, strong) NSString *destText;// 定位的文本

@end
