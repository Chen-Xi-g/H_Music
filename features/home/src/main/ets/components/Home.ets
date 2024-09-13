import { BreakpointConstants, BreakpointType, CommonConstants, Logger, WindowUtil } from '@ohos/commons';
import { FooterTab, FooterTabViewModel } from '../viewmodel/FooterViewModel';
import deviceInfo from '@ohos.deviceInfo';
import { HomeHeader } from './HomeHeader';
import { HomeContent } from './HomeContent';
import { window } from '@kit.ArkUI';
import { TopChartsView } from './TopChartsView';

@Preview
@Component
export struct Home {
  @State currentBottomIndex: number = 0;
  @State collectionTitle: Resource = $r('app.string.mine_collection')
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @StorageLink(CommonConstants.WINDOW_WIDTH) windowWidth: number = 0;
  private onWindowSizeChange: (data: window.Size) => void = (data: window.Size) => {
    this.windowWidth = data.width;
  }
  private windowUtil?: WindowUtil;
  private mainWindow?: window.Window;
  private tabList: FooterTab[] = new FooterTabViewModel().getTabList();

  aboutToAppear(): void {
    this.windowUtil = WindowUtil.getInstance()
    if (this.windowUtil === undefined) {
      Logger.error(`WindwoUtil is undefined`);
      return;
    }
    if (deviceInfo.deviceType !== CommonConstants.DEVICE_TYPES[0]) {
      this.windowUtil.setFullScreen();
      this.windowUtil.setSystemBarColor();
    }
    this.mainWindow = this.windowUtil.getMainWindow();
    if (this.mainWindow === undefined) {
      Logger.error(`MainWindow is undefined`);
      return;
    }
    this.windowWidth = this.mainWindow.getWindowProperties().windowRect.width;
    this.mainWindow.on('windowSizeChange', this.onWindowSizeChange);
  }

  @Builder
  BottomTabBuilder(item: FooterTab, index: number) {
    Column() {
      Image(index !== this.currentBottomIndex ? item.getIcon() : item.getIconSelected())
        .objectFit(ImageFit.Cover)
        .width($r('app.float.icon_tab_width'))
        .height($r('app.float.icon_tab_height'))
      Text(item.getName())
        .fontSize($r('app.float.tab_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(index === this.currentBottomIndex ? $r('app.color.tab_font_color_selected') :
        $r('app.color.tab_font_color_normal'))
        .margin({ top: $r('app.float.tab_top_margin') })
    }
    .padding({
      bottom: this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG && deviceInfo.deviceType !==
      CommonConstants.DEVICE_TYPES[0] ? $r('app.float.bottom_navigation') : 0
    })
    .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.tab_height_lg') :
    CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      Tabs({
        barPosition: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? BarPosition.Start : BarPosition.End,
      }) {
        TabContent() {
          Column() {
            HomeHeader()
            HomeContent()
            Line()
              .height(new BreakpointType($r('app.float.tab_control_height_sm'), $r('app.float.tab_control_height_md'),
                $r('app.float.tab_control_height_lg')).getValue(this.currentBreakpoint))
          }.width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
        }.tabBar(this.BottomTabBuilder(this.tabList[0], 0))

        TabContent() {
          Column() {
            Scroll() {
              Column() {
                TopChartsView({
                  title: this.collectionTitle
                })
                Line()
                  .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
                  $r('app.float.tab_control_height_lg') : $r('app.float.tab_control_height_md'))
              }.width(CommonConstants.FULL_PERCENT)
            }
            .width(CommonConstants.FULL_PERCENT)
            .layoutWeight(1)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
          }.width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .padding({ top: this.statusBarHeight })
        }.tabBar(this.BottomTabBuilder(this.tabList[1], 1))
      }
      .backgroundColor($r('app.color.tab_background'))
      .barWidth(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.bottom_tab_bar_width_lg') :
      CommonConstants.FULL_PERCENT)
      .barHeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? CommonConstants.FULL_PERCENT :
        (deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? $r('app.float.tab_size_lg') :
        $r('app.float.tab_size')))
      .barMode(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? BarMode.Scrollable : BarMode.Fixed,
        { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
      .vertical(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG)
      .barBackgroundColor($r('app.color.tab_background'))
      .onChange((index) => {
        this.currentBottomIndex = index
      })
      .barOverlap(false)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)

      if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
        Image($r('app.media.ic_header_logo'))
          .width($r('app.float.header_logo'))
          .height($r('app.float.header_logo'))
          .margin({ left: $r('app.float.header_logo_margin'), top: this.statusBarHeight })
      }
    }.height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .alignContent(Alignment.TopStart)
  }
}
