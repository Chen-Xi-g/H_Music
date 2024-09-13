import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { avSession } from '@kit.AVSessionKit';
import { MediaTools } from './MediaTools';
import { common, wantAgent } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { BackgroundUtil } from './BackgroundUtil';
import { PreferencesUtil } from './PreferencesUtil';
import { CardData } from '../viewmodel/CardData';
import { formBindingData, formProvider } from '@kit.FormKit';
import { CommonConstants } from '../constants/CommonConstants';
import { AudioPlayerState, MusicPlayMode, SongItem } from '../viewmodel/SongViewModel';
import { SongItemBuilder } from '../viewmodel/SongItemBuilder';
import Logger from './Logger';

const TAG = 'MediaService';

export class MediaService {
  private context: common.UIAbilityContext | undefined = AppStorage.get(CommonConstants.CONTEXT);
  /**
   * 媒体播放器
   */
  public avPlayer?: media.AVPlayer;
  /**
   * 媒体会话
   *
   * 提供音视频统一管控能力，音视频类应用接入AVSession后，可以发送应用的数据（比如正在播放的歌曲、歌曲的播放状态等），用户可以通过系统播控中心、语音助手等应用切换多个应用、多个设备播放。
   */
  private session?: avSession.AVSession;
  /**
   * AVPlayer 当前状态
   */
  private state: AudioPlayerState = AudioPlayerState.IDLE;
  /**
   * 歌曲列表
   */
  private songList: SongItem[] = [];
  /**
   * 当前播放歌曲
   */
  private songItem: SongItem = new SongItem(0, '', '', '', undefined, '', 0);
  /**
   * 当前播放歌曲的索引
   */
  private musicIndex: number = 0;
  /**
   * 歌曲资源文件
   */
  private songItemBuilder: SongItemBuilder = new SongItemBuilder();
  /**
   * 播放模式
   */
  private playMode: MusicPlayMode = MusicPlayMode.ORDER;
  /**
   * 推送的表单ID
   */
  private formIds: string[] = [];
  /**
   * 是否正在播放
   */
  private isCurrent: boolean = true;
  /**
   * 是否准备完成
   */
  private isPrepared: boolean = false;
  /**
   * 是否第一次播放
   */
  private isFirst: boolean = true;
  /**
   * 播放器进度回调
   */
  private seekCall: (seekDoneTime: number) => void = (seekDoneTime: number) => {
    this.isCurrent = true;
    Logger.info(TAG, `AVPlayer 进度回调成功, 当前时间进度： ${seekDoneTime}`);
    this.setPlayState({
      position: {
        elapsedTime: this.getCurrentTime(),
        updateTime: new Date().getTime()
      }
    });
  };
  /**
   * 播放器错误回调
   */
  private errorCall: (err: BusinessError) => void = (err: BusinessError) => {
    Logger.error(TAG, `调用 AVPlayer 失败，错误代码： ${err.code}, 错误信息：${err.message}`);
    this.avPlayer?.reset();
  };
  /**
   * 监听资源播放当前时间
   */
  private updateTimeCall: (updateTime: number) => void = (updateTime: number) => {
    if (this.isCurrent) {
      AppStorage.setOrCreate(CommonConstants.CURRENT_TIME, MediaTools.msToCountdownTime(updateTime));
      AppStorage.setOrCreate<number>(CommonConstants.PROGRESS, updateTime);
    }
  };
  /**
   * 音量调整监听
   */
  private volumeChangeCall: (volume: number) => void = (volume: number) => {
    Logger.info(TAG, `音量调整回调，当前音量： ${volume}`);
    AppStorage.setOrCreate(CommonConstants.VOLUME, volume * 100);
    this.setPlayState({
      volume: volume
    });
  };

  constructor() {
    let list: SongItem[] | undefined = AppStorage.get(CommonConstants.SONG_LIST)
    if (list) {
      this.songList = list
    }
    this.songItemBuilder = new SongItemBuilder()
    this.initAudioPlayer()
  }

  /**
   * 创建播放器
   */
  private initAudioPlayer() {
    media.createAVPlayer()
      .then(async avPlayer => {
        if (avPlayer !== null) {
          this.avPlayer = avPlayer
          this.setAVPlayerCallback();
          this.createSession();
        }
      }).catch((error: BusinessError) => {
      Logger.error('PlayerService', 'createAVPlayer failed, error: ' + error.code)
    })
  }

