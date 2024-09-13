import { BreakpointConstants, BreakpointType, CommonConstants } from '@ohos/commons';
import { it } from '@ohos/hypium';
import { HomeConstants } from '../constants/HomeConstants';
import { BannerImg, BannerViewModel } from '../viewmodel/BannerViewModel';

class BannerDataSource implements IDataSource {
  private bannerImgList: BannerImg[] = [];

  constructor(bannerImgList: BannerImg[]) {
    this.bannerImgList = bannerImgList;
  }

  totalCount(): number {
    return this.bannerImgList.length;
  }

  getData(index: number): BannerImg {
    return this.bannerImgList[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}

@Component
export struct BannerView {
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  private bannerImgList: BannerImg[] = new BannerViewModel().getBannerImgList();
  private bannerDataSource: BannerDataSource = new BannerDataSource([]);

  aboutToAppear(): void {
    this.bannerDataSource = new BannerDataSource(this.bannerImgList);
  }

  build() {
    Column(){
      Swiper(){
        LazyForEach(this.bannerDataSource, (item: BannerImg) => {
          Stack(){
            Image(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? item.imgSrcSm : item.imgSrc)
              .objectFit(ImageFit.Fill)
              .borderRadius($r('app.float.banner_img_border_radius'))
              .height(item.height.getValue(this.currentBreakpoint))
              .width(CommonConstants.FULL_PERCENT)
              .aspectRatio(new BreakpointType(HomeConstants.BANNER_RATIOS[0], HomeConstants.BANNER_RATIOS[1],
                HomeConstants.BANNER_RATIOS[2]).getValue(this.currentBreakpoint))

            Column({space: 5}){
              Text(item.title)
                .fontColor(Color.White)
                .fontSize(item.fontSize.getValue(this.currentBreakpoint)[0])
                .fontWeight(FontWeight.Bold)
                .letterSpacing(HomeConstants.BANNER_TEXT_LETTER_SPACES[0])
                .textShadow({
                  radius: 5,
                  color: $r('app.color.tab_background')
                })

              Text(item.desc)
                .fontColor(Color.White)
                .fontSize(item.fontSize.getValue(this.currentBreakpoint)[1])
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .letterSpacing(HomeConstants.BANNER_TEXT_LETTER_SPACES[1])
                .textShadow({
                  radius: 5,
                  color: $r('app.color.tab_background')
                })
            }.width(CommonConstants.FULL_PERCENT)
            .padding({left: $r('app.float.banner_padding_sm'), right: $r('app.float.banner_padding_sm')})
          }.width(CommonConstants.FULL_PERCENT)
          .alignContent(Alignment.Center)
        }, (item: BannerImg, index) => index + JSON.stringify(item))
      }
      .displayCount(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? 1 : 2)
      .itemSpace(HomeConstants.SWIPER_ITEM_SPACE)
      .indicator(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? Indicator.dot()
        .itemWidth($r('app.float.swiper_item_size'))
        .itemHeight($r('app.float.swiper_item_size'))
        .selectedItemWidth($r('app.float.swiper_selected_item_width'))
        .selectedItemHeight($r('app.float.swiper_item_size'))
        .color($r('app.color.swiper_indicator'))
        .selectedColor(Color.White) : false
      )
      .loop(true)
      .width(CommonConstants.FULL_PERCENT)
      .effectMode(EdgeEffect.None)
      .prevMargin(new BreakpointType($r('app.float.swiper_prev_next_margin_sm'),
        $r('app.float.swiper_prev_next_margin_md'), $r('app.float.swiper_prev_next_margin_lg'))
        .getValue(this.currentBreakpoint))
      .nextMargin(new BreakpointType($r('app.float.swiper_prev_next_margin_sm'),
        $r('app.float.swiper_prev_next_margin_md'), $r('app.float.swiper_prev_next_margin_lg'))
        .getValue(this.currentBreakpoint))
    }.width(CommonConstants.FULL_PERCENT)
    .padding({
      left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? $r('app.float.banner_padding_sm') : '0',
      right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? $r('app.float.banner_padding_sm') : '0'
    })
    .margin({top: $r('app.float.banner_padding_sm')})
  }
}