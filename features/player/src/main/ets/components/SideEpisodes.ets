import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants, CommonConstants } from '@ohos/commons';
import { PlayerConstants } from '../constants/PlayerConstants';

@Component
export struct SideEpisodes {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Link isShowingSideBar: boolean;
  @Link foldStatus: display.FoldStatus;

  build() {
    Column() {
      // Episodes sidebar.
      Row() {
        Blank()
        SideTitleText({ content: PlayerConstants.PLAYER_TEXT_LIST[0] })
          .width($r('app.float.side_title_width_1'))
          .margin({ right: $r('app.float.side_title_margin') })
        SideTitleText({ content: PlayerConstants.PLAYER_TEXT_LIST[1] })
          .width($r('app.float.side_title_width_2'))
          .opacity(CommonConstants.TEXT_OPACITY[2])
        Blank()
      }
      .width(CommonConstants.FULL_PERCENT)
      .margin({ bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
        $r('app.float.side_row_margin_sm') : $r('app.float.side_row_margin') })

      List({ space: CommonConstants.LIST_SPACE }) {
        ForEach(PlayerConstants.PLAYER_EPISODE, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize($r('app.float.title_font'))
                .fontColor(index === 1 ? $r('app.color.episodes_font') : Color.White)
                .fontWeight(FontWeight.Normal)

              Image($r('app.media.video_playing'))
                .height($r('app.float.playing_size'))
                .width($r('app.float.playing_size'))
                .position({
                  x: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
                    $r('app.float.playing_position_x_side_lg') : $r('app.float.playing_position_x_side'),
                  y: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
                    $r('app.float.playing_position_y_side_lg') : $r('app.float.playing_position_y_side')
                })
                .visibility(index === 1 ? Visibility.Visible : Visibility.None)
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius($r('app.float.episode_row_radius'))
            .backgroundColor($r('app.color.episode_row_background'))
            .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.episode_row_width_lg') : $r('app.float.episode_row_width_other'))
            .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.episode_row_height_lg')  : $r('app.float.episode_row_height_other'))
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .lanes(PlayerConstants.EPISODE_LIST_LANES[1], $r('app.float.lanes_item_space'))
      .padding({
        left: $r('app.float.episodes_sidebar_padding_left_right'),
        right: $r('app.float.episodes_sidebar_padding_left_right'),
        bottom: $r('app.float.episodes_sidebar_padding_bottom')
      })
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor(Color.Black)
    .layoutWeight(this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG ? 2 : 0)
    .height(CommonConstants.FULL_PERCENT)
    .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.side_col_width') : 0)
    .visibility((this.isShowingSideBar && (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ||
      this.foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED ||
      (deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[2] && !display.getFoldStatus()))) ?
      Visibility.Visible : Visibility.None)
  }
}

@Component
struct SideTitleText {
  private content: string = '';

  build() {
    Text(this.content)
      .fontSize($r('app.float.side_text_font'))
      .fontColor(Color.White)
      .fontWeight(FontWeight.Normal)
      .lineHeight($r('app.float.side_text_line'))
  }
}