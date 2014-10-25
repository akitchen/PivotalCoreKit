#import <UIKit/UIKit.h>
#import <Cedar-iOS.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface CustomNavigationBar : UINavigationBar
@end

@implementation CustomNavigationBar
@end

@interface CustomToolbar : UIToolbar
@end

@implementation CustomToolbar
@end

SPEC_BEGIN(UINavigationControllerSpecExtensionsSpec)

describe(@"UINavigationController (spec extensions)", ^{
    __block UINavigationController *navigationController;
    __block UIViewController *rootViewController;
    __block UIViewController *pushedViewController;

    sharedExamplesFor(@"a stubbed navigation controller", ^(NSDictionary *sharedContext) {
        it(@"should add to the stack when pushed", ^{
            [navigationController pushViewController:pushedViewController animated:YES];

            navigationController.viewControllers.count should equal(2);
            navigationController.topViewController should be_same_instance_as(pushedViewController);
            navigationController.visibleViewController should be_same_instance_as(pushedViewController);
        });

        it(@"should remove from the stack when popped", ^{
            [navigationController pushViewController:pushedViewController animated:YES];

            [navigationController popViewControllerAnimated:YES];

            navigationController.viewControllers.count should equal(1);
            navigationController.topViewController should be_same_instance_as(rootViewController);
            navigationController.visibleViewController should be_same_instance_as(rootViewController);
        });

        it(@"should pop to a particular controller with the rest of the navigation stack intact", ^{
            UIViewController *middleController = [[UIViewController alloc] init];

            [navigationController pushViewController:middleController animated:YES];
            [navigationController pushViewController:pushedViewController animated:YES];

            [navigationController popToViewController:middleController animated:YES];

            navigationController.viewControllers.count should equal(2);

            navigationController.topViewController should be_same_instance_as(middleController);
            navigationController.visibleViewController should be_same_instance_as(middleController);
        });

        it(@"should pop to the root controller", ^{
            [navigationController pushViewController:pushedViewController animated:YES];

            [navigationController popToRootViewControllerAnimated:YES];

            navigationController.viewControllers.count should equal(1);
            navigationController.visibleViewController should be_same_instance_as(rootViewController);
            navigationController.topViewController should be_same_instance_as(rootViewController);
        });

        it(@"should blow up when popping to a controller which isn't in the navigation stack", ^{
            [navigationController pushViewController:pushedViewController animated:YES];
            ^{ [navigationController popToViewController:[[UIViewController alloc] init] animated:NO]; } should raise_exception;
        });
    });

    beforeEach(^{
        rootViewController = [[UIViewController alloc] init];
        pushedViewController = [[UIViewController alloc] init];
    });

    context(@"a navigation controller created with a root view controller", ^{
        beforeEach(^{
            navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
            [navigationController view];
        });

        itShouldBehaveLike(@"a stubbed navigation controller");
    });

    context(@"a navigation controller created with nav bar and toolbar classes", ^{
        beforeEach(^{
            navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CustomNavigationBar class] toolbarClass:[CustomToolbar class]];
            [navigationController pushViewController:rootViewController animated:YES];
            [navigationController view];
        });

        it(@"should have a navigation bar with the specified class", ^{
            navigationController.navigationBar should be_instance_of([CustomNavigationBar class]);
        });

        it(@"should have a toolbar with the specified class", ^{
            navigationController.toolbar should be_instance_of([CustomToolbar class]);
        });

        itShouldBehaveLike(@"a stubbed navigation controller");
    });

    context(@"a navigation controller created within a storyboard", ^{
        beforeEach(^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NavigationStackExample" bundle:nil];
            navigationController = [storyboard instantiateInitialViewController];
            rootViewController = navigationController.visibleViewController;
            [navigationController view];
        });

        it(@"should have the root view controller specified in the storyboard", ^{
            navigationController.visibleViewController should be_instance_of([UITableViewController class]);
        });

        itShouldBehaveLike(@"a stubbed navigation controller");
    });
});

SPEC_END
