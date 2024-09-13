import { BreakpointType } from '@ohos/commons';

export class BannerViewModel {
  private _bannerImgList: BannerImg[] = [];

  constructor() {
    this._bannerImgList.push(
      new BannerImg($r('app.media.ic_banner_1'), $r('app.media.ic_banner_1_sm'),
        new BreakpointType($r('app.float.banner_height_sm'), $r('app.float.banner_height_md'),
          $r('app.float.banner_height_lg')),
        $r('app.string.banner_serenity_title'),
        $r('app.string.banner_serenity_description'),
        new BreakpointType([$r("app.float.banner_title_font_size_sm"), $r("app.float.banner_description_font_size_sm")],
          [$r("app.float.banner_title_font_size_md"), $r("app.float.banner_description_font_size_md")],
          [$r("app.float.banner_title_font_size_lg"), $r("app.float.banner_description_font_size_lg")]))
    )
    this._bannerImgList.push(
      new BannerImg($r('app.media.ic_banner_2'), $r('app.media.ic_banner_2_sm'),
        new BreakpointType($r('app.float.banner_height_sm'), $r('app.float.banner_height_md'),
          $r('app.float.banner_height_lg')), $r('app.string.banner_electronic_title'),
        $r('app.string.banner_electronic_description'),
        new BreakpointType([$r("app.float.banner_title_font_size_sm"), $r("app.float.banner_description_font_size_sm")],
          [$r("app.float.banner_title_font_size_md"), $r("app.float.banner_description_font_size_md")],
          [$r("app.float.banner_title_font_size_lg"), $r("app.float.banner_description_font_size_lg")]))
    )
    this._bannerImgList.push(
      new BannerImg($r('app.media.ic_banner_3'), $r('app.media.ic_banner_3_sm'),
        new BreakpointType($r('app.float.banner_height_sm'), $r('app.float.banner_height_md'),
          $r('app.float.banner_height_lg')), $r('app.string.banner_sleep_title'),
        $r('app.string.banner_sleep_description'),
        new BreakpointType([$r("app.float.banner_title_font_size_sm"), $r("app.float.banner_description_font_size_sm")],
          [$r("app.float.banner_title_font_size_md"), $r("app.float.banner_description_font_size_md")],
          [$r("app.float.banner_title_font_size_lg"), $r("app.float.banner_description_font_size_lg")]))
    )
    this._bannerImgList.push(
      new BannerImg($r('app.media.ic_banner_4'), $r('app.media.ic_banner_4_sm'),
        new BreakpointType($r('app.float.banner_height_sm'), $r('app.float.banner_height_md'),
          $r('app.float.banner_height_lg')), $r('app.string.banner_nature_title'),
        $r('app.string.banner_nature_description'),
        new BreakpointType([$r("app.float.banner_title_font_size_sm"), $r("app.float.banner_description_font_size_sm")],
          [$r("app.float.banner_title_font_size_md"), $r("app.float.banner_description_font_size_md")],
          [$r("app.float.banner_title_font_size_lg"), $r("app.float.banner_description_font_size_lg")]))
    )
    this._bannerImgList.push(
      new BannerImg($r('app.media.ic_banner_5'), $r('app.media.ic_banner_5_sm'),
        new BreakpointType($r('app.float.banner_height_sm'), $r('app.float.banner_height_md'),
          $r('app.float.banner_height_lg')), $r('app.string.banner_winter_title'),
        $r('app.string.banner_winter_description'),
        new BreakpointType([$r("app.float.banner_title_font_size_sm"), $r("app.float.banner_description_font_size_sm")],
          [$r("app.float.banner_title_font_size_md"), $r("app.float.banner_description_font_size_md")],
          [$r("app.float.banner_title_font_size_lg"), $r("app.float.banner_description_font_size_lg")]))
    )
  }

  getBannerImgList(): BannerImg[] {
    return this._bannerImgList;
  }
}

export class BannerImg {
  /**
   * Image src of the banner.
   */
  private _imgSrc: Resource;
  /**
   * Image src of the banner for sm.
   */
  private _imgSrcSm: Resource;
  /**
   * Height of the banner.
   */
  private _height: BreakpointType<Resource>;
  /**
   * Title of the banner.
   */
  private _title: Resource;
  /**
   * Description of the banner.
   */
  private _desc: Resource;
  private _fontSize: BreakpointType<Resource[]>;

  constructor(imgSrc: Resource, imgSrcSm: Resource, height: BreakpointType<Resource>, title: Resource, desc: Resource,
    fontSize: BreakpointType<Resource[]>) {
    this._imgSrc = imgSrc;
    this._imgSrcSm = imgSrcSm;
    this._height = height;
    this._title = title;
    this._desc = desc;
    this._fontSize = fontSize;
  }

  public get imgSrc(): Resource {
    return this._imgSrc;
  }

  public get imgSrcSm(): Resource {
    return this._imgSrcSm;
  }

  public get height(): BreakpointType<Resource> {
    return this._height;
  }

  public get title(): Resource {
    return this._title;
  }

  public get desc(): Resource {
    return this._desc;
  }

  public get fontSize(): BreakpointType<Resource[]> {
    return this._fontSize;
  }
}