import { BreakpointConstants, BreakpointType, CommonConstants } from '@ohos/commons'
import { it } from '@ohos/hypium';
import { HomeConstants } from '../constants/HomeConstants'
import { NewMV, NewMVViewModel } from '../viewmodel/NewMVViewModel';

@Component
export struct NewMVView {
  @Consume(CommonConstants.PATH_STACK) pageInfo: NavPathStack;
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.WINDOW_WIDTH) windowWidth: number = 0;
  private mvMain: NewMV = new NewMVViewModel().main
  private mvList: NewMV[] = new NewMVViewModel().list

  build() {
    Column({ space: HomeConstants.HOME_TITLE_LIST_SPACE }) {
      Text($r('app.string.new_mv_title'))
        .fontSize($r('app.float.home_menu_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.menu_title'))

      GridRow({
        columns: {
          sm: HomeConstants.HOME_MV_COLUMNS[0],
          md: HomeConstants.HOME_MV_COLUMNS[1],
          lg: HomeConstants.HOME_MV_COLUMNS[1]
        },
        gutter: $r("app.float.home_content_padding")
      }) {
        GridCol({
          span: {
            sm: HomeConstants.HOME_MV_COLUMNS[0],
            md: HomeConstants.HOME_MV_COLUMNS[2],
            lg: HomeConstants.HOME_MV_COLUMNS[2]
          }
        }) {
          Column() {
            Image($r('app.media.ic_harmony_os_mv'))
              .objectFit(ImageFit.Cover)
              .aspectRatio(HomeConstants.HOME_MV_RATIO)
              .width(CommonConstants.FULL_PERCENT)
              .height(CommonConstants.FULL_PERCENT)
              .borderRadius({
                topLeft: $r('app.float.home_mv_main_radius'),
                topRight: $r('app.float.home_mv_main_radius')
              })

            Row({ space: HomeConstants.HOME_MV_ROW_SPACE }) {
              Image(this.mvMain.cover)
                .objectFit(ImageFit.Cover)
                .aspectRatio(HomeConstants.HOME_MV_RATIO)
                .width(new BreakpointType($r('app.float.home_mv_main_sub_img_width_sm'),
                  $r('app.float.home_mv_main_sub_img_width_md'),
                  $r('app.float.home_mv_main_sub_img_width_lg')).getValue(this.currentBreakpoint))
                .height(CommonConstants.FULL_PERCENT)
                .borderRadius($r('app.float.home_mv_main_sub_img_radio'))
                .margin({
                  left: HomeConstants.HOME_MV_ROW_SPACE
                })
              Column({ space: HomeConstants.HOME_MV_TITLE_SUB_SPACE }) {
                Text(this.mvMain.title)
                  .fontColor(Color.White)
                  .fontSize($r('app.float.home_mv_title_font_size'))
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })

                Text(this.mvMain.subtitle)
                  .fontColor($r('app.color.home_mv_sub_title'))
                  .fontSize($r('app.float.home_mv_sub_title_font_size'))
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }.layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Button($r('app.string.play'))
                .fontSize($r('app.float.home_mv_title_font_size'))
                .backgroundColor($r('app.color.home_mv_play_btn_bg'))
                .height($r('app.float.home_mv_play_btn_height'))
                .margin({
                  right: HomeConstants.HOME_MV_ROW_SPACE
                })
                .onClick(() => {
                  this.pageInfo.pushPathByName('VideoDetail','')
                })
            }.width(CommonConstants.FULL_PERCENT)
            .margin(HomeConstants.HOME_MV_ROW_SPACE)
          }
          .width(CommonConstants.FULL_PERCENT)
          .borderRadius($r('app.float.home_mv_main_radius'))
          .backgroundColor($r('app.color.search_background'))
        }

        GridCol({
          span: {
            sm: HomeConstants.HOME_MV_COLUMNS[0],
            md: HomeConstants.HOME_MV_COLUMNS[2],
            lg: HomeConstants.HOME_MV_COLUMNS[2]
          }
        }) {
          List() {
            ForEach(this.mvList, (item: NewMV) => {
              ListItem() {
                Column() {
                  Stack() {
                    Image(item.cover)
                      .objectFit(ImageFit.Cover)
                      .width(CommonConstants.FULL_PERCENT)
                      .height(CommonConstants.FULL_PERCENT)
                      .borderRadius($r('app.float.home_mv_main_radius'))
                    Text(item.title)
                      .fontColor(Color.White)
                      .fontSize(new BreakpointType($r('app.float.home_mv_grid_desc_font_size_sm'),
                        $r('app.float.home_mv_grid_desc_font_size_md'),
                        $r('app.float.home_mv_grid_desc_font_size_lg')).getValue(this.currentBreakpoint))
                      .maxLines(1)
                      .textOverflow({
                        overflow: TextOverflow.Ellipsis
                      })
                      .margin(HomeConstants.HOME_MV_ROW_SPACE)
                  }
                  .alignContent(Alignment.BottomStart)
                  .aspectRatio(HomeConstants.HOME_MV_RATIO)
                  .width(CommonConstants.FULL_PERCENT)
                  .height(CommonConstants.FULL_PERCENT)

                  Text(item.subtitle)
                    .fontColor(Color.White)
                    .fontSize($r('app.float.home_mv_title_font_size'))
                    .maxLines(1)
                    .textOverflow({
                      overflow: TextOverflow.Ellipsis
                    })
                    .margin({top: HomeConstants.HOME_MV_ROW_SPACE, bottom: HomeConstants.HOME_MV_ROW_SPACE})
                }
                .width(CommonConstants.FULL_PERCENT)
                .alignItems(HorizontalAlign.Start)
                .onClick(() => {
                  this.pageInfo.pushPathByName('VideoDetail','')
                })
              }

            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .lanes(2, $r('app.float.home_mv_grid_gap'))
          .divider({
            strokeWidth: HomeConstants.HOME_MV_GRID_GAP
          })
        }
      }
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

  getGridHeight() {

  }
}