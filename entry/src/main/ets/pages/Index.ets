import { CommonConstants } from '@ohos/commons';
import { Home } from '@ohos/home/src/main/ets/components/Home';
import { PlayerBar } from '@ohos/player/src/main/ets/components/PlayerBarView';
import { uiObserver } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @Provide(CommonConstants.PATH_STACK) pageInfo: NavPathStack = new NavPathStack();

  build() {
    Stack() {
      Navigation(this.pageInfo) {
        Home()
      }
      .mode(NavigationMode.Stack)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.tab_background'))

      PlayerBar()
    }.backgroundColor($r('app.color.tab_background'))
    .alignContent(Alignment.Bottom)
  }
}