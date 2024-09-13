import { BreakpointConstants, BreakpointType, CommonConstants, SongItem } from '@ohos/commons'

@Preview
@Component
export struct PlayerControlSongInfoView {
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.SONG_LIST) songList: SongItem[] = [];
  @StorageProp(CommonConstants.SELECT_INDEX) selectIndex: number = 0;

  build() {
    Column() {
      Row() {
        Column({ space: 5 }) {
          Text(this.songList[this.selectIndex].name)
            .fontSize(new BreakpointType($r('app.float.player_title_font_size_sm'),
              $r('app.float.player_title_font_size_md'),
              $r('app.float.player_title_font_size_lg')).getValue(this.currentBreakpoint))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)

          Text(this.songList[this.selectIndex].singer)
            .fontColor($r('app.color.player_subtitle'))
            .fontSize(new BreakpointType($r('app.float.player_subtitle_font_size_md'),
              $r('app.float.player_subtitle_font_size_md'),
              $r('app.float.player_subtitle_font_size_lg')).getValue(this.currentBreakpoint))
        }
        .alignItems(HorizontalAlign.Start)

        Column() {
          Image($r('app.media.ic_player_collection_normal'))
            .objectFit(ImageFit.Contain)
            .width(new BreakpointType($r('app.float.player_control_collection_size_sm'),
              $r('app.float.player_control_collection_size_md'),
              $r('app.float.player_control_collection_size_lg')).getValue(this.currentBreakpoint))
            .height(CommonConstants.FULL_PERCENT)
            .aspectRatio(1)

          Text('1W+')
            .fontColor(Color.White)
            .fontSize(new BreakpointType($r('app.float.player_subtitle_font_size_md'),
              $r('app.float.player_subtitle_font_size_md'),
              $r('app.float.player_subtitle_font_size_lg')).getValue(this.currentBreakpoint))
        }
      }.width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: $r('app.float.player_page_content_padding'),
      right: $r('app.float.player_page_content_padding'),
      top: $r('app.float.player_page_content_padding')
    })
  }
}