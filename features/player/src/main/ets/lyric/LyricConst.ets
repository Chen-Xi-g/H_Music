/**
 * Lyrics scrolling effect.
 */
export const enum LyricScrollEffect {
  /**
   * Full line scrolling
   */
  Line,

  /**
   * Gradient Color
   */
  LetterGradient,

  /**
   * Single character scaling and gradation.
   */
  LetterScaleGradient,

  /**
   * Star scrolling style.
   */
  LetterStar
}

/**
 * Lyrics initial position
 */
export const enum LyricTopPosition {
  Top,
  Middle,
}

export class LyricFile {
  static readonly KRC: string = '.krc';
  static readonly LRC : string = '.lrc';
}

export class Rectangle {
  left: number;
  top: number;
  right: number;
  bottom: number;

  constructor(left: number, top: number, right: number, bottom: number) {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;
  }

  public isIn(x: number, y: number) {
    return x >= this.left && x <= this.right && y >= this.top && y <= this.bottom;
  }

  toString() {
    return `[Rectangle] = ${this.left}, ${this.top}, ${this.right},${this.bottom}`;
  }
}