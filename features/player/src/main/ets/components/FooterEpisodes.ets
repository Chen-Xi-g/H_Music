
import { BreakpointConstants, CommonConstants } from '@ohos/commons';
import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { PlayerConstants } from '../constants/PlayerConstants';

@Component
export struct FooterEpisodes {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Link isShowingSideBar: boolean;
  @Link foldStatus: display.FoldStatus;

  build() {
    Column() {
      // Selection bottom bar.
      Row() {
        Text(PlayerConstants.PLAYER_TEXT_LIST[0])
          .fontSize($r('app.float.title_selected_font'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .lineHeight($r('app.float.title_selected_line'))
          .width($r('app.float.title_selected_width'))
          .margin({ right: $r('app.float.title_selected_margin') })
        Text(PlayerConstants.PLAYER_TEXT_LIST[1])
          .fontSize($r('app.float.title_font'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Normal)
          .lineHeight($r('app.float.title_line'))
          .width($r('app.float.title_width'))
          .opacity(CommonConstants.TEXT_OPACITY[2])
      }
      .margin({
        top: $r('app.float.title_row_top'),
        bottom: $r('app.float.title_row_bottom')
      })
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.title_row_height'))

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
                  x: $r('app.float.playing_position_x'),
                  y: $r('app.float.playing_position_y')
                })
                .visibility(index === 1 ? Visibility.Visible : Visibility.None)
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius($r('app.float.episode_row_radius'))
            .backgroundColor($r('app.color.episode_row_background'))
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.episode_row_height'))
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .padding({ bottom: $r('app.float.episode_list_bottom') })
      .lanes(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ? PlayerConstants.EPISODE_LIST_LANES[0] :
        PlayerConstants.EPISODE_LIST_LANES[1], $r('app.float.episode_list_lanes_space'))
    }
    .layoutWeight(1)
    .width(CommonConstants.FULL_PERCENT)
    .visibility(this.isShowingFooter())
    .backgroundColor(Color.Black)
    .padding({
      left: $r('app.float.episode_col_padding'),
      right: $r('app.float.episode_col_padding')
    })
  }

  isShowingFooter(): Visibility {
    if (this.isShowingSideBar) {
      if (deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[2]) {
        return (display.isFoldable() && this.foldStatus !== display.FoldStatus.FOLD_STATUS_FOLDED) ?
          Visibility.Visible : Visibility.None;
      } else if (deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0]) {
        return this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_LG ? Visibility.Visible : Visibility.None;
      }
      return Visibility.None;
    }
    return Visibility.None;
  }
}