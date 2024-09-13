import { BreakpointConstants, formatStr, MediaService, SongDataSource, SongItem } from '@ohos/commons'
import { CommonConstants } from '@ohos/commons/src/main/ets/constants/CommonConstants'
import { HomeConstants } from '../constants/HomeConstants';
import { TopChartsViewModel } from '../viewmodel/TopChartsViewModel';

@Component
export struct TopChartsView {
  @Consume(CommonConstants.PATH_STACK) pageInfo: NavPathStack;
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.WINDOW_WIDTH) windowWidth: number = 0;
  @Link title: Resource
  private topCharts: SongItem[] = new TopChartsViewModel().topChartsList
  private songDataSource: SongDataSource = new SongDataSource([]);

  aboutToAppear(): void {
    this.songDataSource = new SongDataSource(this.topCharts);
    AppStorage.setOrCreate(CommonConstants.SONG_LIST, this.topCharts);
    MediaService.getInstance();
  }

  @Builder
  TopChartsItemBuilder(item: SongItem, index: number) {
    Row({ space: HomeConstants.HOME_TOP_CHARTS_ROW_SPACE }) {
      Image(item.cover)
        .height($r('app.float.home_top_charts_img_size'))
        .width($r('app.float.home_top_charts_img_size'))
        .aspectRatio(HomeConstants.HOME_RANKING_GRID_RATIO)
        .borderRadius($r('app.float.home_top_charts_img_radius'))
      Column() {
        Text(formatStr(item.name))
          .fontColor(Color.White)
          .fontSize($r('app.float.home_top_charts_title_font_size'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(formatStr(item.singer))
          .fontColor($r('app.color.top_charts_desc'))
          .fontSize($r('app.float.home_top_charts_desc_font_size'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.formatMilliseconds(item.duration))
          .fontColor(Color.White)
          .fontSize($r('app.float.home_top_charts_desc_font_size'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }.layoutWeight(1)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)

      Stack() {
        Image($r('app.media.ic_collection_normal'))
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
      }.width($r('app.float.home_top_charts_collection_size'))
      .height($r('app.float.home_top_charts_collection_size'))
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.home_top_charts_item_height'))
    .padding($r('app.float.home_top_charts_item_padding'))
    .backgroundColor($r('app.color.search_background'))
    .borderRadius(HomeConstants.HOME_TOP_CHARTS_RADIUS)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      MediaService.getInstance().loadAssent(index, true)
      this.pageInfo.pushPathByName('PlayerPage', '')
    })
  }

  build() {
    Column({ space: HomeConstants.HOME_TITLE_LIST_SPACE }) {
      Text(this.title)
        .fontSize($r('app.float.home_menu_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.menu_title'))

      List({ space: HomeConstants.HOME_TOP_CHARTS_LIST_SPACE }) {
        LazyForEach(this.songDataSource, (item: SongItem, index) => {
          ListItem() {
            this.TopChartsItemBuilder(item, index)
          }
        })
      }.width(CommonConstants.FULL_PERCENT)
      .lanes(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 1 : 2, $r('app.float.banner_padding_sm'))
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: $r("app.float.home_content_padding"),
      right: $r("app.float.home_content_padding"),
    })
    .margin({
      top: $r('app.float.banner_padding_sm')
    })
  }

  formatMilliseconds(milliseconds: number) {
    // 计算分钟和秒数
    const minutes = Math.floor(milliseconds / 60000);
    const seconds = Math.floor((milliseconds % 60000) / 1000);

    // 格式化分钟和秒数，确保总是两位数
    const formattedMinutes = minutes.toString().padStart(2, '0');
    const formattedSeconds = seconds.toString().padStart(2, '0');

    // 返回格式化后的字符串
    return `${formattedMinutes}:${formattedSeconds}`;
  }

  // /**
  //  * 动态计算Grid的高度
  //  *
  //  * @param videoGridColumn
  //  * @param currentBreakpoint
  //  * @param windowWidth
  //  * @returns
  //  */
  // getGirdHeight(videoGridColumn: string, currentBreakpoint: string, windowWidth: number): string {
  //   // 获取屏幕宽度，减去两边间距，得到剩余宽度
  //   let result: number = px2vp(windowWidth) - new BreakpointType(HomeConstants.MENU_GRID_MARGIN[0],
  //     HomeConstants.MENU_GRID_MARGIN[1], HomeConstants.MENU_GRID_MARGIN[2]).getValue(this.currentBreakpoint);
  //   // 减去侧边导航栏宽度
  //   if (currentBreakpoint == BreakpointConstants.BREAKPOINT_LG) {
  //     result = result - HomeConstants.HOME_NAVIGATION_WIDTH_LG
  //   }
  //   // 根据列数计算每列的高度
  //   if (videoGridColumn === CommonConstants.HOME_MENU_GRID_COLUMNS[0]) {
  //     result = result / 1
  //   } else if (videoGridColumn === CommonConstants.HOME_MENU_GRID_COLUMNS[1]) {
  //     result = (result - HomeConstants.HOME_GRID_SPACE * 1) / 2
  //   } else if (videoGridColumn === CommonConstants.HOME_MENU_GRID_COLUMNS[2]) {
  //     result = (result - HomeConstants.HOME_GRID_SPACE * 2) / 3
  //   } else {
  //     result = (result - HomeConstants.HOME_GRID_SPACE * 3) / 4
  //   }
  //
  //   return result / HomeConstants.HOME_RANKING_GRID_RATIO * 2 + HomeConstants.HOME_GRID_SPACE + 'vp'
  // }
}