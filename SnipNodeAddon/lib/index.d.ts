/**
 * 截图 SDK 类型定义
 */

export interface ScreenshotManager {
  isCaptureTracking(): boolean;
  startCapture(imagePath: string, callback: (ret: number) => void)
}

/**
 * 默认导出：已初始化的截图管理器实例
 */
declare const screenshot: ScreenshotManager;
export default screenshot;