import { SongItem } from '@ohos/commons';

export class TopChartsViewModel {
  private _topChartsList: SongItem[] = [];

  public get topChartsList(): SongItem[] {
    return this._topChartsList;
  }

  constructor() {
    this._topChartsList.push(
      new SongItem(
        1,
        'Dream It Possible',
        'Delacey',
        'lrcfiles/DreamItPossible.lrc',
        $r('app.media.ic_dream'),
        'Delacey - Dream It Possible.flac',
        204000
      )
    )
    this._topChartsList.push(
      new SongItem(
        2,
        'Dreams',
        'Benjamin Tissot',
        '',
        $r('app.media.ic_dreams'),
        'dreams.mp3',
        210000
      )
    )
    this._topChartsList.push(
      new SongItem(
        3,
        'Slow life',
        'Benjamin Lazzarus',
        '',
        $r('app.media.ic_slowlife'),
        'slowlife.mp3',
        237000
      )
    )
    this._topChartsList.push(
      new SongItem(
        4,
        'Dawn Of Change',
        'Roman Senyk',
        '',
        $r('app.media.ic_dawn_of_change'),
        'dawnofchange.mp3',
        117000
      )
    )
    this._topChartsList.push(
      new SongItem(
        5,
        'Hope',
        'Hugo Dujardin',
        '',
        $r('app.media.ic_hope'),
        'hope.mp3',
        113000
      )
    )
    this._topChartsList.push(
      new SongItem(
        6,
        'Angels By My Side',
        'Lunar Years',
        '',
        $r('app.media.ic_angels_by_my_side'),
        'angelsbymyside.mp3',
        173000
      )
    )
    this._topChartsList.push(
      new SongItem(
        7,
        'Moonlight Drive',
        'Yunior Arronte',
        '',
        $r('app.media.ic_moonlight_drive'),
        'moonlightdrive.mp3',
        249000
      )
    )
    this._topChartsList.push(
      new SongItem(
        8,
        'Prism',
        'Theatre Of Delays',
        '',
        $r('app.media.ic_prism'),
        'prism.mp3',
        174000
      )
    )
    this._topChartsList.push(
      new SongItem(
        9,
        'On Repeat',
        'Marcus P.',
        '',
        $r('app.media.ic_on_repeat'),
        'onrepeat.mp3',
        139000
      )
    )
    this._topChartsList.push(
      new SongItem(
        10,
        'The Light Between Us',
        'Shaydow',
        '',
        $r('app.media.ic_the_light_between_us'),
        'thelightbetweenus.mp3',
        184000
      )
    )
  }
}