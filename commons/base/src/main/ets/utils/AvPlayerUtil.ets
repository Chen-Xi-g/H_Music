import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { CommonConstants } from '../constants/CommonConstants';

export class AvPlayerUtil {
  private avPlayer?: media.AVPlayer;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private url: resourceManager.RawFileDescriptor | null = null;
  private playState: boolean = true;
  private surfaceId: string = '';
  private sliderBegin: number = 0;
  private startTime: number = 0;
  private isFullScreen: boolean = false;
  private onError: (err: BusinessError) => void = (err: BusinessError) => {
    Logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    this.avPlayer.reset();
  }
  private onTimeUpdateFunction: (updateTime: number) => void = (updateTime: number) => {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    AppStorage.setOrCreate<string>(CommonConstants.AV_PLAYER_CURRENT_TIME, this.formatTime(updateTime));
    AppStorage.setOrCreate<number>(CommonConstants.AV_PLAYER_UPDATE_TIME, updateTime);
    AppStorage.setOrCreate<number>(CommonConstants.AV_PLAYER_PROGRESS, updateTime / this.avPlayer.duration * 100);
  }
  private onStateChange: (state: media.AVPlayerState) => void = async (state: media.AVPlayerState) => {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    switch (state) {
      case 'idle':
        this.url = await this.context.resourceManager.getRawFd('harmony_os_mv.mp4');
        this.avPlayer.fdSrc = this.url;
        Logger.info('AVPlayer state idle called.');
        break;
      case 'initialized':
        Logger.info('AVPlayer initialized called.');
        this.avPlayer.surfaceId = this.surfaceId;
        this.avPlayer.prepare().then(() => {
          Logger.info('AVPlayer prepare succeeded.');
        }, (err: BusinessError) => {
          Logger.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          if (this.avPlayer === undefined) {
            Logger.error(`AvPlayer is undefined`);
            return;
          }
          this.avPlayer.reset();
        });
        break;
      case 'prepared':
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
        Logger.info('AVPlayer state prepared called.');
        this.seekToStart();
        this.avPlayer.play();
        AppStorage.setOrCreate<string>(CommonConstants.AV_PLAYER_TOTAL_TIME, this.formatTime(this.avPlayer.duration));
        break;
      case 'playing':
        Logger.info('AVPlayer state playing called.');
        this.playState = true;
        if (this.isFullScreen) {
          AppStorage.setOrCreate<boolean>('fullScreenPlayState', this.playState);
        }
        this.seekToStart();
        break;
      case 'paused':
        Logger.info('AVPlayer state paused called.');
        this.playState = false;
        if (this.isFullScreen) {
          AppStorage.setOrCreate<boolean>('fullScreenPlayState', this.playState);
        }
        this.seekToStart();
        break;
      case 'completed':
        Logger.info('AVPlayer state completed called.');
        this.playState = false;
        if (this.isFullScreen) {
          AppStorage.setOrCreate<boolean>('fullScreenPlayState', this.playState);
        }
        this.avPlayer.stop();
        break;
      case 'stopped':
        Logger.info('AVPlayer state stopped called.');
        break;
      case 'released':
        Logger.info('AVPlayer state released called.');
        break;
      case 'error':
        Logger.error('AVPlayer state error called.');
        break;
      default:
        Logger.info('AVPlayer state unknown called.');
        break;
    }
  }

  async createAvPlayer(surfaceId: string, isFullScreen: boolean): Promise<void> {
    this.isFullScreen = isFullScreen;
    if (this.avPlayer === undefined || this.avPlayer.state === 'released') {
      this.avPlayer = await media.createAVPlayer();
      this.surfaceId = surfaceId;
      Logger.info('Created AvPlayer successfully.');
      // Entering idle state.
      this.url = await this.context.resourceManager.getRawFd('harmony_os_mv.mp4');
      this.avPlayer.fdSrc = this.url;
      this.setAVPlayerCallback();
    } else {
      Logger.info(`AvPlayer has been created`);
    }
  }

