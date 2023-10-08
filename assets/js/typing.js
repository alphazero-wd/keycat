import { specialKeys } from "./special_keys";

const typingParagraphEl = document.getElementById("typing-paragraph");
const typingBox = document.getElementById("typing-box");
const typingParagraph = typingParagraphEl.textContent;
let prevError = null;
let charTyped = 0;

typingBox.addEventListener("paste", (e) => e.preventDefault()); // prevent cheating

typingBox.addEventListener("keydown", (e) => {
  let highlightedText = "";
  if (e.key === "Backspace") {
    if (prevError === null) e.preventDefault();
    else {
      charTyped--;
      highlightedText =
        `<mark class="correct">${typingParagraph.substring(
          0,
          charTyped
        )}</mark>` + typingParagraph.substring(charTyped);
      typingParagraphEl.innerHTML = highlightedText;
      prevError = null;
    }
  } else if (!isSpecialKeyPressed(e.key) && prevError === null) {
    let classNameBasedOnCorrectness = "";

    if (typingParagraph[charTyped] === e.key) {
      if (e.key === " ") typingBox.value = "";
      classNameBasedOnCorrectness = "correct";
    } else {
      prevError = charTyped;
      classNameBasedOnCorrectness = "incorrect";
    }

    highlightedText =
      `<mark class="correct">${typingParagraph.substring(
        0,
        charTyped
      )}</mark>` +
      `<mark class="${classNameBasedOnCorrectness}">${typingParagraph.charAt(
        charTyped
      )}</mark>` +
      typingParagraph.substring(charTyped + 1);
    typingParagraphEl.innerHTML = highlightedText;
    charTyped++;
  } else {
    e.preventDefault();
  }
});

function isSpecialKeyPressed(key) {
  const specialKeysSet = new Set(specialKeys);
  return specialKeysSet.has(key);
}
