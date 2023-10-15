export const convertSecondsToMinutesSeconds = (seconds) => {
  return `${Math.floor(seconds / 60)}:${seconds % 60 < 10 ? "0" : ""}${
    seconds % 60
  }`;
};

const calculateNumberOfWordsTyped = (charTyped) => {
  return charTyped / 5;
};

const convertToMinutes = (ms) => {
  return ms / 1000 / 60;
};

export const calculateWpm = (charTyped, timeTaken) => {
  return Math.trunc(
    calculateNumberOfWordsTyped(charTyped) / convertToMinutes(timeTaken)
  );
};

export const calculateAccuracy = (typos, charTyped) => {
  return 100 - +((typos / charTyped) * 100).toFixed(1);
};

export const calculateProgress = (charTyped, typingParagraph) =>
  ((charTyped / typingParagraph.length) * 100).toFixed(0);
