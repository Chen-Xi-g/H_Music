import { BreakpointConstants, BreakpointType, CommonConstants } from '@ohos/commons'

@Preview
@Component
export struct PlayerToolbar {
  @Consume(CommonConstants.PATH_STACK) pageInfo: NavPathStack;
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  build() {
    Row() {
      Image($r('app.media.ic_player_close'))
        .width(new BreakpointType($r('app.float.player_close_size_sm'), $r('app.float.player_close_size_md'),
          $r('app.float.player_close_size_lg')).getValue(this.currentBreakpoint))
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.pageInfo.pop()
        })

      Image($r('app.media.ic_player_shared'))
        .width(new BreakpointType($r('app.float.player_close_size_sm'), $r('app.float.player_close_size_md'),
          $r('app.float.player_close_size_lg')).getValue(this.currentBreakpoint))
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: $r('app.float.player_page_content_padding'),
      right: $r('app.float.player_page_content_padding')
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}