import { AvPlayerUtil, BreakpointConstants, CommonConstants, Logger } from '@ohos/commons';
import { CurrentOffsetUtil } from '../util/CurrentOffsetUtil';
import { RelatedList } from './RelatedList';

@Component
export struct VideoDetailView {
  @StorageLink(CommonConstants.AV_PLAYER_CURRENT_TIME) currentTime: string = '00:00:00';
  @StorageLink(CommonConstants.AV_PLAYER_TOTAL_TIME) totalTime: string = '00:00:00';
  @StorageLink(CommonConstants.AV_PLAYER_PROGRESS) progress: number = 0;
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  @Consume(CommonConstants.PATH_STACK) pageInfo: NavPathStack;
  @Link relatedVideoHeight: number;
  @Link videoHeight: number;
  private avPlayerUtil: AvPlayerUtil = new AvPlayerUtil();
  private screenHeight: number = 0;
  private surfaceId: string = '';
  private xComponentController: XComponentController = new XComponentController();
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        Stack({ alignContent: Alignment.Bottom }) {
          XComponent({
            id: 'videoDetail',
            type: XComponentType.SURFACE,
            controller: this.xComponentController
          })
            .onLoad(() => {
              this.surfaceId = this.xComponentController.getXComponentSurfaceId();
              this.avPlayerUtil.createAvPlayer(this.surfaceId, false);
            })
            .width(this.videoHeight + '%')
            .height(CommonConstants.FULL_PERCENT)
            .aspectRatio(1.78)

          Row() {
            TimeText({ time: $currentTime })
              .margin({
                left: $r('app.float.current_time_text_left'),
                right: $r('app.float.current_time_text_right')
              })

            Slider({
              min: 0,
              max: 100,
              step: 1,
              value: this.progress
            })
              .onChange((value: number, mode: SliderChangeMode) => {
                this.avPlayerUtil.sliderChange(value, mode);
              })
              .layoutWeight(1)
              .selectedColor($r('app.color.episodes_font'))

            TimeText({ time: $totalTime })
              .margin({
                left: $r('app.float.total_time_text_left'),
                right: $r('app.float.total_time_text_right')
              })

            Image($r('app.media.ic_public_enlarge'))
              .height($r('app.float.enlarge_size'))
              .width($r('app.float.enlarge_size'))
              .margin({ right: $r('app.float.enlarge_margin') })
              .fillColor(Color.White)
              .onClick(() => {
                // Full-screen playback.
                this.pageInfo.pushPath({ name: 'VideoPlayer' });
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.time_row_height'))
          .alignItems(VerticalAlign.Center)

          Image($r('app.media.ic_public_back'))
            .height($r('app.float.back_size'))
            .width($r('app.float.back_size'))
            .position({
              x: $r('app.float.back_position_x'),
              y: $r('app.float.back_position_y')
            })
            .fillColor(Color.White)
            .onClick(() => {
              this.pageInfo.pop();
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor(Color.Black)
        .onClick(() => {
          this.avPlayerUtil.playerStateControl();
        })

        RelatedList({
          relatedVideoHeight: $relatedVideoHeight,
          videoHeight: $videoHeight,
          screenHeight: this.screenHeight
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .padding({ bottom: $r('app.float.video_col_padding') })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .height(CommonConstants.FULL_PERCENT)
    .onScrollFrameBegin((offset: number) => {
      if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
        if ((offset > 0) && (this.videoHeight > 53)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - 53 ? offsetPercent :
            this.videoHeight - 53;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((offset < 0) && (this.videoHeight < 100) &&
          (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
          let heightOffset = offsetPercent < 100 - this.videoHeight ? offsetPercent :
            100 - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else {
          Logger.info(`No specific function`);
        }
      } else {
        if ((offset > 0) && (this.videoHeight === 100) && (this.relatedVideoHeight > 0)) {
          // Related list shrinking logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * 10) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight - offsetPercent * 169) <
            0 ? 0 : (this.relatedVideoHeight - offsetPercent * 169);
        } else if ((offset > 0) && (this.videoHeight > 53) &&
          (this.relatedVideoHeight === 0)) {
          // Video zoom-out logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
          // Video shrinkage percentage.
          let heightOffset = offsetPercent < this.videoHeight - 53 ? offsetPercent :
            this.videoHeight - 53;
          this.videoHeight = this.videoHeight - heightOffset;
        } else if ((this.videoHeight < 100) && (this.relatedVideoHeight === 0)
          && (offset < 0) && (CurrentOffsetUtil.scrollToTop(JSON.stringify(this.scroller.currentOffset())))) {
          // Video magnification logic.
          let offsetPercent = (Math.abs(offset) * 100) / this.screenHeight;
          let heightOffset = offsetPercent < 100 - this.videoHeight ? offsetPercent :
            100 - this.videoHeight;
          this.videoHeight = this.videoHeight + heightOffset;
        } else if ((offset < 0) && (this.videoHeight === 100) &&
          (this.relatedVideoHeight >= 0)) {
          // Related list enlargement logic.
          // Percentage of screen height by sliding.
          let offsetPercent = (Math.abs(offset) * 10) / this.screenHeight;
          this.relatedVideoHeight = (this.relatedVideoHeight + offsetPercent * 169) >
            169 ? 169 : (this.relatedVideoHeight +
            offsetPercent * 169);
        } else {
          Logger.info(`No specific function`);
        }
      }
      // Returns the actual offset 0.
      return { offsetRemain: 0 };
    })
  }
}

@Component
struct TimeText {
  @Link time: string;

  build() {
    Text(this.time)
      .fontSize($r('app.float.time_font'))
      .fontColor(Color.White)
      .lineHeight($r('app.float.time_text_line'))
      .width($r('app.float.time_text_width'))
  }
}