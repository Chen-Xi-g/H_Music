export class NewMVViewModel {
  private _main: NewMV =
    new NewMV(1, $r('app.media.ic_harmony_os_mv'), '智能操作系统', 'HarmonyOS NEXT', 'harmony_os_mv.mp4')

  public get main(): NewMV {
    return this._main
  }

  private _list: Array<NewMV> = []

  public get list(): Array<NewMV> {
    return this._list
  }

  constructor() {
    this._list.push(
      new NewMV(
        1,
        $r('app.media.ic_video_grid_1'),
        '历史人文',
        '欣赏岁月流动的痕迹',
        'harmony_os_mv.mp4'
      )
    )
    this._list.push(
      new NewMV(
        2,
        $r('app.media.ic_video_grid_2'),
        '生命谜语',
        '揭开生命的奥秘',
        'harmony_os_mv.mp4'
      )
    )
    this._list.push(
      new NewMV(
        3,
        $r('app.media.ic_video_grid_3'),
        '深海探索',
        '揭示海底的神秘与未解之谜',
        'harmony_os_mv.mp4'
      )
    )
    this._list.push(
      new NewMV(
        4,
        $r('app.media.ic_video_grid_4'),
        '舞动者们',
        '探索舞蹈艺术与激情',
        'harmony_os_mv.mp4'
      )
    )
  }


}

export class NewMV {
  private _id: number

  public get id(): number {
    return this._id
  }

  private _cover: Resource

  public get cover(): Resource {
    return this._cover
  }

  private _title: string

  public get title(): string {
    return this._title
  }

  private _subtitle: string

  public get subtitle(): string {
    return this._subtitle
  }

  private _src: string

  public get src(): string {
    return this._src
  }

  constructor(id: number, cover: Resource, title: string, subtitle: string, src: string) {
    this._id = id
    this._cover = cover
    this._title = title
    this._subtitle = subtitle
    this._src = src
  }
}