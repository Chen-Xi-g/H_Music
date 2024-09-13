import {
  BreakpointConstants,
  BreakpointType,
  CommonConstants,
  formatStr,
  Logger,
  MediaService,
  MusicPlayMode,
  SongItem
} from '@ohos/commons'
import deviceInfo from '@ohos.deviceInfo';
import { PlayerConstants } from '../constants/PlayerConstants';
import { uiObserver } from '@kit.ArkUI';
import { MediaTools } from '@ohos/commons/src/main/ets/utils/MediaTools';

@Preview
@Component
export struct PlayerBar {
  @Consume(CommonConstants.PATH_STACK) pageInfo: NavPathStack;
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.WINDOW_WIDTH) windowWidth: number = 0;
  @StorageLink(CommonConstants.CURRENT_TIME) @Watch('changeIsMoving') currentTime: string = '00:00';
  @StorageLink(CommonConstants.TOTAL_TIME) totalTime: string = '00:00';
  @StorageLink(CommonConstants.PROGRESS) value: number = 0;
  @StorageLink(CommonConstants.PROGRESS_MAX) max: number = 0;
  @StorageLink(CommonConstants.SONG_LIST) songList: SongItem[] = [];
  @StorageProp(CommonConstants.SELECT_INDEX) selectIndex: number = 0;
  @StorageProp(CommonConstants.IS_PLAY) isPlay: boolean = false;
  @StorageLink(CommonConstants.VOLUME) @Watch('changeIsVolumeMoving') volume: number = 100
  @StorageLink(CommonConstants.PLAY_MODE) @Watch('changePlayMode') playMode: number = MusicPlayMode.ORDER.valueOf()
  @State playModelRes: Resource = $r('app.media.ic_public_list_cycle')
  @State isMoving: boolean = false
  @State isVolumeMoving: boolean = false
  @State isPlayerBar: boolean = true;
  @State seekBarMovingTime: string = ''
  @State seekBarMovingVolume: string = ''

  aboutToAppear(): void {
    uiObserver.on('navDestinationUpdate', (info: NavDestinationInfo) => {
      if (info.state === uiObserver.NavDestinationState.ON_SHOWN && (info.name === 'PlayerPage' || info.name === 'VideoDetail' || info.name === 'VideoPlayer')) {
        this.isPlayerBar = false
        if (info.name === 'VideoDetail') {
          MediaService.getInstance().pause()
        }
      } else if (!this.isPlayerBar && info.name !== 'VideoPlayer') {
        this.isPlayerBar = true
      }
    })
  }

  build() {
    Stack() {
      Line()
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .backgroundColor($r('app.color.player_background'))
        .blur(50)

      if (this.songList.length > 0) {
        Row({
          space: PlayerConstants.PLAYER_ROW_SPACE
        }) {
          Image(this.songList[this.selectIndex].cover)
            .width(new BreakpointType($r('app.float.player_cover_size_sm'), $r('app.float.player_cover_size_md'),
              $r('app.float.player_cover_size_lg')).getValue(this.currentBreakpoint))
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .borderRadius(new BreakpointType($r('app.float.player_cover_radius_sm'),
              $r('app.float.player_cover_radius_md'),
              $r('app.float.player_cover_radius_lg')).getValue(this.currentBreakpoint))

          Column({
            space: 5
          }) {
            Text(formatStr(this.songList[this.selectIndex].name))
              .fontColor(Color.White)
              .fontSize(new BreakpointType($r('app.float.player_title_font_size_sm'),
                $r('app.float.player_title_font_size_md'),
                $r('app.float.player_title_font_size_lg')).getValue(this.currentBreakpoint))
              .maxLines(1)
              .textOverflow({overflow: TextOverflow.Ellipsis})
            Text(formatStr(this.songList[this.selectIndex].singer))
              .fontColor($r('app.color.player_subtitle'))
              .fontSize(new BreakpointType($r('app.float.player_subtitle_font_size_sm'),
                $r('app.float.player_subtitle_font_size_md'),
                $r('app.float.player_subtitle_font_size_lg')).getValue(this.currentBreakpoint))
              .maxLines(1)
              .textOverflow({overflow: TextOverflow.Ellipsis})
          }.alignItems(HorizontalAlign.Start)
          .width('35%')
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .padding({
          left: new BreakpointType($r('app.float.player_content_padding_sm'), $r('app.float.player_content_padding_md'),
            $r('app.float.player_content_padding_left_lg')).getValue(this.currentBreakpoint),
          right: new BreakpointType($r('app.float.player_content_padding_sm'),
            $r('app.float.player_content_padding_md'),
            $r('app.float.player_content_padding_right_lg')).getValue(this.currentBreakpoint)
        })
        .margin({
          bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.player_bottom_margin') :
            0
        })

        if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
          // 音量
          Row() {
            Image($r('app.media.ic_player_volume_high'))
              .width($r('app.float.player_controller_icon_size'))
              .height($r('app.float.player_controller_icon_size'))

            Slider({
              value: this.volume,
              min: 0,
              max: 100,
              style: SliderStyle.OutSet
            })
              .trackColor($r('app.color.player_slider_track'))
              .selectedColor($r('app.color.player_slider_selected'))
              .width(180)
              .onChange((value: number, mode: SliderChangeMode) => {
                // value 始终为整数
                this.seekBarMovingVolume = value.toFixed(0)
                if (mode === SliderChangeMode.End) {
                  MediaService.getInstance().setVolume(value / 100)
                } else {
                  this.isVolumeMoving = mode === SliderChangeMode.Moving
                }
              })

            Text(this.seekBarMovingVolume)
              .fontColor(Color.White)
              .fontSize(12)
              .width('20vp')
              .visibility(this.isVolumeMoving ? Visibility.Visible : Visibility.Hidden)
              .animation({
                duration: this.isVolumeMoving ? 300 : 1000
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.End)
          .visibility(this.isPlay ? Visibility.Visible : Visibility.Hidden)
          .padding({
            right: new BreakpointType($r('app.float.player_content_padding_sm'),
              $r('app.float.player_content_padding_md'),
              $r('app.float.player_content_padding_right_lg')).getValue(this.currentBreakpoint)
          })
          .margin({
            bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
            $r('app.float.player_bottom_margin') :
              0
          })
          .animation({
            duration: 500
          })

          // 进度条
          Stack() {
            Row() {
              Text(this.isMoving ? this.seekBarMovingTime : this.currentTime)
                .fontColor(Color.White)
                .fontSize(12)
                .visibility(this.totalTime === "00:00" ? Visibility.Hidden : Visibility.Visible)
              Slider({
                value: this.value,
                min: 0,
                max: this.max,
                style: SliderStyle.OutSet
              })
                .trackColor($r('app.color.player_slider_track'))
                .selectedColor($r('app.color.player_slider_selected'))
                .layoutWeight(1)
                .onChange((value: number, mode: SliderChangeMode) => {
                  this.seekBarMovingTime = MediaTools.msToCountdownTime(value)
                  if (mode === SliderChangeMode.End) {
                    MediaService.getInstance().seek(value)
                  } else {
                    this.isMoving = mode === SliderChangeMode.Moving
                  }
                })
              Text(this.totalTime)
                .fontColor(Color.White)
                .fontSize(12)
                .visibility(this.totalTime === "00:00" ? Visibility.Hidden : Visibility.Visible)
            }.width(px2vp(this.windowWidth) / 2)
            .alignItems(VerticalAlign.Center)
            .padding({
              bottom: $r('app.float.player_bottom_margin')
            })
          }.height(CommonConstants.FULL_PERCENT)
          .alignContent(Alignment.Bottom)

          // 控制器
          Row({ space: PlayerConstants.PLAYER_CONTROLLER_SPACE_LG }) {
            Image(this.playModelRes)
              .width($r('app.float.player_controller_icon_size'))
              .height($r('app.float.player_controller_icon_size'))
              .onClick(() => {
                let index = PlayerConstants.PLAYER_PLAY_MODE_LIST.indexOf(this.playMode)
                if (PlayerConstants.PLAYER_PLAY_MODE_LIST.length - 1 === index) {
                  MediaService.getInstance().changePlayMode(PlayerConstants.PLAYER_PLAY_MODE_LIST[0])
                } else {
                  MediaService.getInstance().changePlayMode(PlayerConstants.PLAYER_PLAY_MODE_LIST[index + 1])
                }
              })
            Image($r('app.media.ic_player_previous'))
              .width($r('app.float.player_controller_icon_size'))
              .height($r('app.float.player_controller_icon_size'))
              .onClick((event) => {
                MediaService.getInstance().playPrevious()
              })
            Image(this.isPlay ? $r('app.media.ic_player_play') : $r('app.media.ic_player_pause'))
              .width($r('app.float.player_controller_play_icon_size'))
              .height($r('app.float.player_controller_play_icon_size'))
              .onClick(() => {
                if (MediaService.getInstance().getFirst()) {
                  MediaService.getInstance().loadAssent(0)
                } else {
                  this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play()
                }
              })
            Image($r('app.media.ic_player_next'))
              .width($r('app.float.player_controller_icon_size'))
              .height($r('app.float.player_controller_icon_size'))
              .onClick(() => {
                MediaService.getInstance().playNextAuto(true)
              })
            Image($r('app.media.ic_player_more'))
              .width($r('app.float.player_controller_icon_size'))
              .height($r('app.float.player_controller_icon_size'))
          }.margin({
            bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
            $r('app.float.player_bottom_margin') : 0
          })

        } else {
          // 控制器
          Stack() {
            Row({ space: PlayerConstants.PLAYER_CONTROLLER_SPACE_SM }) {
              Image($r('app.media.ic_player_previous'))
                .width($r('app.float.player_controller_icon_size'))
                .height($r('app.float.player_controller_icon_size'))
                .onClick((event) => {
                  MediaService.getInstance().playPrevious()
                })
              Image(this.isPlay ? $r('app.media.ic_player_play') : $r('app.media.ic_player_pause'))
                .width($r('app.float.player_controller_play_icon_size'))
                .height($r('app.float.player_controller_play_icon_size'))
                .onClick(() => {
                  if (MediaService.getInstance().getFirst()) {
                    MediaService.getInstance().loadAssent(0)
                  } else {
                    this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play()
                  }
                })
              Image($r('app.media.ic_player_next'))
                .width($r('app.float.player_controller_icon_size'))
                .height($r('app.float.player_controller_icon_size'))
                .onClick(() => {
                  MediaService.getInstance().playNextAuto(true)
                })
              Image($r('app.media.ic_player_more'))
                .width($r('app.float.player_controller_icon_size'))
                .height($r('app.float.player_controller_icon_size'))
            }.margin({
              bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
              $r('app.float.player_bottom_margin') :
                0,
              right: new BreakpointType($r('app.float.player_content_padding_sm'),
                $r('app.float.player_content_padding_md'),
                $r('app.float.player_content_padding_left_lg')).getValue(this.currentBreakpoint)
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .alignContent(Alignment.End)
        }
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(this.getPlayerBarBlurHeight(this.currentBreakpoint))
    .opacity(this.songList.length > 0 ? 1 : 0)
    .visibility(this.isPlayerBar ? Visibility.Visible : Visibility.Hidden)
    .margin({
      bottom: this.getPlayerBarBottomMargin(this.currentBreakpoint, this.pageInfo.size())
    })
    .animation({
      duration: 500,
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Normal,
      curve: Curve.FastOutSlowIn
    })
    .onClick(() => {
      this.pageInfo.pushPathByName('PlayerPage','')
    })
  }

  getPlayerBarBottomMargin(currentBreakpoint: string, pageSize: number): Length {
    let result = currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 0 :
      (deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? $r('app.float.player_bottom_tab_lg_margin') :
      $r('app.float.player_bottom_tab_margin'))
    if (pageSize <= 0) {
      return result
    } else {
      return 0
    }
  }

  getPlayerBarBlurHeight(currentBreakpoint: string): string {
    let result = 0
    if (currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      result = result + PlayerConstants.PLAYER_COVER_SIZE[1] + (PlayerConstants.PLAYER_PADDING[1] * 2)
    } else if (currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
      result = result + PlayerConstants.PLAYER_COVER_SIZE[2] + (PlayerConstants.PLAYER_PADDING[2] * 2) + 24
    } else {
      result = result + PlayerConstants.PLAYER_COVER_SIZE[0] + (PlayerConstants.PLAYER_PADDING[0] * 2)
    }
    return result + 'vp'
  }

  changeIsMoving() {
    this.isMoving = false
  }

  changeIsVolumeMoving() {
    this.isVolumeMoving = false
  }

  changePlayMode() {
    this.playModelRes = PlayerConstants.getPlayModeRes(this.playMode)
  }
}