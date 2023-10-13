import { specialKeys } from "./special_keys";

export class Typing {
  constructor(channel) {
    this.typingParagraphEl = document.getElementById("typing-paragraph");
    this.typingBox = document.getElementById("typing-box");
    this.prevError = null;
    this.charTyped = 0;
    this.channel = channel;
    this.typingParagraph = this.typingParagraphEl.textContent;
  }

  load() {
    this.preventCheating();
    this.onKeydown();
  }

  preventCheating() {
    this.typingBox.addEventListener("paste", (e) => e.preventDefault()); // prevent copy and paste
    this.typingParagraphEl.addEventListener("select", (e) =>
      e.preventDefault()
    ); // prevent select
  }

  onKeydown() {
    this.typingBox.addEventListener("keydown", (e) => {
      let highlightedText = "";
      if (e.key === "Backspace") {
        if (this.prevError === null) e.preventDefault();
        else {
          this.charTyped--;
          highlightedText =
            `<mark class="correct">${this.typingParagraph.substring(
              0,
              this.charTyped
            )}</mark>` + this.typingParagraph.substring(this.charTyped);

          this.typingParagraphEl.innerHTML = highlightedText;
          this.prevError = null;
        }
      } else if (!this.isSpecialKeyPressed(e.key) && this.prevError === null) {
        let classNameBasedOnCorrectness = "";

        if (this.typingParagraph[this.charTyped] === e.key) {
          if (e.key === " ") {
            this.typingBox.value = "";
            this.channel.push("progress", {
              progress: (
                (this.charTyped / this.typingParagraph.length) *
                100
              ).toFixed(0),
            });
          }
          classNameBasedOnCorrectness = "correct";
        } else {
          this.prevError = this.charTyped;
          classNameBasedOnCorrectness = "incorrect";
        }

        highlightedText =
          `<mark class="correct">${this.typingParagraph.substring(
            0,
            this.charTyped
          )}</mark>` +
          `<mark class="${classNameBasedOnCorrectness}">${this.typingParagraph.charAt(
            this.charTyped
          )}</mark>` +
          this.typingParagraph.substring(this.charTyped + 1);
        this.typingParagraphEl.innerHTML = highlightedText;
        this.charTyped++;
      } else {
        e.preventDefault();
      }
    });
  }

  isSpecialKeyPressed(key) {
    const specialKeysSet = new Set(specialKeys);
    return specialKeysSet.has(key);
  }
}
