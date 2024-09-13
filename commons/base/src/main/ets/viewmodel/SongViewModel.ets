export enum MusicPlayMode {
  SINGLE_CYCLE = 0,
  ORDER = 1,
  RANDOM = 2
}

export enum AudioPlayerState {
  IDLE,
  INITIALIZED,
  LOAD,
  PREPARED,
  PLAY,
  PAUSE,
  STOP,
  ERROR,
  COMPLETED,
  RELEASED,
  PROGRESS_SPEED,
  TIME_UPDATE,
  VOLUME_CHANGE,
  UNKNOWN
}

export class SongItem {
  /**
   * 歌单id
   */
  private _id: number;

  public get id(): number {
    return this._id;
  }

  /**
   * 歌单名称
   */
  private _name: string;

  public get name(): string {
    return this._name;
  }

  /**
   * 歌手名称
   */
  private _singer: string;

  public get singer(): string {
    return this._singer;
  }

  /**
   * 歌词
   */
  private _lyric: string;

  public get lyric(): string {
    return this._lyric;
  }

  /**
   * 封面
   */
  private _cover: Resource | undefined;

  public get cover(): Resource | undefined {
    return this._cover;
  }

  /**
   * 歌曲地址
   */
  private _src: string;

  public get src(): string {
    return this._src;
  }

  /**
   * 歌曲时长
   */
  private _duration: number;

  public get duration(): number {
    return this._duration;
  }

  constructor(id: number, name: string, singer: string, lyric: string, cover: Resource | undefined, src: string,
    duration: number) {
    this._id = id;
    this._name = name;
    this._singer = singer;
    this._lyric = lyric;
    this._cover = cover;
    this._src = src;
    this._duration = duration;
  }
}