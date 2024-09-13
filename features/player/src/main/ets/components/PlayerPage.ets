import { BreakpointConstants, CommonConstants, SongItem } from '@ohos/commons'
import { PlayerConstants } from '../constants/PlayerConstants';
import { PlayerControlCoverView } from './PlayerControlCoverView';
import { PlayerControlSongInfoView } from './PlayerControlSongInfoView';
import { PlayerControlView } from './PlayerControlView';
import { PlayerToolbar } from './PlayerToolbar';
import shiLrcView from './LrcView';
import { LrcEntry } from '../lyric/LrcEntry';
import { LyricFile, LyricScrollEffect } from '../lyric/LyricConst';
import { LyricTopPosition } from '../lyric/LyricConst';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { parseKrcLyric, parseLrcLyric } from '../lyric/LrcUtils';

@Builder
export function PlayerPageBuilder() {
  PlayerPage()
}

@Preview
@Component
export struct PlayerPage {
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  @StorageLink(CommonConstants.NAV_BAR_HEIGHT) navBarHeight: number = 0;
  @StorageLink(CommonConstants.SONG_LIST) songList: SongItem[] = [];
  @StorageProp(CommonConstants.SELECT_INDEX) @Watch('getLrcEntryList') selectIndex: number = 0;
  @StorageLink(CommonConstants.PROGRESS) time: number = 0;
  private context: common.UIAbilityContext | undefined = AppStorage.get(CommonConstants.CONTEXT);
  @State mLrcEntryList: Array<LrcEntry> = [];
  @State lyricScrollEffect: LyricScrollEffect = LyricScrollEffect.Line;

  aboutToAppear(): void {
    this.getLrcEntryList()
  }

  getLrcEntryList() {
    this.mLrcEntryList = [];
    if (!this.context) {
      return;
    }
    this.context.resourceManager.getRawFileContent(this.songList[this.selectIndex].lyric)
      .then((value: Uint8Array) => {
        let textDecoder = util.TextDecoder.create(PlayerConstants.ENCODING, { ignoreBOM: true });
        let stringData = textDecoder.decodeWithStream(value, { stream: false });
        if (this.songList[this.selectIndex].lyric.endsWith(LyricFile.KRC)) {
          this.mLrcEntryList = parseKrcLyric(stringData);
        } else if (this.songList[this.selectIndex].lyric.endsWith(LyricFile.LRC)) {
          this.mLrcEntryList = parseLrcLyric(stringData);
        }
      })
  }

  build() {
    NavDestination() {
      Stack() {
        Image(this.songList[this.selectIndex].cover)
          .size(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? {
            width: PlayerConstants.PLAYER_BACK_IMG_SIZE
          } : {
            height: PlayerConstants.PLAYER_BACK_IMG_SIZE
          })
          .objectFit(ImageFit.Cover)
          .opacity(0.5)
          .blur(255)
          .backgroundColor(Color.Black)

        Column() {
          PlayerToolbar()
          if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG || this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD){
            GridRow({
              columns: {
                sm: PlayerConstants.PLAYER_COLUMN_SM,
                md: PlayerConstants.PLAYER_COLUMN_MD,
                lg: PlayerConstants.PLAYER_COLUMN_LG
              },
              gutter: PlayerConstants.PLAYER_GUTTER_X
            }) {
              GridCol({
                span: {
                  sm: PlayerConstants.PLAYER_COLUMN_SM,
                  md: PlayerConstants.PLAYER_COLUMN_SM,
                  lg: PlayerConstants.PLAYER_COLUMN_SM
                },
                offset: { lg: PlayerConstants.PLAYER_OFFSET_MD }
              }) {
                Column() {
                  PlayerControlCoverView()
                  PlayerControlSongInfoView()
                  Blank()
                  PlayerControlView()
                }
                .height(CommonConstants.FULL_PERCENT)
                .width(CommonConstants.FULL_PERCENT)
                .clip(false)
              }

              GridCol({
                span: {
                  sm: PlayerConstants.PLAYER_COLUMN_SM,
                  md: PlayerConstants.PLAYER_SPAN_MD,
                  lg: PlayerConstants.PLAYER_SPAN_LG
                },
                offset: { lg: PlayerConstants.PLAYER_OFFSET_MD }
              }) {
                Column() {
                  shiLrcView({
                    lyricMilliSecondsTime: this.time,
                    mLrcEntryList: this.mLrcEntryList,
                    lyricScrollEffect: this.lyricScrollEffect,
                    lyricTopPosition: LyricTopPosition.Middle
                  })
                    .layoutWeight(1)
                }
                .height(CommonConstants.FULL_PERCENT)
                .width(CommonConstants.FULL_PERCENT)
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({
                  bottom: $r('app.float.player_page_content_padding')
                })
              }
            }.layoutWeight(1)
            .padding({
              bottom: $r('app.float.player_bottom_margin'),
            })
          }else {
            Swiper(){
              Column() {
                PlayerControlCoverView()
                PlayerControlSongInfoView()
                Blank()
                PlayerControlView()
              }
              .height(CommonConstants.FULL_PERCENT)
              .width(CommonConstants.FULL_PERCENT)
              .clip(false)

              Column() {
                shiLrcView({
                  lyricMilliSecondsTime: this.time,
                  mLrcEntryList: this.mLrcEntryList,
                  lyricScrollEffect: this.lyricScrollEffect,
                  lyricTopPosition: LyricTopPosition.Middle
                })
                  .layoutWeight(1)
              }
              .justifyContent(FlexAlign.Start)
              .height(CommonConstants.FULL_PERCENT)
              .width(CommonConstants.FULL_PERCENT)
              .padding({
                left: $r('app.float.player_content_padding_sm'),
                right: $r('app.float.player_content_padding_sm')
              })
            }
            .layoutWeight(1)
            .indicator(
              new DotIndicator()
                .top(0)
                .selectedColor($r('app.color.player_select_swiper'))
                .color($r('app.color.player_slider_track'))
            )
            .clip(false)
            .loop(false)
            .padding({
              bottom: $r('app.float.player_bottom_margin'),
            })
          }
        }
        .justifyContent(FlexAlign.Start)
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .padding({
          top: this.statusBarHeight,
          bottom: this.navBarHeight
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .onShown(() => {
      AppStorage.setOrCreate(CommonConstants.COVER_ROTATE_ANGLE, 360)
    })
    .onHidden(() => {
      AppStorage.setOrCreate(CommonConstants.COVER_ROTATE_ANGLE, 0)
    })
  }
}
