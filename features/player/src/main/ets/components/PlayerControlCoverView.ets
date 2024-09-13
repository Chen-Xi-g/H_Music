import { CommonConstants, SongItem } from '@ohos/commons'
import { PlayerConstants } from '../constants/PlayerConstants';

@Preview
@Component
export struct PlayerControlCoverView {
  @StorageLink(CommonConstants.WINDOW_WIDTH) windowWidth: number = 0;
  @StorageLink(CommonConstants.COVER_ROTATE_ANGLE) rotateAngle: number = 0
  @StorageLink(CommonConstants.SONG_LIST) songList: SongItem[] = [];
  @StorageProp(CommonConstants.SELECT_INDEX) selectIndex: number = 0;

  build() {
    Column() {
      Image(this.songList[this.selectIndex].cover)
        .width(CommonConstants.FULL_PERCENT)
        .aspectRatio(1)
        .borderRadius(vp2px(this.windowWidth))
        .shadow({
          radius: $r('app.float.player_shadow_radius'),
          color: $r('app.color.player_shadow_color'),
          offsetX: 0,
          offsetY: 8
        })
        .rotate({angle: this.rotateAngle})
        .animation({
          duration: PlayerConstants.PLAYER_COVER_ROTATE_DURATION,
          curve: Curve.Linear,
          delay: 1000,
          iterations: -1,
          expectedFrameRateRange: {
            min: 20,
            max: 120,
            expected: 90
          }
        })
    }.width(CommonConstants.FULL_PERCENT)
    .padding({
      left: $r('app.float.player_page_content_padding'),
      right: $r('app.float.player_page_content_padding'),
      top: $r('app.float.player_page_content_padding')
    })
  }
}