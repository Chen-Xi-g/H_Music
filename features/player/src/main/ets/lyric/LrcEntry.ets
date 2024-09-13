export interface Word {
  /**
   * What is this character
   */
  text: string;

  /**
   * This character is relative to the start time of the line. Unit: ms.
   */
  wordStartTime: number;

  /**
   * The duration of this character. Unit: ms.
   */
  duration: number;
}

export interface LrcEntry {
  /**
   * The start time of this line of lyrics. Unit: ms.
   */
  lineStartTime: number;

  /**
   * The duration of this line of lyrics. Unit: ms.
   */
  lineDuration: number;

  /**
   * This Line lyrics.
   */
  lineWords: string;

  /**
   * Content of each character.
   */
  words: Word[];
}