  /**
   * 获取媒体服务实例
   */
  public static getInstance(): MediaService {
    let mediaService: MediaService | undefined = AppStorage.get(CommonConstants.MEDIA_SERVICE);
    if (!mediaService) {
      mediaService = new MediaService();
      AppStorage.setOrCreate(CommonConstants.MEDIA_SERVICE, mediaService);
    }
    return mediaService;
  }

  /**
   * 媒体状态回调
   */
  private stateCall: (state: string) => Promise<void> = async (state: string) => {
    switch (state) {
      case 'idle':
        Logger.info(TAG, 'AVPlayer 闲置状态已被调用');
        this.state = AudioPlayerState.IDLE;
        this.songItem = await this.songItemBuilder.build(this.songList[this.musicIndex]);
        let url = this.songItemBuilder.getRealUrl();
        if (this.avPlayer && url) {
          let avFileDescriptor: media.AVFileDescriptor = { fd: url.fd, offset: url.offset, length: url.length };
          this.avPlayer.fdSrc = avFileDescriptor;
          Logger.info(TAG, 'avPlayer.url 加载的资源文件为：' + this.avPlayer.fdSrc);
        }
        break;
      case 'initialized':
        Logger.info(TAG, 'AVPlayer 资源初始化完成状态已被调用');
        this.state = AudioPlayerState.INITIALIZED;
        if (this.avPlayer) {
          this.avPlayer.prepare().then(() => {
            Logger.info(TAG, 'AVPlayer 准备成功');
          }, (err: BusinessError) => {
            Logger.error(TAG, `调用准备失败，错误代码： ${err.code}，错误信息： ${err.message}`);
          });
        }
        break;
      case 'prepared':
        Logger.info(TAG, 'AVPlayer 准备状态已被调用');
        this.state = AudioPlayerState.PREPARED;
        this.isPrepared = true;
        AppStorage.setOrCreate(CommonConstants.TOTAL_TIME, MediaTools.msToCountdownTime(this.getDuration()));
        AppStorage.setOrCreate(CommonConstants.PROGRESS_MAX, this.getDuration());
        if (this.avPlayer) {
          this.avPlayer.play();
        }
        this.setAVMetadata();
        Logger.info(TAG, 'AVPlayer 准备成功');
        break;
      case 'playing':
        Logger.info(TAG, 'AVPlayer 播放中状态已被调用');
        this.state = AudioPlayerState.PLAY;
        break;
      case 'paused':
        Logger.info(TAG, 'AVPlayer 暂停状态已被调用');
        this.state = AudioPlayerState.PAUSE;
        break;
      case 'completed':
        Logger.info(TAG, 'AVPlayer 播放直结尾状态已被调用');
        this.state = AudioPlayerState.COMPLETED;
        this.playNextAuto(false);
        break;
      case 'stopped':
        Logger.info(TAG, 'AVPlayer 停止播放状态已被调用');
        this.state = AudioPlayerState.STOP;
        if (this.avPlayer) {
          this.avPlayer.reset();
        }
        break;
      case 'released':
        Logger.info(TAG, 'AVPlayer 销毁状态已被调用');
        this.state = AudioPlayerState.RELEASED;
        break;
      default:
        Logger.info(TAG, 'AVPlayer 未知状态已被调用');
        this.state = AudioPlayerState.UNKNOWN;
        break;
    }
    this.updateCardData();
    this.updateIsPlay(this.state === AudioPlayerState.PLAY);
  };
  /**
   * 播放回调
   */
  private playCall: () => void = () => {
    Logger.info(TAG, `on play , do play task`);
    if (this.isFirst) {
      this.loadAssent(0);
    } else {
      this.play();
    }
  };
  /**
   * 暂停回调
   */
  private pauseCall: () => void = () => {
    Logger.info(TAG, `on pause , do pause task`);
    this.pause();
  };
  /**
   * 播放下一首回调
   */
  private playNextCall: () => void = () => {
    Logger.info(TAG, `on playNext , do playNext task`);
    this.playNextAuto(true);
  };
  /**
   * 播放上一首回调
   */
  private playPreviousCall: () => void = () => {
    Logger.info(TAG, `on playPrevious , do playPrevious task`);
    this.playPrevious();
  };

  /**
   * 设置播放回调
   */
  private setAVPlayerCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('seekDone', this.seekCall);

    this.avPlayer.on('error', this.errorCall);

    this.avPlayer.on('timeUpdate', this.updateTimeCall);

    this.avPlayer.on('stateChange', this.stateCall)

