import { BreakpointConstants, BreakpointType, CommonConstants, MediaService,
  MusicPlayMode,
  SongItem } from '@ohos/commons'
import { MediaTools } from '@ohos/commons/src/main/ets/utils/MediaTools';
import { PlayerConstants } from '../constants/PlayerConstants';

@Preview
@Component
export struct PlayerControlView {
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.CURRENT_TIME) @Watch('changeIsMoving') currentTime: string = '00:00';
  @StorageLink(CommonConstants.TOTAL_TIME) totalTime: string = '00:00';
  @StorageLink(CommonConstants.PROGRESS) value: number = 0;
  @StorageLink(CommonConstants.PROGRESS_MAX) max: number = 0;
  @StorageLink(CommonConstants.SONG_LIST) songList: SongItem[] = [];
  @StorageProp(CommonConstants.SELECT_INDEX) selectIndex: number = 0;
  @StorageProp(CommonConstants.IS_PLAY) isPlay: boolean = false;
  @StorageLink(CommonConstants.PLAY_MODE) @Watch('changePlayMode') playMode: number = MusicPlayMode.ORDER.valueOf()
  @StorageLink(CommonConstants.VOLUME) @Watch('changeIsVolumeMoving') volume: number = 100
  @State playModelRes: Resource = PlayerConstants.getPlayModeRes(this.playMode)
  @State isMoving: boolean = false
  @State seekBarMovingTime: string = ''
  @State isVolumeMoving: boolean = false
  @State seekBarMovingVolume: string = ''
  @State isVolumePopup: boolean = false
  private intervalTag: boolean = false
  private intervalId: number = 0

  @Builder
  volumeBuilder(){
    Slider({
      value: this.volume,
      min: 0,
      max: 100,
      style: SliderStyle.OutSet,
      direction: Axis.Vertical,
      reverse: true
    })
      .trackColor($r('app.color.player_slider_track'))
      .selectedColor($r('app.color.player_slider_selected'))
      .onChange((value: number, mode: SliderChangeMode) => {
        // value 始终为整数
        this.seekBarMovingVolume = value.toFixed(0)
        if (mode === SliderChangeMode.End) {
          MediaService.getInstance().setVolume(value / 100)
        } else {
          this.isVolumeMoving = mode === SliderChangeMode.Moving
        }
      })
      .height('180vp')
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_cloud_download'))
          .width(new BreakpointType($r('app.float.player_control_collection_size_sm'),
            $r('app.float.player_control_collection_size_md'),
            $r('app.float.player_control_collection_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()

        Image($r('app.media.ic_public_comments'))
          .width(new BreakpointType($r('app.float.player_control_collection_size_sm'),
            $r('app.float.player_control_collection_size_md'),
            $r('app.float.player_control_collection_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()

        Image($r('app.media.ic_public_ring'))
          .width(new BreakpointType($r('app.float.player_control_collection_size_sm'),
            $r('app.float.player_control_collection_size_md'),
            $r('app.float.player_control_collection_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()

        Image($r('app.media.ic_public_sound'))
          .width(new BreakpointType($r('app.float.player_control_collection_size_sm'),
            $r('app.float.player_control_collection_size_md'),
            $r('app.float.player_control_collection_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()
          .bindPopup(this.isVolumePopup, {
            builder: this.volumeBuilder(),
            onStateChange: (e) => {
              if (!e.isVisible) {
                this.cancelInterval()
                this.isVolumePopup = false
              }
            }
          })
          .onClick(() => {
            this.isVolumePopup = !this.isVolumePopup
            this.dismissPopupTime()
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceAround)

      Stack() {
        Row() {
          Text(this.isMoving ? this.seekBarMovingTime : this.currentTime)
            .fontColor(Color.White)
            .fontSize(12)
          Text(this.totalTime)
            .fontColor(Color.White)
            .fontSize(12)
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: $r('app.float.player_time_margin') })
        .padding({
          left: $r('app.float.player_slider_time_margin'), right: $r('app.float.player_slider_time_margin')
        })
        Slider({
          value: this.value,
          min: 0,
          max: this.max,
          style: SliderStyle.OutSet
        })
          .blockColor($r('app.color.player_slider_block'))
          .trackColor($r('app.color.player_slider_track'))
          .selectedColor($r('app.color.player_slider_selected'))
          .blockSize({
            width: $r('app.float.player_slider_block'),
            height: $r('app.float.player_slider_block')
          })
          .width(CommonConstants.FULL_PERCENT)
          .onChange((value: number, mode) => {
            this.seekBarMovingTime = MediaTools.msToCountdownTime(value)
            if (mode === SliderChangeMode.End) {
              MediaService.getInstance().seek(value)
              this.cancelInterval()
              this.dismissPopupTime()
            } else {
              this.intervalTag = false
              this.isMoving = mode === SliderChangeMode.Moving
            }
          })
          .margin({
            left: new BreakpointType($r('app.float.player_slider_margin_sm'), $r('app.float.player_slider_margin_md'),
              $r('app.float.player_slider_margin_lg')).getValue(this.currentBreakpoint),
            right: new BreakpointType($r('app.float.player_slider_margin_sm'), $r('app.float.player_slider_margin_md'),
              $r('app.float.player_slider_margin_lg')).getValue(this.currentBreakpoint)
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .alignContent(Alignment.Bottom)
      .margin({
        top: $r('app.float.player_page_control_margin')
      })

      Row(){
        Image(this.playModelRes)
          .width(new BreakpointType($r('app.float.player_control_mode_size_sm'),
            $r('app.float.player_control_mode_size_md'),
            $r('app.float.player_control_mode_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()
          .onClick(() => {
            let index = PlayerConstants.PLAYER_PLAY_MODE_LIST.indexOf(this.playMode)
            if (PlayerConstants.PLAYER_PLAY_MODE_LIST.length - 1 === index) {
              MediaService.getInstance().changePlayMode(PlayerConstants.PLAYER_PLAY_MODE_LIST[0])
            } else {
              MediaService.getInstance().changePlayMode(PlayerConstants.PLAYER_PLAY_MODE_LIST[index + 1])
            }
          })

        Image($r('app.media.ic_public_play_last'))
          .width(new BreakpointType($r('app.float.player_control_mode_size_sm'),
            $r('app.float.player_control_mode_size_md'),
            $r('app.float.player_control_mode_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()
          .onClick(() => {
            MediaService.getInstance().playPrevious()
          })

        Image(this.isPlay ? $r('app.media.ic_public_pause_norm') : $r('app.media.ic_public_play_norm'))
          .width(new BreakpointType($r('app.float.player_control_play_size_sm'),
            $r('app.float.player_control_play_size_md'),
            $r('app.float.player_control_play_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()
          .onClick(() => {
            if (MediaService.getInstance().getFirst()) {
              MediaService.getInstance().loadAssent(0)
            } else {
              this.isPlay ? MediaService.getInstance().pause() : MediaService.getInstance().play()
            }
          })

        Image($r('app.media.ic_public_play_next'))
          .width(new BreakpointType($r('app.float.player_control_mode_size_sm'),
            $r('app.float.player_control_mode_size_md'),
            $r('app.float.player_control_mode_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()
          .onClick(() => {
            MediaService.getInstance().playNextAuto(true)
          })

        Image($r('app.media.ic_public_view_list'))
          .width(new BreakpointType($r('app.float.player_control_mode_size_sm'),
            $r('app.float.player_control_mode_size_md'),
            $r('app.float.player_control_mode_size_lg')).getValue(this.currentBreakpoint))
          .controlImageBuilder()

      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: $r('app.float.player_page_content_padding'),
      right: $r('app.float.player_page_content_padding'),
      top: $r('app.float.player_page_content_padding')
    })
  }

  dismissPopupTime(){
    if (!this.intervalTag){
      this.intervalTag = true
      this.intervalId = setInterval(()=>{
        if (this.intervalTag) {
          this.isVolumePopup = false
        }
      }, 2000)
    }
  }

  cancelInterval(){
    clearInterval(this.intervalId)
    this.intervalTag = false
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

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .opacity(0.86)
  .objectFit(ImageFit.Contain)
}