  setAVPlayerCallback(): void {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    this.avPlayer.on('error', this.onError);
    this.onTimeUpdate();
    this.setStateChange();
  }

  onTimeUpdate(): void {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    this.avPlayer.on('timeUpdate', this.onTimeUpdateFunction);
  }

  offTimeUpdate(): void {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    try {
      this.avPlayer.off('timeUpdate');
    } catch (exception) {
      Logger.error('Failed to unregister callback. Code: ' + JSON.stringify(exception));
    }
  }

  setStateChange(): void {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    this.avPlayer.on('stateChange', this.onStateChange)
  }

  setStartTime(startTime: number): void {
    this.startTime = startTime;
  }

  seekToStart(): void {
    if (this.startTime != 0 && this.avPlayer !== undefined) {
      this.avPlayer.seek(this.startTime, media.SeekMode.SEEK_PREV_SYNC);
      this.startTime = 0;
    } else {
      Logger.info(`Video is played from the beginning`);
    }
  }

  release(): void {
    if (this.avPlayer !== undefined && this.avPlayer.state !== 'released') {
      try {
        this.avPlayer.off('error');
        this.avPlayer.off('stateChange');
      } catch (exception) {
        Logger.error('Failed to unregister callback. Code: ' + JSON.stringify(exception));
      }
      this.avPlayer.release();
    } else {
      Logger.info(`AvPlayer release failed`);
    }
  }

  sliderChange(value: number, mode: SliderChangeMode): void {
    let seekType: media.SeekMode = value > this.sliderBegin ? media.SeekMode.SEEK_PREV_SYNC :
    media.SeekMode.SEEK_NEXT_SYNC;
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    switch (mode) {
      case SliderChangeMode.Begin:
        Logger.info(`AvPlayer SliderChangeMode Begin`);
        this.sliderBegin = value;
        this.avPlayer.pause();
        break;
      case SliderChangeMode.Moving:
        Logger.info(`AvPlayer SliderChangeMode Moving`);
        this.avPlayer.seek(value / 100 * this.avPlayer.duration, seekType);
        break;
      case SliderChangeMode.End:
        Logger.info(`AvPlayer SliderChangeMode End`);
        this.avPlayer.play();
        break;
      case SliderChangeMode.Click:
        Logger.info(`AvPlayer SliderChangeMode Click`);
        this.avPlayer.seek(this.sliderBegin / 100 * this.avPlayer.duration, seekType);
        break;
      default:
        break;
    }
  }

  playerStateControl(): void {
    if (this.avPlayer === undefined) {
      Logger.error(`AvPlayer is undefined`);
      return;
    }
    if (this.avPlayer.state === 'stopped') {
      this.avPlayer.prepare();
      return;
    }
    if (!this.playState) {
      this.avPlayer.play();
    } else {
      this.avPlayer.pause();
    }
  }

  play(): void {
    if (this.avPlayer !== undefined && !this.playState) {
      this.avPlayer.play();
    } else {
      Logger.info(`AvPlayer play failed`);
    }
  }

  pause(): void {
    if (this.avPlayer !== undefined && this.playState) {
      this.avPlayer.pause();
    } else {
      Logger.info(`AvPlayer pause failed`);
    }
  }

  formatTime(duration: number): string {
    let totalSecond: number = Math.round(duration / 1000);
    let hourNum: number = Math.floor(totalSecond / 3600);
    let minNum: number = Math.floor((totalSecond % 3600) / 60);
    let secNum: number = (totalSecond % 3600) % 60;
    return this.formatUnitTime(hourNum) + ':' + this.formatUnitTime(minNum) + ':' +
    this.formatUnitTime(secNum);
  }

  formatUnitTime(time: number): string {
    if (time >= 1 && time < 10) {
      let zero: string = '0';
      return zero.concat(time.toString());
    } else if (time >= 0 && time < 1) {
      return '00';
    }
    return time.toString();
  }
}