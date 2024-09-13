import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

export class BackgroundUtil {

  /**
   * Start background task.
   *
   * @param context
   */
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      Logger.error('this avPlayer: ', `context undefined`);
      return
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: Object) => {
      try {
        backgroundTaskManager.startBackgroundRunning(context,
          backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
          Logger.info('this avPlayer: ', 'startBackgroundRunning 成功');
        }).catch((error: BusinessError) => {
          Logger.error('this avPlayer: ', `startBackgroundRunning 失败: code ${error.code}`);
        });
      } catch (error) {
        Logger.error('this avPlayer: ', `startBackgroundRunning 错误. code ${(error as BusinessError).code}
         message ${(error as BusinessError).message}`);
      }
    });
  }

  /**
   * Stop background task.
   *
   * @param context
   */
  public static stopContinuousTask(context: common.UIAbilityContext): void {
    try {
      backgroundTaskManager.stopBackgroundRunning(context).then(() => {
        Logger.info('this avPlayer: ', 'stopBackgroundRunning 成功');
      }).catch((error: BusinessError) => {
        Logger.error('this avPlayer: ', `stopBackgroundRunning 失败: code ${error.code}`);
      });
    } catch (error) {
      Logger.error('this avPlayer: ', `stopBackgroundRunning 错误. code ${(error as BusinessError).code}
       message ${(error as BusinessError).message}`);
    }
  }
}