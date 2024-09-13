export class CurrentOffsetUtil {
  static scrollToTop(offset: string): boolean {
    if (offset === '{"xOffset":0,"yOffset":0}') {
      return true;
    }
    return false;
  }
}