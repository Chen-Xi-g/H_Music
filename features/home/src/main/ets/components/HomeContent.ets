import { BreakpointConstants } from '@ohos/commons'
import { CommonConstants } from '@ohos/commons/src/main/ets/constants/CommonConstants'
import { HomeConstants } from '../constants/HomeConstants'
import { BannerView } from './BannerView'
import { NewMVView } from './NewMVView'
import { TopChartsView } from './TopChartsView'

@Component
export struct HomeContent{
  @StorageLink(CommonConstants.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @State topChartsTitle: Resource = $r('app.string.top_charts_title')
  build() {
    Scroll(){
      Column(){
        BannerView()
        TopChartsView({
          title: this.topChartsTitle
        })
        NewMVView()
      }.width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}