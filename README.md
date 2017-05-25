/**
 *  业务控制室
 *
 *  每个项目划分成多个独立的业务组件(模块)；每个独立的业务组件(模块)拥有自己的代码库和工程（可以运行起来）；
 *  业务控制室的目的就是将独立的业务模块(组件)加载到App主工程，并且将AppDelegate的方法分发消息给业务组件(模块)
 *
 *  1.（App启动前）首先业务组件需要在控制室注册（通常使用+(void)load方法）
 *  2.控制室在App启动的时候，去创建业务实例
 *  3.AppDelegate分发消息给业务组件
 *
 *  必要方法：
 *  业务组件，必须实现-(instancetype)init;
 *
 *  关于分发消息给业务组件:
 *  UIApplication必须以AppDelegate作为delegateClass，包含ONEControlRoomDistributionMessage对应UIApplicationDelegate的方法
 *  业务控制室将UIApplicationDelegate方法分发给业务组件入口
 *
 */