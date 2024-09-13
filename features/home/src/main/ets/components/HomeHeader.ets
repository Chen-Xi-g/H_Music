import { CommonConstants } from '@ohos/commons/src/main/ets/constants/CommonConstants'

@Preview
@Component
export struct HomeHeader {
  @Consume(CommonConstants.PATH_STACK) pageInfo: NavPathStack;

  build() {
    Row() {
      Row({ space: CommonConstants.SEARCH_ICON_CONTENT_MARGIN }) {
        Image($r('app.media.ic_header_search'))
          .width($r('app.float.header_search_size'))
          .height($r('app.float.header_search_size'))

        Text($r('app.string.header_search'))
          .fontColor($r('app.color.search_hint'))
          .fontSize($r('app.float.search_font_size'))
      }.layoutWeight(1)
      .borderRadius($r('app.float.search_border_radius'))
      .backgroundColor($r('app.color.search_background'))
      .padding($r('app.float.search_input_padding'))
    }.width(CommonConstants.FULL_PERCENT)
    .padding({
      left: $r('app.float.header_search_margin'),
      top: $r('app.float.status_bar_padding'),
      right: $r('app.float.header_search_margin')
    })
  }
}