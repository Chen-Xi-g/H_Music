import { DetailConstants } from '../constants/DetailConstants';

export class RelatedVideoViewModel {
  private relatedVideoList: RelatedVideo[] = [];
  private peripheralVideoList: RelatedVideo[] = [];

  constructor() {
    this.relatedVideoList.push(new RelatedVideo(DetailConstants.RELATED_VIDEO_TITLES[0],
      $r('app.media.related_video_1')));
    this.relatedVideoList.push(new RelatedVideo(DetailConstants.RELATED_VIDEO_TITLES[1],
      $r('app.media.related_video_2')));
    this.relatedVideoList.push(new RelatedVideo(DetailConstants.RELATED_VIDEO_TITLES[2],
      $r('app.media.related_video_3')));
    this.relatedVideoList.push(new RelatedVideo(DetailConstants.RELATED_VIDEO_TITLES[3],
      $r('app.media.related_video_4')));
    this.relatedVideoList.push(new RelatedVideo(DetailConstants.RELATED_VIDEO_TITLES[4],
      $r('app.media.related_video_5')));
    this.relatedVideoList.push(new RelatedVideo(DetailConstants.RELATED_VIDEO_TITLES[5],
      $r('app.media.related_video_6')));
    this.relatedVideoList.push(new RelatedVideo(DetailConstants.RELATED_VIDEO_TITLES[6],
      $r('app.media.related_video_7')));
    this.peripheralVideoList.push(new RelatedVideo(DetailConstants.PERIPHERAL_VIDEO_TITLE[0],
      $r('app.media.peripheral_video_1')));
    this.peripheralVideoList.push(new RelatedVideo(DetailConstants.PERIPHERAL_VIDEO_TITLE[1],
      $r('app.media.peripheral_video_2')));
    this.peripheralVideoList.push(new RelatedVideo(DetailConstants.PERIPHERAL_VIDEO_TITLE[2],
      $r('app.media.peripheral_video_3')));
    this.peripheralVideoList.push(new RelatedVideo(DetailConstants.PERIPHERAL_VIDEO_TITLE[3],
      $r('app.media.peripheral_video_4')));
    this.peripheralVideoList.push(new RelatedVideo(DetailConstants.PERIPHERAL_VIDEO_TITLE[4],
      $r('app.media.peripheral_video_5')));
  }

  getRelatedVideoList(): RelatedVideo[] {
    return this.relatedVideoList;
  }

  getPeripheralVideoList(): RelatedVideo[] {
    return this.peripheralVideoList;
  }
}

export class RelatedVideo {
  /**
   * Name of the related video.
   */
  private name: string;

  /**
   * Image src of related video.
   */
  private imageSrc: Resource;

  constructor(name: string, imageSrc: Resource) {
    this.name = name;
    this.imageSrc = imageSrc;
  }

  public getName(): string {
    return this.name;
  }

  public getImageSrc(): Resource {
    return this.imageSrc;
  }
}