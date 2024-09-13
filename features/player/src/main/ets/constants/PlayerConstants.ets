import { MusicPlayMode } from '@ohos/commons'

export class PlayerConstants {
  static readonly PLAYER_COVER_SIZE: number[] = [40, 60, 80]
  static readonly PLAYER_PADDING: number[] = [10, 12, 15]
  static readonly PLAYER_ROW_SPACE: number = 15
  static readonly PLAYER_CONTROLLER_SPACE_LG: number = 42
  static readonly PLAYER_CONTROLLER_SPACE_SM: number = 10
  static readonly PLAYER_BACK_IMG_SIZE: string = '120%'
  static readonly PLAYER_COLUMN_SM: number = 4
  static readonly PLAYER_COLUMN_MD: number = 8
  static readonly PLAYER_COLUMN_LG: number =12
  static readonly PLAYER_GUTTER_X: number = 24
  static readonly PLAYER_SPAN_SM: number = 4
  static readonly PLAYER_SPAN_MD: number = 4
  static readonly PLAYER_SPAN_LG: number = 6
  static readonly PLAYER_OFFSET_MD: number = 1
  static readonly PLAYER_COVER_ROTATE_DURATION: number = 20000
  static readonly PLAYER_PLAY_MODE_LIST: MusicPlayMode[] = [MusicPlayMode.ORDER.valueOf(), MusicPlayMode.RANDOM.valueOf(), MusicPlayMode.SINGLE_CYCLE.valueOf()]
  /**
   * The value of encoding.
   */
  static readonly ENCODING: string = 'utf-8';
  static readonly PLAYER_TEXT_LIST: string[] = ['选集', '只看TA', '超清', '倍速'];
  /**
   * Episodes.
   */
  static readonly PLAYER_EPISODE: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14',
    '15', '16', '17', '18', '19', '20', '21', '22', '23', '24'];
  /**
   * Episode list lanes list.
   */
  static readonly EPISODE_LIST_LANES: number[] = [8, 4];
  /**
   * 获取当前播放模式的资源文件
   */
  static getPlayModeRes(mode: MusicPlayMode): Resource{
    switch (mode){
      case MusicPlayMode.ORDER:
        return $r('app.media.ic_public_list_cycle')
      case MusicPlayMode.RANDOM:
        return $r('app.media.ic_public_random')
      case MusicPlayMode.SINGLE_CYCLE:
        return $r('app.media.ic_public_single_cycle')
      default :
        return $r('app.media.ic_public_list_cycle')
    }
  }
}