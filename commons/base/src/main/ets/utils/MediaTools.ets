import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import Logger from './Logger';

const TAG = 'MediaTools';

export class MediaTools {

  static async getPixelMapFromResource(context: common.UIAbilityContext,
      name: resourceManager.Resource): Promise<PixelMap> {
    let resourceMgr = context.resourceManager;
    let fileData: Uint8Array = await resourceMgr.getMediaContent(name);
    return await image.createImageSource(fileData.buffer as ArrayBuffer).createPixelMap();
  }

  static async getPixelMapFromFile(id: string, path: string): Promise<image.PixelMap> {
    Logger.info(TAG, 'getPixelMapFromFile id:' + id + ', path:' + path);
    return await image.createImageSource(path).createPixelMap();
  }

  /**
   * 日期不足两位补 0
   *
   * @param {string} value - 数据值
   * @return {string} - 日期不足两位补 0
   */
  private static fill(value: number): string {
    return value.toString().padStart(2, '0');
  }

  /**
   * 根据毫秒数计算时间
   * @param ms
   * @returns
   */
  static msToCountdownTime(ms: number): string {
    if (!ms) {
      return '00:00';
    }
    const days = Math.floor(ms / (1000 * 60 * 60 * 24));
    const hours = Math.floor((ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((ms % (1000 * 60)) / 1000);
    return `${(days ? MediaTools.fill(days) + ':' : '')}${(hours ? MediaTools.fill(hours) + ':' : '')}
      ${MediaTools.fill(minutes)}:${MediaTools.fill(seconds)} `.trim();
  }
}

/**
 * 格式化文本的，每个文本都会添加一个不可见的空格，省略号。
 *
 * 具体原因查看[https://developer.huawei.com/consumer/cn/forum/topic/0201134652640650019?fid=0102683795438680754]
 *
 * @param str 字符串
 */
export function formatStr(str: string): string {
  let newAmount = ''
  // 在每个字符后添加\u200B，
  for (let amountStrElement of str) {
    newAmount += amountStrElement + '\u200B'
  }
  return newAmount
}