    this.avPlayer.on('volumeChange', this.volumeChangeCall)
  }

  /**
   * 设置播放状态
   */
  private async setPlayState(playbackState: avSession.AVPlaybackState) {
    if (this.session) {
      this.session.setAVPlaybackState(playbackState, (err: BusinessError) => {
        if (err) {
          Logger.info(TAG, `setAVPlaybackState 失败: code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, 'setAVPlaybackState 成功');
        }
      });
    }
  }

  /**
   * 创建会话
   */
  async createSession() {
    if (!this.context) {
      return;
    }
    this.session = await avSession.createAVSession(this.context, 'SESSION_NAME', 'audio');
    this.session.activate();
    Logger.info(TAG, `session create done : sessionId : ${this.session.sessionId}`);
    this.setAVMetadata();
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: this.context.abilityInfo.bundleName,
          abilityName: this.context.abilityInfo.name
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
      if (this.session) {
        this.session.setLaunchAbility(agent);
      }
    })
    this.setListenerForMesFromController();
  }

  /**
   * 注册媒体会话监听
   */
  async setListenerForMesFromController() {
    if (!this.session) {
      return;
    }
    this.session.on('play', this.playCall);
    this.session.on('pause', this.pauseCall);
    this.session.on('playNext', this.playNextCall);
    this.session.on('playPrevious', this.playPreviousCall);
  }

  /**
   * 解注媒体会话监听
   */
  async unregisterSessionListener() {
    if (!this.session) {
      return;
    }
    this.session.off('play');
    this.session.off('pause');
    this.session.off('playNext');
    this.session.off('playPrevious');
  }

  /**
   * 设置元数据
   */
  async setAVMetadata() {
    let id = this.musicIndex;
    try {
      if (this.context && this.songList[this.musicIndex].cover) {
        let mediaImage = await MediaTools.getPixelMapFromResource(this.context,
          this.songList[this.musicIndex].cover as resourceManager.Resource);
        Logger.info(TAG, 'getPixelMapFromResource 成功' + JSON.stringify(mediaImage));
        let metadata: avSession.AVMetadata = {
          assetId: `${id}`,
          title: this.songList[this.musicIndex].name,
          artist: this.songList[this.musicIndex].singer,
          mediaImage: mediaImage,
          duration: this.getDuration()
        };
        if (this.session) {
          this.session.setAVMetadata(metadata).then(() => {
            Logger.info(TAG, 'SetAVMetadata 成功');
          }).catch((err: BusinessError) => {
            Logger.error(TAG, `SetAVMetadata 失败: code: ${err.code}, message: ${err.message}`);
          });
        }
      }
    } catch (error) {
      Logger.error(TAG, `SetAVMetadata 错误: code: ${(error as BusinessError).code},
       message: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 播放下一首
   */
  private playNext() {
    Logger.info(TAG, 'playNext Index:' + this.musicIndex + ', length-1:' + (this.songList.length - 1));
    if (this.musicIndex === this.songList.length - 1) {
      this.loadAssent(0);
    } else {
      this.loadAssent(this.musicIndex + 1);
    }
  }

  /**
   * 播放随机歌曲
   */
  private playRandom() {
    let num = Math.round(Math.random() * (this.songList.length - 1));
    if (this.musicIndex === num) {
      this.playRandom();
    } else {
      this.updateMusicIndex(num);
      this.loadAssent(num);
    }
    Logger.info(TAG, 'play Random:' + this.musicIndex);
  }

  /**
   * 加载资源
   */
  async loadAssent(musicIndex: number, isList: boolean = false) {
    if (musicIndex >= this.songList.length) {
      Logger.error(TAG, `current musicIndex ${musicIndex}`);
      return;
    }
    if (musicIndex === this.musicIndex && isList && this.state === AudioPlayerState.PLAY) {
      return;
    }
    BackgroundUtil.startContinuousTask(this.context);
    this.updateMusicIndex(musicIndex);
    if (this.isFirst && this.avPlayer) {
      this.isFirst = false;
      this.songItem = await this.songItemBuilder.build(this.songList[this.musicIndex]);
      let url = this.songItemBuilder.getRealUrl();
      if (url) {
        let avFileDescriptor: media.AVFileDescriptor = { fd: url.fd, offset: url.offset, length: url.length };
        this.avPlayer.fdSrc = avFileDescriptor;
        Logger.info(TAG, 'loadAsset avPlayer.url:' + this.avPlayer.fdSrc);
      }
    } else {
      await this.stop();
      Logger.info(`loadAssent reset ${this.songItem} src ${this.songList[this.musicIndex].src}`)
      if (this.songItem === null || this.songItem.src !== this.songList[this.musicIndex].src) {
        await this.reset();
      }
    }
  }


  /**
   * 重置播放
   */
  private async reset() {
    Logger.info(TAG, 'reset()');
    await this.songItemBuilder.release();
    if (this.avPlayer) {
      await this.avPlayer.reset();
    }
    this.isPrepared = false;
  }

  /**
   * 更新播放状态
   *
   * @param isPlay 是否播放
   */
  private updateIsPlay(isPlay: boolean) {
    AppStorage.setOrCreate<boolean>(CommonConstants.IS_PLAY, isPlay);
    this.setPlayState({
      state: isPlay ? avSession.PlaybackState.PLAYBACK_STATE_PLAY : avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: this.getCurrentTime(),
        updateTime: new Date().getTime()
      }
    });
  }

  /**
   * 准备播放器
   */
  private start() {
    if (this.avPlayer) {
      this.avPlayer.prepare().then(() => {
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `start error ${JSON.stringify(error)}`)
        this.state = AudioPlayerState.ERROR;
        this.updateIsPlay(false);
        this.isPrepared = false;
      });
    }
  }

  /**
   * 更新当前播放索引
   *
   * @param musicIndex
   */
  private updateMusicIndex(musicIndex: number) {
    Logger.info(TAG, '更新当前播放索引 ===> ' + musicIndex);
    AppStorage.setOrCreate(CommonConstants.SELECT_INDEX, musicIndex);
    if (this.musicIndex !== musicIndex) {
      this.musicIndex = musicIndex;
    }
    Logger.info(TAG, 'this.session !== undefined ===> ' + (this.session != undefined));
    if (this.session !== undefined) {
      this.setAVMetadata();
    }
  }

  /**
   * 获取当前播放位置
   *
   * 当前播放的时间进度
   */
  private getCurrentTime() {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.currentTime;
    }
    return 0;
  }

  /**
   * 获取总时长
   */
  private getDuration() {
    if (this.isPrepared && this.avPlayer) {
      return this.avPlayer.duration;
    }
    return 0;
  }

  /**
   * 否是第一次播放
   */
  public getFirst() {
    return this.isFirst;
  }

  /**
   * 更新卡片数据
   */
  public async updateCardData() {
    try {
      if (!this.context) {
        return;
      }
      PreferencesUtil.getInstance().removePreferencesFromCache(this.context);
      this.formIds = await PreferencesUtil.getInstance().getFormIds(this.context);
      if (this.formIds === null || this.formIds === undefined) {
        Logger.error(TAG, 'WANG formIds is null');
        return;
      }

      let cardSongList: Array<SongItem> = [];
      if (this.musicIndex + 1 === this.songList.length) {
        // 最后一首歌曲，添加前三首到卡片数据中
        cardSongList = this.songList.slice(0, 3);
      } else if (this.musicIndex + 2 === this.songList.length) {
        // 最后二首歌曲，添加最后一首和前两首到卡片数据中
        cardSongList.push(this.songList[this.songList.length - 1]);
        cardSongList.push(this.songList[0]);
        cardSongList.push(this.songList[1]);
      } else if (this.musicIndex + 3 === this.songList.length) {
        // 最后三首歌曲，添加后两首和第一首到卡片数据中
        cardSongList = this.songList.slice(this.songList.length - 2,
          this.songList.length);
        cardSongList.push(this.songList[0]);
      } else {
        // 其他歌曲，从当前播放的歌曲开始，添加后三首到卡片数据中
        cardSongList = this.songList.slice(this.musicIndex + 1,
          this.musicIndex + 4);
      }
      let formData: CardData = {
        isPlay: this.state === AudioPlayerState.PLAY,
        musicName: this.songList[this.musicIndex].name,
        musicCover: this.songList[this.musicIndex].cover,
        musicSinger: this.songList[this.musicIndex].singer,
        cardSongList: cardSongList
      }
      let formInfo = formBindingData.createFormBindingData(formData);

      this.formIds.forEach(formId => {
        formProvider.updateForm(formId, formInfo).then(() => {
          Logger.info(TAG, 'WANG updateForm data succeed' + ', formId:' + formId);
        }).catch((error: BusinessError) => {
          Logger.error(TAG, 'updateForm err:' + JSON.stringify(error));
          if (error.code === CommonConstants.ID_NO_EXIT && this.context) {
            PreferencesUtil.getInstance().removeFormId(this.context, formId);
          }
        })
      })
    } catch (error) {
      Logger.error(TAG, `updateCardData err: ${(error as BusinessError).code}`);
    }
  }

  /**
   * 自动播放下一首
   *
   * @param isFromControl 是否通过控制前调用
   */
  public playNextAuto(isFromControl: boolean) {
    Logger.info(TAG, 'playNextAuto 播放模式:' + this.playMode);
    switch (this.playMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        if (isFromControl) {
          this.playNext();
        } else if (this.avPlayer) {
          this.avPlayer.play();
        }
        break;
      case MusicPlayMode.ORDER:
        this.playNext();
        break;
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      default:
        break;
    }
  }


  /**
   * 播放上一首
   */
  public playPrevious() {
    switch (this.playMode) {
      case MusicPlayMode.RANDOM:
        this.playRandom();
        break;
      case MusicPlayMode.ORDER:
      case MusicPlayMode.SINGLE_CYCLE:
        if (this.musicIndex === 0) {
          this.updateMusicIndex(this.songList.length - 1);
        } else {
          this.updateMusicIndex(this.musicIndex - 1);
        }
        Logger.info(TAG, 'setLastIndex:' + this.musicIndex);
        this.loadAssent(this.musicIndex);
        break;
      default:
        break;
    }
  }

  /**
   * 播放
   */
  public async play() {
    Logger.info(TAG, 'AVPlayer play() isPrepared:' + this.isPrepared + ', state:' + this.state);
    BackgroundUtil.startContinuousTask(this.context);
    if (!this.isPrepared) {
      this.start();
    } else if (this.avPlayer) {
      this.avPlayer.play().then(() => {
        Logger.info(TAG, 'progressTime play() current time:' + this.getCurrentTime());
        this.seek(this.getCurrentTime());
        this.updateIsPlay(true);
        this.state = AudioPlayerState.PLAY;
      })
    }
  }

  /**
   * 暂停
   */
  public pause() {
    Logger.info(TAG, 'AVPlayer pause() isPrepared:' + this.isPrepared + ', state:' + this.state);
    if (this.isPrepared && this.state === AudioPlayerState.PLAY && this.avPlayer) {
      this.avPlayer.pause().then(() => {
        this.state = AudioPlayerState.PAUSE;
        this.updateIsPlay(false);
      });
    }
  }

  /**
   * 停止播放
   */
  public async stop() {
    Logger.info(TAG, 'stop()');
    if (this.isPrepared && this.avPlayer) {
      await this.avPlayer.stop();
      this.updateIsPlay(false);
      this.state = AudioPlayerState.PAUSE;
    }
  }

  /**
   * 设置播放位置
   *
   * @param ms 播放位置
   */
  public seek(ms: number) {
    if (this.isPrepared && this.state != AudioPlayerState.ERROR && this.avPlayer) {
      let seekMode = this.getCurrentTime() < ms ? 0 : 1;
      let realTime = (ms <= 0 ? 0 : (ms >= this.getDuration() ? this.getDuration() : ms));
      this.isCurrent = false;
      this.avPlayer.seek(realTime, seekMode);
    }
  }

  /**
   * 释放播放器
   */
  public release() {
    if (this.avPlayer && this.session && this.context) {
      this.updateIsPlay(false);
      this.stop();
      this.reset();
      this.avPlayer.release();
      this.state = AudioPlayerState.IDLE;
      BackgroundUtil.stopContinuousTask(this.context);
      this.unregisterSessionListener();
      this.session.destroy((err: BusinessError) => {
        if (err) {
          Logger.error(TAG, `Failed to destroy session. Code: ${err.code}, message: ${err.message}`);
        } else {
          Logger.info(TAG, `Destroy : SUCCESS `);
        }
      });
    }
  }

  /**
   * 设置音量
   *
   * @volume 音量，范围在0~1之间
   */
  public setVolume(volume: number) {
    if (this.avPlayer) {
      this.avPlayer.setVolume(volume);
    }
  }

  /**
   * 切换播放模式
   *
   * @param mode 播放模式
   */
  public changePlayMode(mode: MusicPlayMode) {
    this.playMode = mode;
    AppStorage.setOrCreate<number>(CommonConstants.PLAY_MODE, mode.valueOf());
  }
}