export class BreakpointConstants{
  /**
   * Breakpoints that represent small device types.
   */
  static readonly BREAKPOINT_SM: string = 'sm';

  /**
   * Breakpoints that represent middle device types.
   */
  static readonly BREAKPOINT_MD: string = 'md';

  /**
   * Breakpoints that represent large device types.
   */
  static readonly BREAKPOINT_LG: string = 'lg';

  /**
   * Grid row column list.
   */
  static readonly GRID_ROW_COLUMNS: number[] = [12, 15, 4];

  /**
   * Grid column span list.
   */
  static readonly GRID_COLUMN_SPANS: number[] = [12, 6, 7, 5, 3, 4, 2];

  /**
   * Breakpoint ranges.
   */
  static readonly BREAKPOINT_RANGES: number[] = [320, 600, 840];
}