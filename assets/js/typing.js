const typingParagraphEl = document.getElementById("typing_paragraph");
const typingBox = document.getElementById("typing_box");
const instance = new Mark(typingParagraphEl);
const typingParagraph = typingParagraphEl.textContent;
let prevError = null;
let charTyped = 0;

typingBox.addEventListener("paste", (e) => e.preventDefault()); // prevent cheating

typingBox.addEventListener("input", (e) => {});

typingBox.addEventListener("keydown", (e) => {
  if (e.key === "Backspace") {
    if (prevError === null) e.preventDefault();
    else {
      instance.unmark({ className: "incorrect" });
      charTyped--;
      prevError = null;
    }
  } else if (e.key !== "Shift" && prevError === null) {
    let classNameBasedOnCorrectness = "";

    if (typingParagraph[charTyped] === e.key) {
      if (e.key === " ") typingBox.value = "";
      else classNameBasedOnCorrectness = "correct";
    } else {
      prevError = charTyped;
      classNameBasedOnCorrectness = "incorrect";
    }
    instance.markRanges([{ start: charTyped, length: 1 }], {
      className: classNameBasedOnCorrectness,
    });
    charTyped++;
  } else {
    e.preventDefault();
  }
});
